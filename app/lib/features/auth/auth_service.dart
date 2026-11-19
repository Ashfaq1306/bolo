import 'package:firebase_auth/firebase_auth.dart';

/// Anonymous sign-in first (zero friction), then optional email linking that
/// keeps the same UID, so no data has to move (docs/03 § F10).
class AuthService {
  AuthService(this._auth);
  final FirebaseAuth _auth;

  Stream<User?> get userChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  /// Returns the signed-in user, signing in anonymously if needed.
  /// Throws [FirebaseAuthException] when offline on the very first launch.
  Future<User> ensureSignedIn() async {
    final existing = _auth.currentUser;
    if (existing != null) return existing;
    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }

  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  /// Upgrades an anonymous account to email/password, keeping all data.
  Future<void> linkEmail(String email, String password) async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not signed in');
    final credential = EmailAuthProvider.credential(email: email.trim(), password: password);
    await user.linkWithCredential(credential);
  }

  /// Signs in to an existing email account (e.g. on a second phone).
  /// Note: data of the current anonymous account on this phone is not merged.
  Future<void> signInWithEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> signOut() => _auth.signOut();
}
