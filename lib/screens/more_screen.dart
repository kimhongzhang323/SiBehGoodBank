import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';
import 'fixed_deposit_screen.dart';
import 'tabung_screen.dart';
import 'goal_investment_screen.dart';
import 'physical_cards_screen.dart';
import 'biometric_atm_screen.dart';

/// More screen showing additional banking features
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: HolographicBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Savings & Investments'),
                      const SizedBox(height: AppSpacing.md),
                      _buildFeatureGrid(context, [
                        _FeatureItem(
                          icon: Icons.account_balance,
                          label: 'Fixed Deposit',
                          color: const Color(0xFF6C63FF),
                          description: 'Grow your savings with competitive rates',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FixedDepositScreen(),
                            ),
                          ),
                        ),
                        _FeatureItem(
                          icon: Icons.savings,
                          label: 'Tabung',
                          color: const Color(0xFF4CAF50),
                          description: 'Set monthly savings goals',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const TabungScreen(),
                            ),
                          ),
                        ),
                        _FeatureItem(
                          icon: Icons.trending_up,
                          label: 'Goal Investment',
                          color: const Color(0xFFFF9800),
                          description: 'Invest towards your dreams',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const GoalInvestmentScreen(),
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.xl),
                      _buildSectionTitle('Cards & Access'),
                      const SizedBox(height: AppSpacing.md),
                      _buildFeatureGrid(context, [
                        _FeatureItem(
                          icon: Icons.credit_card,
                          label: 'Physical Cards',
                          color: const Color(0xFFE91E63),
                          description: 'Apply for debit/credit cards',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PhysicalCardsScreen(),
                            ),
                          ),
                        ),
                        _FeatureItem(
                          icon: Icons.fingerprint,
                          label: 'Biometric ATM',
                          color: const Color(0xFF00BCD4),
                          description: 'Cardless ATM withdrawal',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BiometricAtmScreen(),
                            ),
                          ),
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.xl),
                      _buildSectionTitle('More Services'),
                      const SizedBox(height: AppSpacing.md),
                      _buildFeatureGrid(context, [
                        _FeatureItem(
                          icon: Icons.receipt_long,
                          label: 'e-Statements',
                          color: const Color(0xFF9C27B0),
                          description: 'View & download statements',
                          onTap: () => _showComingSoon(context),
                        ),
                        _FeatureItem(
                          icon: Icons.local_offer,
                          label: 'Promotions',
                          color: const Color(0xFFFF5722),
                          description: 'Exclusive deals & offers',
                          onTap: () => _showComingSoon(context),
                        ),
                        _FeatureItem(
                          icon: Icons.currency_exchange,
                          label: 'Forex',
                          color: const Color(0xFF3F51B5),
                          description: 'Currency exchange',
                          onTap: () => _showComingSoon(context),
                        ),
                      ]),
                      const SizedBox(height: AppSpacing.xl),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Text(
              'More Services',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildFeatureGrid(BuildContext context, List<_FeatureItem> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.0,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildFeatureCard(context, items[index]),
    );
  }

  Widget _buildFeatureCard(BuildContext context, _FeatureItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: item.color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.icon, color: item.color, size: 24),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                item.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Coming Soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: AppColors.accent,
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String label;
  final Color color;
  final String description;
  final VoidCallback onTap;

  _FeatureItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.description,
    required this.onTap,
  });
}
