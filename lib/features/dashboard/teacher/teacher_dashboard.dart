import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../features/auth/auth_provider.dart';

class TeacherDashboard extends ConsumerStatefulWidget {
  const TeacherDashboard({super.key});

  @override
  ConsumerState<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends ConsumerState<TeacherDashboard> {
  int _selectedIndex = 0;

  // Demo subjects — replace with Firestore
  final List<Map<String, dynamic>> _todayClasses = [
    {
      'subject': 'Physics',
      'code': 'PHY301',
      'time': '09:00 AM',
      'section': 'CS-A',
      'totalStudents': 32,
      'attendanceTaken': false,
      'subjectId': 'phy301',
    },
    {
      'subject': 'Mathematics',
      'code': 'MAT201',
      'time': '11:00 AM',
      'section': 'CS-B',
      'totalStudents': 28,
      'attendanceTaken': true,
      'subjectId': 'mat201',
    },
    {
      'subject': 'Chemistry',
      'code': 'CHE301',
      'time': '02:00 PM',
      'section': 'CS-A',
      'totalStudents': 32,
      'attendanceTaken': false,
      'subjectId': 'che301',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserModelProvider);
    final name = user?.name ?? 'Teacher';

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
                      _buildQuickStats(),
                      const SizedBox(height: 24),
                      Text('Today\'s Classes', style: AppTextStyles.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        _todayDate(),
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 14),
                      ..._todayClasses.map(_buildClassCard),
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

  String _todayDate() {
    final now = DateTime.now();
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Widget _buildTopBar(String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ready to teach? 📚', style: AppTextStyles.bodyMedium),
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

  Widget _buildQuickStats() {
    final pendingCount =
        _todayClasses.where((c) => !(c['attendanceTaken'] as bool)).length;

    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.class_rounded, color: AppColors.primary, size: 28),
                const SizedBox(height: 8),
                Text('${_todayClasses.length}',
                    style: AppTextStyles.headlineMedium),
                Text('Classes Today', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.pending_actions_rounded,
                    color: pendingCount > 0
                        ? AppColors.warning
                        : AppColors.success,
                    size: 28),
                const SizedBox(height: 8),
                Text('$pendingCount',
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: pendingCount > 0
                          ? AppColors.warning
                          : AppColors.success,
                    )),
                Text('Pending', style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassCard(Map<String, dynamic> cls) {
    final done = cls['attendanceTaken'] as bool;
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: done
                  ? AppColors.success.withOpacity(0.15)
                  : AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  done
                      ? Icons.check_circle_rounded
                      : Icons.camera_alt_rounded,
                  color: done ? AppColors.success : AppColors.primary,
                  size: 24,
                ),
                const SizedBox(height: 2),
                Text(
                  cls['time'].toString().split(' ')[0],
                  style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cls['subject'], style: AppTextStyles.titleMedium),
                Text('${cls['code']} • ${cls['section']}',
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Text('${cls['totalStudents']} students',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          if (!done)
            GestureDetector(
              onTap: () =>
                  context.push('/teacher/scan/${cls['subjectId']}'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryButton,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child:
                    const Icon(Icons.play_arrow_rounded, color: Colors.white),
              ),
            )
          else
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Text('Done ✓',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.success)),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      (Icons.home_rounded, 'Home'),
      (Icons.history_rounded, 'History'),
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
