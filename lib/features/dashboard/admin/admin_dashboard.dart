import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../features/auth/auth_provider.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserModelProvider);
    final name = user?.name ?? 'Admin';

    // Demo data
    final atRisk = [
      {'name': 'Rahul Kumar', 'pct': 68.0, 'subject': 'Physics'},
      {'name': 'Priya Singh', 'pct': 71.0, 'subject': 'Chemistry'},
      {'name': 'Amit Sharma', 'pct': 60.0, 'subject': 'Mathematics'},
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Admin Panel 🛡️',
                            style: AppTextStyles.bodyMedium),
                        Text(name.split(' ').first,
                            style: AppTextStyles.headlineMedium),
                      ],
                    ),
                    GestureDetector(
                      onTap: () async {
                        await ref
                            .read(authNotifierProvider.notifier)
                            .signOut();
                        if (context.mounted) context.go('/');
                      },
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary]),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.admin_panel_settings_rounded,
                            color: Colors.white, size: 26),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Stats row
                Row(
                  children: [
                    _statCard('245', 'Students', Icons.school_rounded,
                        AppColors.primary),
                    const SizedBox(width: 12),
                    _statCard('18', 'Teachers', Icons.person_rounded,
                        AppColors.secondary),
                    const SizedBox(width: 12),
                    _statCard('12', 'Subjects', Icons.book_rounded,
                        AppColors.cyan),
                  ],
                ),
                const SizedBox(height: 24),
                // At-risk students
                GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: AppColors.warning),
                          const SizedBox(width: 8),
                          Text('At-Risk Students',
                              style: AppTextStyles.titleMedium),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('${atRisk.length} students',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.danger)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...atRisk.map((s) => _atRiskRow(s)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Quick actions
                Text('Quick Actions', style: AppTextStyles.titleLarge),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                        child: _actionCard('Add Subject',
                            Icons.add_circle_outline_rounded, AppColors.primary,
                            onTap: () {})),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _actionCard('Manage Users',
                            Icons.people_outline_rounded, AppColors.secondary,
                            onTap: () {})),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                        child: _actionCard('View Reports',
                            Icons.bar_chart_rounded, AppColors.cyan,
                            onTap: () {})),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _actionCard(
                            'Holidays', Icons.event_rounded, AppColors.warning,
                            onTap: () {})),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statCard(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value,
                style: AppTextStyles.titleLarge.copyWith(color: color)),
            Text(label, style: AppTextStyles.bodySmall, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _atRiskRow(Map<String, dynamic> s) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.person_outlined,
                color: AppColors.danger, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['name'], style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                Text(s['subject'], style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.danger.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.danger.withOpacity(0.3)),
            ),
            child: Text('${s['pct']}%',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(String label, IconData icon, Color color,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
