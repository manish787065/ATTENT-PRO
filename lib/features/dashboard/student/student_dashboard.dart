import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';
import '../../../features/auth/auth_provider.dart';
import '../../../core/constants/app_constants.dart';

class StudentDashboard extends ConsumerStatefulWidget {
  const StudentDashboard({super.key});

  @override
  ConsumerState<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends ConsumerState<StudentDashboard>
    with TickerProviderStateMixin {
  late AnimationController _countController;
  late Animation<double> _countAnimation;
  int _selectedIndex = 0;

  // Demo data — replace with Firestore in production
  final List<Map<String, dynamic>> _subjects = [
    {'name': 'Physics', 'code': 'PHY301', 'attended': 18, 'total': 22},
    {'name': 'Mathematics', 'code': 'MAT201', 'attended': 20, 'total': 22},
    {'name': 'Chemistry', 'code': 'CHE301', 'attended': 12, 'total': 20},
    {'name': 'English', 'code': 'ENG101', 'attended': 15, 'total': 18},
  ];

  @override
  void initState() {
    super.initState();
    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _countAnimation = CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOut,
    );
    _countController.forward();
  }

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  double get _overallPercent {
    int attended = 0, total = 0;
    for (var s in _subjects) {
      attended += s['attended'] as int;
      total += s['total'] as int;
    }
    return total == 0 ? 0 : (attended / total * 100);
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserModelProvider);
    final name = user?.name ?? 'Student';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildTopBar(name),
                      const SizedBox(height: 24),
                      _buildAttendanceRing(),
                      const SizedBox(height: 24),
                      _buildEnrollmentBanner(),
                      const SizedBox(height: 24),
                      Text('Subject Attendance',
                          style: AppTextStyles.titleLarge),
                      const SizedBox(height: 14),
                      ..._subjects.map(_buildSubjectCard),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              _buildBottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good Morning 👋', style: AppTextStyles.bodyMedium),
            Text(name.split(' ').first, style: AppTextStyles.headlineMedium),
          ],
        ),
        GestureDetector(
          onTap: () async {
            await ref.read(authNotifierProvider.notifier).signOut();
            if (mounted) context.go('/');
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_rounded,
                color: Colors.white, size: 26),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceRing() {
    return GlassCard(
      child: Row(
        children: [
          // Ring
          SizedBox(
            width: 120,
            height: 120,
            child: AnimatedBuilder(
              animation: _countAnimation,
              builder: (_, __) {
                final pct = _overallPercent * _countAnimation.value;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    PieChart(
                      PieChartData(
                        startDegreeOffset: -90,
                        sectionsSpace: 0,
                        centerSpaceRadius: 42,
                        sections: [
                          PieChartSectionData(
                            value: pct,
                            color: pct >= AppConstants.minAttendancePercent
                                ? AppColors.primary
                                : AppColors.danger,
                            radius: 14,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: 100 - pct,
                            color: AppColors.surfaceLight,
                            radius: 14,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${pct.toStringAsFixed(0)}%',
                          style: AppTextStyles.titleLarge.copyWith(
                            fontSize: 20,
                            color: pct >= AppConstants.minAttendancePercent
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overall Attendance', style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                Text(
                  _overallPercent >= AppConstants.minAttendancePercent
                      ? '✅ You meet the 75% criteria'
                      : '⚠️ Below 75% threshold!',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _overallPercent >= AppConstants.minAttendancePercent
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${_subjects.fold<int>(0, (s, e) => s + (e['attended'] as int))} / '
                  '${_subjects.fold<int>(0, (s, e) => s + (e['total'] as int))} classes',
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnrollmentBanner() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.face_retouching_natural,
                color: AppColors.secondary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Face Enrollment', style: AppTextStyles.titleMedium),
                Text('Register your face for auto attendance',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push('/student/enroll-face'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppGradients.primaryButton,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Enroll',
                  style: AppTextStyles.labelLarge.copyWith(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    final attended = subject['attended'] as int;
    final total = subject['total'] as int;
    final pct = total == 0 ? 0.0 : attended / total * 100;
    final isGood = pct >= AppConstants.minAttendancePercent;

    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subject['name'], style: AppTextStyles.titleMedium),
                  Text(subject['code'], style: AppTextStyles.bodySmall),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isGood
                      ? AppColors.success.withOpacity(0.15)
                      : AppColors.danger.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isGood
                        ? AppColors.success.withOpacity(0.4)
                        : AppColors.danger.withOpacity(0.4),
                  ),
                ),
                child: Text(
                  '${pct.toStringAsFixed(0)}%',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isGood ? AppColors.success : AppColors.danger,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : attended / total,
              backgroundColor: AppColors.surfaceLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                  isGood ? AppColors.success : AppColors.danger),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text('$attended / $total classes attended',
              style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      (Icons.home_rounded, 'Home'),
      (Icons.qr_code_scanner_rounded, 'QR'),
      (Icons.bar_chart_rounded, 'Reports'),
      (Icons.person_rounded, 'Profile'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (i) {
          final isSelected = _selectedIndex == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedIndex = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppGradients.primaryButton : null,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(items[i].$1,
                      color: isSelected
                          ? Colors.white
                          : AppColors.textSecondary,
                      size: 22),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Text(items[i].$2,
                        style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
