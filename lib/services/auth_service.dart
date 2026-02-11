import 'package:pocket_career_football_puzzle/core/logging/logger.dart';

/// Kullanıcı bilgisi.
class AppUser {
  final String uid;
  final String? displayName;
  final String? email;
  final String? avatarUrl;

  const AppUser({
    required this.uid,
    this.displayName,
    this.email,
    this.avatarUrl,
  });
}

/// Kimlik doğrulama servisi (Firebase Auth).
/// SDK entegrasyonu production'da yapılacak, şimdilik stub.
class AuthService {
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  bool get isSignedIn => _currentUser != null;

  /// Google ile giriş yap.
  Future<AppUser?> signInWithGoogle() async {
    try {
      // TODO: Gerçek Firebase Auth + Google Sign-In
      await Future.delayed(const Duration(seconds: 1));
      _currentUser = const AppUser(
        uid: 'local_user',
        displayName: 'Oyuncu',
      );
      AppLogger.sdk('Firebase Auth', 'Signed in (stub)');
      return _currentUser;
    } catch (e) {
      AppLogger.error('Sign in failed', error: e);
      return null;
    }
  }

  /// Çıkış yap.
  Future<void> signOut() async {
    try {
      // TODO: Gerçek Firebase Auth signOut
      _currentUser = null;
      AppLogger.sdk('Firebase Auth', 'Signed out (stub)');
    } catch (e) {
      AppLogger.error('Sign out failed', error: e);
    }
  }
}
