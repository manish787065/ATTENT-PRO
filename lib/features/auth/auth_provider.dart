import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../shared/models/user_model.dart';
import '../../shared/services/auth_service.dart';
import '../../core/constants/app_constants.dart';

// ─── Auth State ─────────────────────────────────────────────────────────────

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  const AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({UserModel? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ─── Auth Service Provider ──────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ─── Auth Notifier (Real Firebase Auth) ─────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _authService;

  @override
  AuthState build() {
    _authService = ref.read(authServiceProvider);
    // Check if user is already logged in
    _checkCurrentUser();
    return const AuthState();
  }

  Future<void> _checkCurrentUser() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      try {
        final userModel = await _authService.getUserModel(firebaseUser.uid);
        if (userModel != null) {
          state = state.copyWith(user: userModel);
        }
      } catch (e) {
        // Silently fail — user will need to log in again
      }
    }
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final credential = await _authService.signInWithEmail(email, password);
      final uid = credential.user!.uid;

      // Fetch user profile from Firestore
      final userModel = await _authService.getUserModel(uid);

      if (userModel != null) {
        state = state.copyWith(user: userModel, isLoading: false);
      } else {
        // User exists in Firebase Auth but not in Firestore
        // Create a basic user model from Firebase Auth data
        final firebaseUser = credential.user!;
        final fallbackUser = UserModel(
          uid: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? email,
          role: AppConstants.roleStudent, // Default role
          institutionId: 'default',
          createdAt: DateTime.now(),
        );
        state = state.copyWith(user: fallbackUser, isLoading: false);
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.code, // Pass the error code for the UI to translate
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> registerStudent({
    required String name,
    required String email,
    required String password,
    required String institutionId,
    String? parentEmail,
    String? parentPhone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userModel = await _authService.registerStudent(
        name: name,
        email: email,
        password: password,
        institutionId: institutionId,
        parentEmail: parentEmail,
        parentPhone: parentPhone,
      );
      state = state.copyWith(user: userModel, isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.code);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> registerTeacher({
    required String name,
    required String email,
    required String password,
    required String institutionId,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final userModel = await _authService.registerTeacher(
        name: name,
        email: email,
        password: password,
        institutionId: institutionId,
      );
      state = state.copyWith(user: userModel, isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(isLoading: false, error: e.code);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState();
  }
}

// ─── Providers ──────────────────────────────────────────────────────────────

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// Auth state stream from Firebase
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges;
});

// Current user from auth notifier
final currentUserModelProvider = Provider<UserModel?>((ref) {
  return ref.watch(authNotifierProvider).user;
});
