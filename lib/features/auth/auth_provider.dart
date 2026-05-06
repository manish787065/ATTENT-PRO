import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/user_model.dart';
import '../../core/constants/app_constants.dart';

// ─── Demo Mode Auth (No Firebase needed) ─────────────────────────────────────
// Replace with real Firebase auth after google-services.json is set up

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

// Demo users for testing all 3 roles without Firebase
final Map<String, UserModel> _demoUsers = {
  'student@demo.com': UserModel(
    uid: 'demo-student-001',
    name: 'Rahul Kumar',
    email: 'student@demo.com',
    role: AppConstants.roleStudent,
    institutionId: 'DEMO_COLLEGE',
    parentEmail: 'parent@demo.com',
    createdAt: DateTime.now(),
  ),
  'teacher@demo.com': UserModel(
    uid: 'demo-teacher-001',
    name: 'Prof. Sharma',
    email: 'teacher@demo.com',
    role: AppConstants.roleTeacher,
    institutionId: 'DEMO_COLLEGE',
    createdAt: DateTime.now(),
  ),
  'admin@demo.com': UserModel(
    uid: 'demo-admin-001',
    name: 'Admin Singh',
    email: 'admin@demo.com',
    role: AppConstants.roleAdmin,
    institutionId: 'DEMO_COLLEGE',
    createdAt: DateTime.now(),
  ),
};

final Map<String, String> _demoPasswords = {
  'student@demo.com': 'demo123',
  'teacher@demo.com': 'demo123',
  'admin@demo.com': 'demo123',
};

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final emailKey = email.trim().toLowerCase();
    final user = _demoUsers[emailKey];
    final correctPassword = _demoPasswords[emailKey];

    if (user != null && password == correctPassword) {
      state = state.copyWith(user: user, isLoading: false);
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid credentials. Demo default: student@demo.com / demo123',
      );
    }
  }

  Future<void> register(UserModel newUser, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future.delayed(const Duration(milliseconds: 800));
    
    final emailKey = newUser.email.toLowerCase();
    if (_demoUsers.containsKey(emailKey)) {
      state = state.copyWith(isLoading: false);
      throw Exception('Email already registered!');
    }

    _demoUsers[emailKey] = newUser;
    _demoPasswords[emailKey] = password;
    state = state.copyWith(isLoading: false);
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    state = const AuthState();
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

// Stream provider kept for router compatibility — always null (not logged in) on start
final authStateProvider = StreamProvider<String?>((ref) async* {
  yield null; // Start not logged in
});

// Current user from auth notifier
final currentUserModelProvider = Provider<UserModel?>((ref) {
  return ref.watch(authNotifierProvider).user;
});
