import 'package:flutter/material.dart';
import '../../constants/constants.dart';
import '../../widgets/widgets.dart';
import '../root_shell.dart';

/// Account preferences screen - final step in setup
class AccountPreferencesScreen extends StatefulWidget {
  const AccountPreferencesScreen({super.key});

  @override
  State<AccountPreferencesScreen> createState() =>
      _AccountPreferencesScreenState();
}

class _AccountPreferencesScreenState extends State<AccountPreferencesScreen> {
  // Notification preferences
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsAlerts = false;

  // Transaction alerts
  bool _largeTransactionAlerts = true;
  double _largeTransactionThreshold = 500;

  // Privacy preferences
  bool _hideBalance = false;
  bool _showTransactionPreviews = true;

  // Account type
  AccountType _selectedAccountType = AccountType.personal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            _buildProgressIndicator(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.screenPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppSpacing.xl),

                    // Account type selection
                    _buildAccountTypeSection(),
                    const SizedBox(height: AppSpacing.xl),

                    // Notification preferences
                    _buildNotificationSection(),
                    const SizedBox(height: AppSpacing.xl),

                    // Transaction alerts
                    _buildTransactionAlertsSection(),
                    const SizedBox(height: AppSpacing.xl),

                    // Privacy preferences
                    _buildPrivacySection(),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            // Bottom button
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.cardBackground,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            size: 16,
            color: AppColors.textPrimary,
          ),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Preferences',
        style: AppTextStyles.headlineSmall,
      ),
      centerTitle: true,
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Step 5 of 5',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '100%',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.positive,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          LinearProgressIndicator(
            value: 1.0,
            backgroundColor: AppColors.lavender.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.positive),
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Settings icon
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.positive.withOpacity(0.2),
                AppColors.accentBlue.withOpacity(0.2),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.tune,
            color: AppColors.positive,
            size: 32,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Customize Your\nBanking Experience',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Set your preferences for notifications, alerts, and privacy. You can change these anytime in settings.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Type',
          style: AppTextStyles.titleLarge,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildAccountTypeCard(
                type: AccountType.personal,
                icon: Icons.person_outline,
                title: 'Personal',
                description: 'For individual use',
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildAccountTypeCard(
                type: AccountType.business,
                icon: Icons.business_center_outlined,
                title: 'Business',
                description: 'For your company',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountTypeCard({
    required AccountType type,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedAccountType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAccountType = type;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.accent.withOpacity(0.1)
                    : AppColors.lavender.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTextStyles.titleMedium.copyWith(
                color:
                    isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
            Text(
              description,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return _buildSettingsSection(
      title: 'Notifications',
      children: [
        _buildToggleItem(
          icon: Icons.notifications_outlined,
          title: 'Push Notifications',
          subtitle: 'Get instant alerts on your device',
          value: _pushNotifications,
          onChanged: (value) {
            setState(() {
              _pushNotifications = value;
            });
          },
        ),
        _buildToggleItem(
          icon: Icons.email_outlined,
          title: 'Email Notifications',
          subtitle: 'Receive updates via email',
          value: _emailNotifications,
          onChanged: (value) {
            setState(() {
              _emailNotifications = value;
            });
          },
        ),
        _buildToggleItem(
          icon: Icons.sms_outlined,
          title: 'SMS Alerts',
          subtitle: 'Important alerts via text message',
          value: _smsAlerts,
          onChanged: (value) {
            setState(() {
              _smsAlerts = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTransactionAlertsSection() {
    return _buildSettingsSection(
      title: 'Transaction Alerts',
      children: [
        _buildToggleItem(
          icon: Icons.warning_amber_outlined,
          title: 'Large Transaction Alerts',
          subtitle: 'Notify for transactions above threshold',
          value: _largeTransactionAlerts,
          onChanged: (value) {
            setState(() {
              _largeTransactionAlerts = value;
            });
          },
        ),
        if (_largeTransactionAlerts) ...[
          const SizedBox(height: AppSpacing.md),
          _buildSliderItem(),
        ],
      ],
    );
  }

  Widget _buildSliderItem() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.lavender.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alert Threshold',
                style: AppTextStyles.labelMedium,
              ),
              Text(
                '\$${_largeTransactionThreshold.toStringAsFixed(0)}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Slider(
            value: _largeTransactionThreshold,
            min: 100,
            max: 5000,
            divisions: 49,
            activeColor: AppColors.accent,
            inactiveColor: AppColors.glassBorder,
            onChanged: (value) {
              setState(() {
                _largeTransactionThreshold = value;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$100', style: AppTextStyles.labelSmall),
              Text('\$5,000', style: AppTextStyles.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return _buildSettingsSection(
      title: 'Privacy & Display',
      children: [
        _buildToggleItem(
          icon: Icons.visibility_off_outlined,
          title: 'Hide Balance',
          subtitle: 'Mask balance on home screen',
          value: _hideBalance,
          onChanged: (value) {
            setState(() {
              _hideBalance = value;
            });
          },
        ),
        _buildToggleItem(
          icon: Icons.preview_outlined,
          title: 'Transaction Previews',
          subtitle: 'Show details in notifications',
          value: _showTransactionPreviews,
          onChanged: (value) {
            setState(() {
              _showTransactionPreviews = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.titleLarge),
        const SizedBox(height: AppSpacing.md),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.lavender.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.titleMedium),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: PrimaryButton(
        text: 'Complete Setup',
        backgroundColor: AppColors.positive,
        textColor: Colors.white,
        onPressed: () => _showCompletionDialog(),
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success animation
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.positive.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.positive,
                  size: 48,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'You\'re All Set! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your account has been successfully set up. Welcome to SiBeh Good Bank!',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                text: 'Start Banking',
                backgroundColor: AppColors.textPrimary,
                textColor: Colors.white,
                onPressed: () {
                  // Navigate to RootShell (with navbar) and clear stack
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const RootShell(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum AccountType {
  personal,
  business,
}
