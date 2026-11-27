import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/bolo_database.dart';
import '../../data/device_identity.dart';

/// A capture that could not be understood yet (usually because the phone was
/// offline). Kept ONLY on this phone until the user taps "Process".
class InboxItem {
  const InboxItem({required this.id, required this.text, required this.createdAt, required this.fromVoice});
  final String id;
  final String text;
  final DateTime createdAt;
  final bool fromVoice;
}

/// The inbox lives in the local database. It is never synced.
class InboxStore {
  InboxStore(this._db, {required this.ownerScope});
  final BoloDatabase _db;
  final String ownerScope;
  static const maxItems = 20;

  /// Old versions kept the inbox in SharedPreferences under this key.
  static const legacyPrefsKey = 'inbox.v1';

  Stream<List<InboxItem>> watch() {
    final q = _db.select(_db.inboxItems)
      ..where((t) => t.ownerScope.equals(ownerScope))
      ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
      ..limit(maxItems);
    return q.watch().map((rows) => rows.map(_fromRow).toList());
  }

  Future<void> add({required String text, required DateTime createdAt, required bool fromVoice}) =>
      _db.transaction(() async {
        await _db.into(_db.inboxItems).insert(InboxItemsCompanion.insert(
              id: newRecordId(),
              ownerScope: ownerScope,
              body: text,
              fromVoice: fromVoice,
              createdAt: createdAt.toUtc().millisecondsSinceEpoch,
            ));
        await _trim();
      });

  Future<void> remove(InboxItem item) =>
      (_db.delete(_db.inboxItems)..where((t) => t.id.equals(item.id) & t.ownerScope.equals(ownerScope))).go();

  /// Keeps only the newest [maxItems] captures, as before.
  Future<void> _trim() async {
    final keep = _db.selectOnly(_db.inboxItems)
      ..addColumns([_db.inboxItems.id])
      ..where(_db.inboxItems.ownerScope.equals(ownerScope))
      ..orderBy([OrderingTerm.desc(_db.inboxItems.createdAt)])
      ..limit(maxItems);
    await (_db.delete(_db.inboxItems)
          ..where((t) => t.ownerScope.equals(ownerScope) & t.id.isNotInQuery(keep)))
        .go();
  }

  /// One-time copy of the SharedPreferences inbox (old versions) into the
  /// database. The old value is left in place; a flag stops a second copy.
  Future<int> importLegacy(SharedPreferences prefs) async {
    if (await _db.meta(MetaKeys.inboxImported) != null) return 0;
    final items = decodeLegacyInbox(prefs.getString(legacyPrefsKey));
    await _db.transaction(() async {
      for (final i in items) {
        await _db.into(_db.inboxItems).insert(InboxItemsCompanion.insert(
              id: newRecordId(),
              ownerScope: ownerScope,
              body: i.text,
              fromVoice: i.fromVoice,
              createdAt: i.createdAt.toUtc().millisecondsSinceEpoch,
            ));
      }
      await _db.setMeta(MetaKeys.inboxImported, '1');
    });
    return items.length;
  }

  InboxItem _fromRow(InboxRow r) => InboxItem(
        id: r.id,
        text: r.body,
        createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt, isUtc: true).toLocal(),
        fromVoice: r.fromVoice,
      );
}

/// Parses the old SharedPreferences JSON; bad entries are skipped.
List<({String text, DateTime createdAt, bool fromVoice})> decodeLegacyInbox(String? raw) {
  if (raw == null) return const [];
  try {
    final list = jsonDecode(raw);
    if (list is! List) return const [];
    final out = <({String text, DateTime createdAt, bool fromVoice})>[];
    for (final j in list) {
      if (j is! Map) continue;
      final text = j['text'], created = j['createdAt'];
      if (text is! String || created is! String) continue;
      final at = DateTime.tryParse(created);
      if (at == null) continue;
      out.add((text: text, createdAt: at, fromVoice: j['fromVoice'] == true));
    }
    return out;
  } catch (_) {
    return const [];
  }
}
