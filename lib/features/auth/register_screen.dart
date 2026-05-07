import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/glass_card.dart';
import '../../shared/widgets/gradient_button.dart';
import '../../shared/services/auth_service.dart';
import '../../shared/models/user_model.dart';
import '../../features/auth/auth_provider.dart';
import '../../core/constants/app_constants.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String role;
  const RegisterScreen({super.key, required this.role});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _institutionController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _parentPhoneController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMsg;

  bool get isStudent => widget.role == AppConstants.roleStudent;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _institutionController.dispose();
    _parentEmailController.dispose();
    _parentPhoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });
    try {
      final notifier = ref.read(authNotifierProvider.notifier);
      
      if (isStudent) {
        await notifier.registerStudent(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          institutionId: _institutionController.text.trim(),
          parentEmail: _parentEmailController.text.trim().isEmpty
              ? null
              : _parentEmailController.text.trim(),
          parentPhone: _parentPhoneController.text.trim().isEmpty
              ? null
              : _parentPhoneController.text.trim(),
        );
      } else {
        await notifier.registerTeacher(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          institutionId: _institutionController.text.trim(),
        );
      }

      // After successful registration, navigate to dashboard
      if (mounted) {
        final user = ref.read(authNotifierProvider).user;
        if (user != null) {
          switch (user.role) {
            case AppConstants.roleAdmin:
              context.go('/admin/dashboard');
            case AppConstants.roleTeacher:
              context.go('/teacher/dashboard');
            default:
              context.go('/student/dashboard');
          }
        }
      }
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('email-already-in-use')) {
        setState(() => _errorMsg = 'This email is already registered');
      } else if (msg.contains('weak-password')) {
        setState(() => _errorMsg = 'Password is too weak');
      } else if (msg.contains('invalid-email')) {
        setState(() => _errorMsg = 'Invalid email format');
      } else {
        setState(() => _errorMsg = 'Registration failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: AppColors.textPrimary),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(height: 16),
                Text(
                  isStudent ? 'Student Registration' : 'Teacher Registration',
                  style: AppTextStyles.displayLarge,
                ),
                const SizedBox(height: 8),
                Text('Create your AttendPro account',
                    style: AppTextStyles.bodyMedium),
                const SizedBox(height: 32),
                GlassCard(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _field(_nameController, 'Full Name', Icons.person_outlined),
                        const SizedBox(height: 14),
                        _field(_emailController, 'Email Address',
                            Icons.email_outlined,
                            type: TextInputType.emailAddress),
                        const SizedBox(height: 14),
                        _passwordField(),
                        const SizedBox(height: 14),
                        _field(_institutionController, 'Institution ID / Code',
                            Icons.business_outlined),
                        if (isStudent) ...[
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Parent Information (Optional)',
                                style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary)),
                          ),
                          const SizedBox(height: 10),
                          _field(_parentEmailController, "Parent's Email",
                              Icons.family_restroom_outlined,
                              type: TextInputType.emailAddress,
                              required: false),
                          const SizedBox(height: 14),
                          _field(_parentPhoneController, "Parent's Phone",
                              Icons.phone_outlined,
                              type: TextInputType.phone,
                              required: false),
                        ],
                        if (_errorMsg != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: AppColors.danger.withOpacity(0.3)),
                            ),
                            child: Text(_errorMsg!,
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.danger)),
                          ),
                        ],
                        const SizedBox(height: 20),
                        GradientButton(
                          label: 'Create Account',
                          isLoading: _isLoading,
                          onPressed: _register,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType type = TextInputType.text,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
      ),
      validator: required
          ? (v) => (v == null || v.isEmpty) ? '$hint is required' : null
          : null,
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Password (min 6 chars)',
        prefixIcon:
            const Icon(Icons.lock_outline, color: AppColors.textSecondary),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: AppColors.textSecondary,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password required';
        if (v.length < 6) return 'Min 6 characters';
        return null;
      },
    );
  }
}
