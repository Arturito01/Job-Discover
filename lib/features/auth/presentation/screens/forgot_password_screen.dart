import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/theme.dart';
import '../../providers/auth_provider.dart';
import '../widgets/auth_text_field.dart';

/// Forgot password screen
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authProvider.notifier)
        .requestPasswordReset(_emailController.text.trim());

    if (success && mounted) {
      setState(() => _emailSent = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _emailSent ? _buildSuccessContent() : _buildFormContent(authState),
        ),
      ),
    );
  }

  Widget _buildFormContent(AuthState authState) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),

          const Gap.lg(),

          // Title
          Text(
            'Reset Password',
            style: AppTypography.displayLarge,
          ),

          const Gap.xs(),

          Text(
            'Enter your email address and we\'ll send you instructions to reset your password.',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const Gap.xl(),

          // Error message
          if (authState.error != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.error.withValues(alpha:0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const Gap.xs(),
                  Expanded(
                    child: Text(
                      authState.error!,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
            const Gap.md(),
          ],

          // Email field
          AuthTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icons.email_outlined,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleResetPassword(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email is required';
              }
              if (!value.contains('@')) {
                return 'Enter a valid email';
              }
              return null;
            },
          ),

          const Gap.xl(),

          // Reset button
          ElevatedButton(
            onPressed: authState.isLoading ? null : _handleResetPassword,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: authState.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(
                    'Send Reset Link',
                    style: AppTypography.labelLarge.copyWith(color: Colors.white),
                  ),
          ),

          const Gap.lg(),

          // Back to login
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Back to Sign In',
              style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha:0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 40,
            color: AppColors.success,
          ),
        ),

        const Gap.lg(),

        // Title
        Text(
          'Check Your Email',
          style: AppTypography.displayLarge,
        ),

        const Gap.xs(),

        Text(
          'We\'ve sent password reset instructions to:',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),

        const Gap.sm(),

        Text(
          _emailController.text,
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.primary,
          ),
        ),

        const Gap.xl(),

        // Info box
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_outline, size: 20, color: AppColors.textSecondary),
                  const Gap.xs(),
                  Text(
                    'Didn\'t receive the email?',
                    style: AppTypography.titleSmall,
                  ),
                ],
              ),
              const Gap.xs(),
              Text(
                '• Check your spam folder\n• Make sure the email address is correct\n• Wait a few minutes and try again',
                style: AppTypography.bodyMedium,
              ),
            ],
          ),
        ),

        const Gap.xl(),

        // Resend button
        OutlinedButton(
          onPressed: () {
            setState(() => _emailSent = false);
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
          child: const Text('Try Different Email'),
        ),

        const Gap.md(),

        // Back to login
        ElevatedButton(
          onPressed: () => context.go('/login'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
          child: Text(
            'Back to Sign In',
            style: AppTypography.labelLarge.copyWith(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
