import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/auth_provider.dart';
import '../../features/dashboard/student/student_dashboard.dart';
import '../../features/dashboard/teacher/teacher_dashboard.dart';
import '../../features/dashboard/admin/admin_dashboard.dart';
import '../../features/enrollment/face_enrollment_screen.dart';
import '../../features/attendance/camera_scan/camera_scan_screen.dart';
import '../../shared/widgets/splash_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = authState.user != null;
      final loc = state.matchedLocation;

      if (loc == '/splash') return null;

      final isOnAuth = loc == '/' || loc.startsWith('/register');
      if (!isLoggedIn && !isOnAuth) return '/';
      if (isLoggedIn && isOnAuth) {
        final role = authState.user!.role;
        if (role == 'admin') return '/admin/dashboard';
        if (role == 'teacher') return '/teacher/dashboard';
        return '/student/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, state) => const SplashScreen()),
      GoRoute(path: '/', builder: (_, state) => const LoginScreen()),
      GoRoute(
        path: '/register/:role',
        builder: (_, state) =>
            RegisterScreen(role: state.pathParameters['role']!),
      ),
      // Student
      GoRoute(
          path: '/student/dashboard',
          builder: (_, state) => const StudentDashboard()),
      GoRoute(
          path: '/student/enroll-face',
          builder: (_, state) => const FaceEnrollmentScreen()),
      // Teacher
      GoRoute(
          path: '/teacher/dashboard',
          builder: (_, state) => const TeacherDashboard()),
      GoRoute(
        path: '/teacher/scan/:subjectId',
        builder: (_, state) =>
            CameraScanScreen(subjectId: state.pathParameters['subjectId']!),
      ),
      // Admin
      GoRoute(
          path: '/admin/dashboard',
          builder: (_, state) => const AdminDashboard()),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      body: Center(
        child: Text(
          'Page not found',
          style: const TextStyle(color: Colors.white),
        ),
      ),
    ),
  );
});
