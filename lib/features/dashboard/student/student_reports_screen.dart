import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_card.dart';

class StudentReportsScreen extends StatefulWidget {
  const StudentReportsScreen({super.key});

  @override
  State<StudentReportsScreen> createState() => _StudentReportsScreenState();
}

class _StudentReportsScreenState extends State<StudentReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedMonth = DateTime.now().month - 1; // 0-indexed

  // Demo data — replace with Firestore in production
  final List<Map<String, dynamic>> _subjects = [
    {'name': 'Physics', 'code': 'PHY301', 'attended': 18, 'total': 22},
    {'name': 'Mathematics', 'code': 'MAT201', 'attended': 20, 'total': 22},
    {'name': 'Chemistry', 'code': 'CHE301', 'attended': 12, 'total': 20},
    {'name': 'English', 'code': 'ENG101', 'attended': 15, 'total': 18},
  ];

  // Demo monthly data
  final List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  final List<double> _monthlyPercent = [
    85, 78, 92, 70, 88, 76, 82, 90, 68, 80, 74, 79
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(Icons.bar_chart_rounded,
                  color: AppColors.primary, size: 28),
              const SizedBox(width: 10),
              Text('Attendance Reports', style: AppTextStyles.headlineMedium),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tab Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: AppGradients.primaryButton,
              borderRadius: BorderRadius.circular(14),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: AppTextStyles.labelLarge.copyWith(fontSize: 13),
            dividerHeight: 0,
            tabs: const [
              Tab(text: 'Subject Wise'),
              Tab(text: 'Month Wise'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Tab views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildSubjectWiseTab(),
              _buildMonthWiseTab(),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Subject Wise Bar Chart ───
  Widget _buildSubjectWiseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Subject-wise Attendance',
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                Text('Attendance percentage per subject',
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: 24),
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${_subjects[group.x.toInt()]['name']}\n${rod.toY.toStringAsFixed(0)}%',
                              AppTextStyles.bodySmall
                                  .copyWith(color: Colors.white, fontSize: 11),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval: 25,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}%',
                                style: AppTextStyles.bodySmall
                                    .copyWith(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= _subjects.length) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _subjects[idx]['code'].toString().substring(0, 3),
                                  style: AppTextStyles.bodySmall
                                      .copyWith(fontSize: 10),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 25,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppColors.glassBorder,
                          strokeWidth: 0.5,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(_subjects.length, (i) {
                        final attended = _subjects[i]['attended'] as int;
                        final total = _subjects[i]['total'] as int;
                        final pct = total == 0 ? 0.0 : attended / total * 100;
                        final isGood = pct >= 75;
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: pct,
                              width: 28,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              gradient: LinearGradient(
                                colors: isGood
                                    ? [AppColors.success, AppColors.primary]
                                    : [AppColors.danger, AppColors.warning],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: 100,
                                color: AppColors.surfaceLight.withOpacity(0.5),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Legend / Details
          Text('Details', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          ...List.generate(_subjects.length, (i) {
            final s = _subjects[i];
            final pct = (s['attended'] as int) / (s['total'] as int) * 100;
            final isGood = pct >= 75;
            return GlassCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: LinearGradient(
                        colors: isGood
                            ? AppColors.successGradient
                            : AppColors.dangerGradient,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s['name'],
                            style: AppTextStyles.titleMedium
                                .copyWith(fontSize: 14)),
                        Text('${s['attended']}/${s['total']} classes',
                            style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isGood
                          ? AppColors.success.withOpacity(0.12)
                          : AppColors.danger.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
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
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ─── Month Wise Bar Chart ───
  Widget _buildMonthWiseTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Month-wise Attendance',
                    style: AppTextStyles.titleMedium),
                const SizedBox(height: 6),
                Text('Your monthly attendance trend',
                    style: AppTextStyles.bodySmall),
                const SizedBox(height: 24),
                SizedBox(
                  height: 220,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${_months[group.x.toInt()]}\n${rod.toY.toStringAsFixed(0)}%',
                              AppTextStyles.bodySmall
                                  .copyWith(color: Colors.white, fontSize: 11),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval: 25,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}%',
                                style: AppTextStyles.bodySmall
                                    .copyWith(fontSize: 10),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= _months.length) {
                                return const SizedBox();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  _months[idx],
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 9,
                                    color: idx == _selectedMonth
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                    fontWeight: idx == _selectedMonth
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 25,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppColors.glassBorder,
                          strokeWidth: 0.5,
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(12, (i) {
                        final pct = _monthlyPercent[i];
                        final isGood = pct >= 75;
                        final isCurrent = i == _selectedMonth;
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: pct,
                              width: isCurrent ? 16 : 10,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                              gradient: LinearGradient(
                                colors: isCurrent
                                    ? [AppColors.primary, AppColors.cyan]
                                    : isGood
                                        ? [
                                            AppColors.success.withOpacity(0.7),
                                            AppColors.success
                                          ]
                                        : [
                                            AppColors.danger.withOpacity(0.7),
                                            AppColors.danger
                                          ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: 100,
                                color: AppColors.surfaceLight.withOpacity(0.3),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 75% threshold indicator
          GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.info_outline_rounded,
                      color: AppColors.warning, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('75% Threshold',
                          style: AppTextStyles.titleMedium
                              .copyWith(fontSize: 14)),
                      Text(
                        'You need minimum 75% attendance to be eligible for exams.',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Monthly stats cards
          Text('Monthly Summary', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('Best Month', 'March', '92%', AppColors.success)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Worst Month', 'September', '68%', AppColors.danger)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('Average', 'Overall', '80%', AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('This Month', _months[_selectedMonth], '${_monthlyPercent[_selectedMonth].toInt()}%', AppColors.cyan)),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String subtitle, String value, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: AppTextStyles.headlineMedium
                  .copyWith(color: color, fontSize: 22)),
          Text(subtitle,
              style: AppTextStyles.bodySmall.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
