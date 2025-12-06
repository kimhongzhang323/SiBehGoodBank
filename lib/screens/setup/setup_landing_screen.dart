import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/constants.dart';
import '../../widgets/widgets.dart';
import 'personal_info_setup_screen.dart';

/// Professional banking setup landing page
class SetupLandingScreen extends StatelessWidget {
  const SetupLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: HolographicBackground(
        fullScreen: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // Logo and welcome
                _buildHeader(),

                const SizedBox(height: AppSpacing.xxl),

                // Setup steps preview
                Expanded(
                  child: _buildSetupStepsPreview(),
                ),

                // Get started button
                _buildBottomSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bank logo
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.accent,
                AppColors.accentBlue,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance,
            color: Colors.white,
            size: 32,
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        const Text(
          'Welcome to\nSiBeh Good Bank',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        Text(
          'Let\'s set up your account in just a few minutes. We\'ll guide you through each step.',
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSetupStepsPreview() {
    final steps = [
      _SetupStep(
        icon: Icons.person_outline,
        title: 'Personal Information',
        description: 'Basic details and identification',
        isCompleted: false,
        stepNumber: 1,
      ),
      _SetupStep(
        icon: Icons.security,
        title: 'Security Setup',
        description: 'Biometric & authentication options',
        isCompleted: false,
        stepNumber: 2,
      ),
      _SetupStep(
        icon: Icons.key,
        title: 'Passkey Configuration',
        description: 'Alternative device access',
        isCompleted: false,
        stepNumber: 3,
      ),
      _SetupStep(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Account Preferences',
        description: 'Customize your banking experience',
        isCompleted: false,
        stepNumber: 4,
      ),
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What we\'ll set up',
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...steps.map((step) => _buildStepCard(step)),
        ],
      ),
    );
  }

  Widget _buildStepCard(_SetupStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        backgroundColor: Colors.white.withOpacity(0.7),
        child: Row(
          children: [
            // Step number circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.lavender,
                    AppColors.pastelBlue,
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${step.stepNumber}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: AppTextStyles.titleMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.description,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
            // Icon
            Icon(
              step.icon,
              color: AppColors.accent,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Column(
      children: [
        // Time estimate
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: AppColors.positive.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 18,
                color: AppColors.positive,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Takes about 5 minutes',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.positive,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Start button
        PrimaryButton(
          text: 'Start Setup',
          backgroundColor: AppColors.textPrimary,
          textColor: Colors.white,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PersonalInfoSetupScreen(),
              ),
            );
          },
        ),

        const SizedBox(height: AppSpacing.md),

        // Skip option
        TextButton(
          onPressed: () {
            // Show confirmation dialog
            _showSkipDialog(context);
          },
          child: Text(
            'I\'ll do this later',
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  void _showSkipDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: const Text('Skip Setup?'),
        content: const Text(
          'You can complete the setup later, but some features may be limited until you verify your identity and set up security.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Setup'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to home with limited features
            },
            child: Text(
              'Skip for Now',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupStep {
  final IconData icon;
  final String title;
  final String description;
  final bool isCompleted;
  final int stepNumber;

  _SetupStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.stepNumber,
  });
}
