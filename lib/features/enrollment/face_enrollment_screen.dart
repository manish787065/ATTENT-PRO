import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';

class FaceEnrollmentScreen extends ConsumerStatefulWidget {
  const FaceEnrollmentScreen({super.key});

  @override
  ConsumerState<FaceEnrollmentScreen> createState() =>
      _FaceEnrollmentScreenState();
}

class _FaceEnrollmentScreenState extends ConsumerState<FaceEnrollmentScreen>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _checkController;

  final List<Map<String, dynamic>> _steps = [
    {'instruction': 'Look straight at the camera', 'icon': Icons.face_rounded},
    {'instruction': 'Turn your head slightly left', 'icon': Icons.arrow_back_rounded},
    {'instruction': 'Turn your head slightly right', 'icon': Icons.arrow_forward_rounded},
    {'instruction': 'Tilt your head up slightly', 'icon': Icons.arrow_upward_rounded},
    {'instruction': 'Smile naturally 😊', 'icon': Icons.sentiment_satisfied_alt_rounded},
  ];

  final List<bool> _captured = [false, false, false, false, false];
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  Future<void> _captureStep() async {
    setState(() => _isCapturing = true);
    // Simulate capture delay — replace with actual camera capture + FaceNet
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      _captured[_currentStep] = true;
      _isCapturing = false;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
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
            Text('Face Enrolled!', style: AppTextStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Your face has been successfully registered. You will now be automatically marked present.',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            GradientButton(
              label: 'Back to Dashboard',
              onPressed: () {
                Navigator.pop(context);
                context.go('/student/dashboard');
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
              const SizedBox(height: 16),
              // Back button + title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.textPrimary),
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(width: 8),
                    Text('Face Enrollment', style: AppTextStyles.titleLarge),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Step indicator
              _buildStepIndicator(),
              const SizedBox(height: 8),
              Text(
                'Step ${_currentStep + 1} of ${_steps.length}',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 32),
              // Camera circle
              _buildCameraCircle(),
              const SizedBox(height: 24),
              // Instruction
              Text(
                _steps[_currentStep]['instruction'],
                style: AppTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _isCapturing ? 'Capturing...' : 'Hold still and press Capture',
                style: AppTextStyles.bodyMedium,
              ),
              const Spacer(),
              // Tips card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.tips_and_updates_rounded,
                          color: AppColors.warning, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ensure good lighting • Remove glasses • Face camera directly',
                          style: AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Capture button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GradientButton(
                  label: _isCapturing ? 'Capturing...' : 'Capture',
                  isLoading: _isCapturing,
                  onPressed: _isCapturing ? null : _captureStep,
                  icon: Icons.camera_alt_rounded,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_steps.length, (i) {
        final isDone = _captured[i];
        final isCurrent = i == _currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isCurrent ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            gradient: isCurrent || isDone ? AppGradients.primaryButton : null,
            color: isCurrent || isDone ? null : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(6),
          ),
          child: isDone && !isCurrent
              ? const Icon(Icons.check, color: Colors.white, size: 8)
              : null,
        );
      }),
    );
  }

  Widget _buildCameraCircle() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (_, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse ring
              Container(
                width: 220 + 20 * _pulseAnimation.value,
                height: 220 + 20 * _pulseAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary
                        .withOpacity(0.15 + 0.15 * _pulseAnimation.value),
                    width: 2,
                  ),
                ),
              ),
              // Middle ring
              Container(
                width: 210,
                height: 210,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.5),
                    width: 2,
                  ),
                ),
              ),
              // Camera preview placeholder
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.surface, AppColors.surfaceLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: _captured[_currentStep]
                        ? AppColors.success
                        : AppColors.primary,
                    width: 3,
                  ),
                ),
                child: _captured[_currentStep]
                    ? const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 60)
                    : Icon(
                        _steps[_currentStep]['icon'],
                        color: AppColors.primary.withOpacity(0.6),
                        size: 60,
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
