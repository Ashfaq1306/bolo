import 'dart:math';

import 'bolo_database.dart';

const _idAlphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
final _random = Random.secure();

/// A random 20-character id, the same shape as a Firestore auto-id, so local
/// ids and ids migrated from Firestore look alike. Generated offline.
String newRecordId() =>
    String.fromCharCodes(List.generate(20, (_) => _idAlphabet.codeUnitAt(_random.nextInt(_idAlphabet.length))));

/// Who owns local data on this phone (ADR-11 "device identity").
///
/// Created on the very first launch without any network, and stored in the
/// local database, so it is stable until the app's data is cleared.
class DeviceIdentity {
  const DeviceIdentity(this.deviceId);
  final String deviceId;

  /// `owner_scope` of the guest workspace on this phone.
  String get guestScope => 'device:$deviceId';

  static String accountScope(String uid) => 'account:$uid';

  static Future<DeviceIdentity> load(BoloDatabase db) async {
    final existing = await db.meta(MetaKeys.deviceId);
    if (existing != null && existing.isNotEmpty) return DeviceIdentity(existing);
    final id = newRecordId();
    await db.setMeta(MetaKeys.deviceId, id);
    return DeviceIdentity(id);
  }
}
