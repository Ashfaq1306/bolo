import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

/// One Firestore document from the old guest data, as read by the migration.
class LegacyDoc {
  const LegacyDoc(this.id, this.data, {this.hasPendingWrites = false});
  final String id;
  final Map<String, dynamic> data;

  /// The cached copy contains a change the server has not confirmed yet.
  final bool hasPendingWrites;
}

/// The server could not be reached; the cache pass is still valid.
class LegacySourceOffline implements Exception {
  const LegacySourceOffline();
}

/// Read-only access to the old `users/<uid>/<collection>` data. The migration
/// never writes, updates or deletes anything through this (docs/13 § 11).
abstract class LegacyRecordSource {
  /// Documents in the phone's Firestore cache (works offline).
  Future<List<LegacyDoc>> readCache(String collection);

  /// Documents on the server. Throws [LegacySourceOffline] without network.
  Future<List<LegacyDoc>> readServer(String collection);

  /// Whether a server pass is possible: the old anonymous session must still
  /// be signed in, or the security rules refuse the read.
  bool get canReadServer;

  /// Lets writes that old app versions queued offline reach the server first,
  /// so the server pass sees the same data as the cache.
  Future<void> flushPendingWrites();
}

class FirestoreLegacySource implements LegacyRecordSource {
  FirestoreLegacySource(this._db, {required this.legacyUid, required this.currentUid});

  final FirebaseFirestore _db;
  final String legacyUid;
  final String? Function() currentUid;

  CollectionReference<Map<String, dynamic>> _col(String name) =>
      _db.collection('users').doc(legacyUid).collection(name);

  List<LegacyDoc> _docs(QuerySnapshot<Map<String, dynamic>> s) => [
        for (final d in s.docs) LegacyDoc(d.id, d.data(), hasPendingWrites: d.metadata.hasPendingWrites),
      ];

  @override
  Future<List<LegacyDoc>> readCache(String collection) async {
    try {
      return _docs(await _col(collection).get(const GetOptions(source: Source.cache)));
    } on FirebaseException catch (e) {
      // An empty or missing cache is not an error for the migration.
      if (e.code == 'unavailable' || e.code == 'not-found') return const [];
      rethrow;
    }
  }

  @override
  Future<List<LegacyDoc>> readServer(String collection) async {
    try {
      return _docs(await _col(collection)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 20)));
    } on TimeoutException {
      throw const LegacySourceOffline();
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable' || e.code == 'deadline-exceeded') throw const LegacySourceOffline();
      rethrow;
    }
  }

  @override
  bool get canReadServer => currentUid() == legacyUid;

  @override
  Future<void> flushPendingWrites() async {
    try {
      await _db.waitForPendingWrites().timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const LegacySourceOffline();
    }
  }
}
