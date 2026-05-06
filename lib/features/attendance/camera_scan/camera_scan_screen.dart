import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/gradient_button.dart';

class CameraScanScreen extends ConsumerStatefulWidget {
  final String subjectId;
  const CameraScanScreen({super.key, required this.subjectId});

  @override
  ConsumerState<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends ConsumerState<CameraScanScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _pulseController;
  late Animation<double> _scanAnimation;
  late Animation<double> _pulseAnimation;

  bool _isScanning = false;
  bool _scanComplete = false;
  int _detectedCount = 0;
  int _totalStudents = 32;

  // Demo detected students — replace with ML Kit + FaceNet results
  final List<Map<String, dynamic>> _detectedStudents = [];

  final List<Map<String, dynamic>> _demoRoster = [
    {'name': 'Rahul Kumar', 'id': 'S001'},
    {'name': 'Priya Sharma', 'id': 'S002'},
    {'name': 'Amit Singh', 'id': 'S003'},
    {'name': 'Neha Gupta', 'id': 'S004'},
    {'name': 'Rohan Patel', 'id': 'S005'},
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scanAnimation = CurvedAnimation(
      parent: _scanController,
      curve: Curves.linear,
    );
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _detectedStudents.clear();
      _detectedCount = 0;
      _scanComplete = false;
    });

    // Simulate progressive detection — replace with real ML Kit pipeline
    for (var student in _demoRoster) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() {
        _detectedStudents.add({
          ...student,
          'confidence': 0.82 + (_detectedStudents.length * 0.02),
          'status': 'present',
        });
        _detectedCount++;
      });
    }

    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isScanning = false;
      _scanComplete = true;
    });
  }

  Future<void> _saveAttendance() async {
    // TODO: Save to Firestore via AttendanceService
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: AppGradients.successCard,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            Text('Attendance Saved!', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              '$_detectedCount students marked present out of $_totalStudents.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Done',
              onPressed: () {
                Navigator.pop(context);
                context.go('/teacher/dashboard');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary),
                      onPressed: () => context.pop(),
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('📷  Physics • CS-A',
                              style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)),
                          Text('Face Recognition Scan',
                              style: TextStyle(
                                  color: AppColors.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              // Camera viewfinder
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Camera mock + overlays
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Camera background placeholder
                              Container(
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0D1117),
                                ),
                                child: const Center(
                                  child: Icon(Icons.videocam_rounded,
                                      color: AppColors.textHint, size: 48),
                                ),
                              ),
                              // Scan line animation
                              if (_isScanning)
                                AnimatedBuilder(
                                  animation: _scanAnimation,
                                  builder: (_, __) {
                                    return Positioned(
                                      top: MediaQuery.of(context).size.height *
                                          0.3 *
                                          _scanAnimation.value,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        height: 2,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.transparent,
                                              AppColors.cyan,
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              // Detected face boxes
                              ..._detectedStudents
                                  .asMap()
                                  .entries
                                  .map((e) => _buildFaceBox(e.key, e.value)),
                              // Corner brackets overlay
                              _buildCornerBrackets(),
                              // Status chip
                              if (_isScanning || _scanComplete)
                                Positioned(
                                  top: 16,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                          color: AppColors.cyan.withOpacity(0.5)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        AnimatedBuilder(
                                          animation: _pulseAnimation,
                                          builder: (_, __) {
                                            return Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.cyan.withOpacity(
                                                    0.5 +
                                                        0.5 *
                                                            _pulseAnimation.value),
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _scanComplete
                                              ? 'Scan Complete'
                                              : 'Scanning...',
                                          style: const TextStyle(
                                              color: AppColors.cyan,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Bottom panel
                      GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Detected',
                                    style: AppTextStyles.bodyMedium),
                                Text(
                                  '$_detectedCount / $_totalStudents students',
                                  style: AppTextStyles.titleMedium.copyWith(
                                      color: AppColors.cyan),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _totalStudents == 0
                                    ? 0
                                    : _detectedCount / _totalStudents,
                                backgroundColor: AppColors.surfaceLight,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.cyan),
                                minHeight: 6,
                              ),
                            ),
                            if (_detectedStudents.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 80,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _detectedStudents.length,
                                  itemBuilder: (_, i) {
                                    final s = _detectedStudents[i];
                                    return Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.success.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: AppColors.success
                                                .withOpacity(0.3)),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.check_circle_rounded,
                                              color: AppColors.success, size: 18),
                                          const SizedBox(height: 4),
                                          Text(
                                            s['name'].toString().split(' ')[0],
                                            style:
                                                AppTextStyles.bodySmall.copyWith(
                                              color: AppColors.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            '${(s['confidence'] * 100).toStringAsFixed(0)}%',
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                    color: AppColors.success),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Action button
                      if (!_scanComplete)
                        GradientButton(
                          label: _isScanning ? 'Scanning...' : 'Start Scan',
                          isLoading: _isScanning,
                          onPressed: _isScanning ? null : _startScan,
                          icon: Icons.camera_alt_rounded,
                        )
                      else
                        GradientButton(
                          label: 'Save Attendance',
                          onPressed: _saveAttendance,
                          icon: Icons.save_rounded,
                          gradient: AppGradients.successCard,
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFaceBox(int index, Map<String, dynamic> student) {
    // Position face boxes in different areas of the viewfinder
    final positions = [
      const Offset(0.2, 0.25), const Offset(0.6, 0.2),
      const Offset(0.4, 0.5), const Offset(0.15, 0.6),
      const Offset(0.7, 0.55),
    ];
    if (index >= positions.length) return const SizedBox.shrink();
    final pos = positions[index];

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: 1.0,
      child: Positioned(
        left: pos.dx * (MediaQuery.of(context).size.width - 40),
        top: pos.dy * 250,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.success, width: 2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(Icons.person_rounded,
                  color: AppColors.success, size: 30),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                student['name'].toString().split(' ')[0],
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerBrackets() {
    return Positioned.fill(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomPaint(painter: _BracketPainter()),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.cyan.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 24.0;
    // Top-left
    canvas.drawLine(Offset.zero, const Offset(len, 0), paint);
    canvas.drawLine(Offset.zero, const Offset(0, len), paint);
    // Top-right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - len, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);
    // Bottom-left
    canvas.drawLine(
        Offset(0, size.height), Offset(len, size.height), paint);
    canvas.drawLine(
        Offset(0, size.height), Offset(0, size.height - len), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width - len, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height),
        Offset(size.width, size.height - len), paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
