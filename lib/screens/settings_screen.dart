import 'package:flutter/material.dart';
import '../constants/constants.dart';
import 'navbar_customization_screen.dart';

/// Settings screen with options to customize the app.
/// 
/// Currently includes:
/// - Navbar customization
/// - (Placeholder for other settings)
class SettingsScreen extends StatelessWidget {
  final VoidCallback? onBackToHome;
  
  const SettingsScreen({super.key, this.onBackToHome});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: onBackToHome != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: onBackToHome,
              )
            : null,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          const SizedBox(height: AppSpacing.sm),
          
          _SettingsTile(
            icon: Icons.dashboard_customize_outlined,
            title: 'Customize Navigation Bar',
            subtitle: 'Change icons and primary action',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NavbarCustomizationScreen(),
                ),
              );
            },
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Account Section
          _buildSectionHeader('Account'),
          const SizedBox(height: AppSpacing.sm),
          
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Profile',
            subtitle: 'Manage your account details',
            onTap: () => _showComingSoon(context),
          ),
          
          _SettingsTile(
            icon: Icons.security_outlined,
            title: 'Security',
            subtitle: 'Biometrics, PIN, and passwords',
            onTap: () => _showComingSoon(context),
          ),
          
          _SettingsTile(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Push notifications and alerts',
            onTap: () => _showComingSoon(context),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Support Section
          _buildSectionHeader('Support'),
          const SizedBox(height: AppSpacing.sm),
          
          _SettingsTile(
            icon: Icons.help_outline,
            title: 'Help & FAQ',
            subtitle: 'Get answers to common questions',
            onTap: () => _showComingSoon(context),
          ),
          
          _SettingsTile(
            icon: Icons.chat_bubble_outline,
            title: 'Contact Support',
            subtitle: 'Chat with our team',
            onTap: () => _showComingSoon(context),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // About Section
          _buildSectionHeader('About'),
          const SizedBox(height: AppSpacing.sm),
          
          _SettingsTile(
            icon: Icons.info_outline,
            title: 'About SiBeh Good Bank',
            subtitle: 'Version 1.0.0',
            onTap: () => _showComingSoon(context),
          ),
          
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Coming soon!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }
}

/// A single settings tile with icon, title, subtitle, and tap action.
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.cardBackgroundAlt,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, color: AppColors.accent, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppColors.textLight,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }
}
