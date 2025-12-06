import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// Balance card widget for displaying account balances
class BalanceCard extends StatelessWidget {
  final String accountType;
  final String balance;
  final String? accountNumber;
  final Color? backgroundColor;
  final bool isOverlapping;
  final double? width;
  final Color? indicatorColor;
  final IconData? icon;

  const BalanceCard({
    super.key,
    required this.accountType,
    required this.balance,
    this.accountNumber,
    this.backgroundColor,
    this.isOverlapping = false,
    this.width,
    this.indicatorColor,
    this.icon,
  });

  Color _getIndicatorColor() {
    if (indicatorColor != null) return indicatorColor!;
    final type = accountType.toLowerCase();
    if (type.contains('checking') || type.contains('current')) {
      return AppColors.accent;
    } else if (type.contains('savings')) {
      return AppColors.positive;
    } else if (type.contains('fixed') || type.contains('fd')) {
      return const Color(0xFFFFB300);
    } else if (type.contains('investment') || type.contains('asb')) {
      return AppColors.accentBlue;
    } else if (type.contains('emergency')) {
      return AppColors.negative;
    }
    return AppColors.accent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 200,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.glassWhiteMedium,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null)
                Icon(icon, size: 16, color: _getIndicatorColor())
              else
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getIndicatorColor(),
                    shape: BoxShape.circle,
                  ),
                ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                accountType,
                style: AppTextStyles.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            balance,
            style: AppTextStyles.amountMedium,
          ),
          if (accountNumber != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              accountNumber!,
              style: AppTextStyles.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

/// Overlapping balance cards container
class OverlappingBalanceCards extends StatelessWidget {
  final String checkingBalance;
  final String savingsBalance;

  const OverlappingBalanceCards({
    super.key,
    required this.checkingBalance,
    required this.savingsBalance,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: BalanceCard(
              accountType: 'Checking',
              balance: checkingBalance,
              width: MediaQuery.of(context).size.width * 0.48,
            ),
          ),
          Positioned(
            right: 0,
            top: 20,
            child: BalanceCard(
              accountType: 'Savings',
              balance: savingsBalance,
              width: MediaQuery.of(context).size.width * 0.48,
              backgroundColor: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

/// Account data model for multi-account display
class AccountData {
  final String accountType;
  final String balance;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final String? maturityDate;
  final double? interestRate;

  const AccountData({
    required this.accountType,
    required this.balance,
    required this.icon,
    required this.color,
    this.subtitle,
    this.maturityDate,
    this.interestRate,
  });
}

/// Multi-account horizontal scroll view
class MultiAccountCards extends StatelessWidget {
  final List<AccountData> accounts;
  final VoidCallback? onViewAll;

  const MultiAccountCards({
    super.key,
    required this.accounts,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'My Accounts',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    'View All',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < accounts.length - 1 ? 12 : 0,
                ),
                child: _buildAccountCard(account),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard(AccountData account) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: account.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  account.icon,
                  color: account.color,
                  size: 20,
                ),
              ),
              const Spacer(),
              if (account.interestRate != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.positive.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${account.interestRate}%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.positive,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            account.accountType,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            account.balance,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (account.subtitle != null || account.maturityDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                account.maturityDate ?? account.subtitle ?? '',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textLight,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

