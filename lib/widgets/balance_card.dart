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

  const BalanceCard({
    super.key,
    required this.accountType,
    required this.balance,
    this.accountNumber,
    this.backgroundColor,
    this.isOverlapping = false,
    this.width,
  });

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
            color: Colors.black.withOpacity(0.05),
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
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accountType.toLowerCase().contains('checking')
                      ? AppColors.accent
                      : AppColors.positive,
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
              backgroundColor: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
}
