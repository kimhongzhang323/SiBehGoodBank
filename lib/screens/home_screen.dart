import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';
import 'analytics_screen.dart';
import 'ai_chat_screen.dart';

/// Home / Balance Overview screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Holographic header with balance
            _buildHeader(context),

            // Quick action buttons
            _buildQuickActions(context),

            const SizedBox(height: AppSpacing.lg),

            // Recent activity section
            _buildRecentActivity(context),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.holographicGradient,
          stops: AppColors.holographicStops,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with avatar and notification
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://api.dicebear.com/7.x/avataaars/png?seed=banking',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Notification bell
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(
                            Icons.notifications_outlined,
                            color: AppColors.textPrimary,
                            size: 24,
                          ),
                        ),
                        Positioned(
                          top: 10,
                          right: 12,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.negative,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),

              // Total Balance label
              Text(
                'Total Balance',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // Balance amount
              const Text(
                '\$120,544.00',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -1.5,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Balance cards
              const OverlappingBalanceCards(
                checkingBalance: '\$57,311.00',
                savingsBalance: '\$120,544.00',
              ),

              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QuickActionButton(
            icon: Icons.swap_horiz,
            label: 'Transfer',
            iconColor: AppColors.accent,
            onTap: () {
              // Handle transfer
            },
          ),
          QuickActionButton(
            icon: Icons.ac_unit,
            label: 'Freeze',
            iconColor: AppColors.accentBlue,
            onTap: () {
              // Handle freeze
            },
          ),
          QuickActionButton(
            icon: Icons.bar_chart,
            label: 'Analytics',
            iconColor: AppColors.positive,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AnalyticsScreen(),
                ),
              );
            },
          ),
          QuickActionButton(
            icon: Icons.more_horiz,
            label: 'More',
            iconColor: AppColors.textSecondary,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AiChatScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    final activities = [
      ActivityItemData(
        title: 'Slack',
        subtitle: 'Dec 5, 2025 • 2:30 PM',
        amount: '\$327.00',
        isPositive: false,
        icon: Icons.tag,
        iconBackgroundColor: const Color(0xFF4A154B),
      ),
      ActivityItemData(
        title: 'Payroll',
        subtitle: 'Dec 4, 2025 • 9:00 AM',
        amount: '\$72,858.00',
        isPositive: false,
        icon: Icons.people_outline,
        iconBackgroundColor: AppColors.accentBlue,
      ),
      ActivityItemData(
        title: 'Transfer',
        subtitle: 'Dec 3, 2025 • 4:15 PM',
        amount: '\$1,260.00',
        isPositive: true,
        icon: Icons.arrow_downward,
        iconBackgroundColor: AppColors.positive,
      ),
      ActivityItemData(
        title: 'Office Expenses',
        subtitle: 'Dec 2, 2025 • 11:45 AM',
        amount: '\$458.00',
        isPositive: false,
        icon: Icons.business_center_outlined,
        iconBackgroundColor: AppColors.accent,
      ),
      ActivityItemData(
        title: 'Office Expenses',
        subtitle: 'Dec 1, 2025 • 3:20 PM',
        amount: '\$458.00',
        isPositive: false,
        icon: Icons.business_center_outlined,
        iconBackgroundColor: AppColors.accent,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: SolidCard(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: ActivityList(
          title: 'Recent Activity',
          activities: activities,
          onSeeAllTap: () {
            // Navigate to full activity list
          },
        ),
      ),
    );
  }
}
