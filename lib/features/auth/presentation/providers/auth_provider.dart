import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/repositories/auth_repository.dart';

class AuthState {
  final UserData? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    UserData? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userData = await _repository.login(email, password);
      
      if (userData == null) {
        state = state.copyWith(
          isLoading: false, 
          error: 'Data user tidak ditemukan di database'
        );
        return;
      }

      if (!userData.isVerified && userData.role == UserRole.karyawan) {
        await _repository.logout();
        state = state.copyWith(
          isLoading: false,
          error: 'Akun Anda belum diverifikasi oleh Admin',
        );
        return;
      }

      state = state.copyWith(user: userData, isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getMessageFromErrorCode(e.code),
      );
    } catch (e) {
      // Tampilkan error asli untuk debugging di tahap ini
      state = state.copyWith(
        isLoading: false,
        error: 'Sistem Error: $e',
      );
    }
  }

  Future<void> register(UserData userData) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.register(userData);
      state = state.copyWith(
        isLoading: false,
        error: 'Registrasi berhasil. Mohon tunggu verifikasi admin.',
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getMessageFromErrorCode(e.code),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal melakukan registrasi',
      );
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _repository.sendPasswordResetEmail(email);
      state = state.copyWith(
        isLoading: false,
        error: 'Link reset password telah dikirim ke email Anda.',
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getMessageFromErrorCode(e.code),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Gagal mengirim email reset password.',
      );
    }
  }

  String _getMessageFromErrorCode(String errorCode) {
    switch (errorCode) {
      case "invalid-email":
        return "Format email salah.";
      case "wrong-password":
        return "Password salah.";
      case "user-not-found":
        return "User tidak ditemukan.";
      case "user-disabled":
        return "User telah dinonaktifkan.";
      case "too-many-requests":
        return "Terlalu banyak request. Coba lagi nanti.";
      case "operation-not-allowed":
        return "Login dengan email & password tidak diaktifkan.";
      case "email-already-in-use":
        return "Email sudah terdaftar.";
      case "weak-password":
        return "Password terlalu lemah.";
      case "api-not-available":
        return "Google Play Services tidak tersedia.";
      case "internal-error":
        return "Terjadi kesalahan internal, periksa konfigurasi SHA-1.";
      default:
        return "Login gagal. Silakan coba lagi.";
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
