import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// Trend badge showing percentage change
class TrendBadge extends StatelessWidget {
  final String value;
  final bool isPositive;
  final Color? backgroundColor;
  final Color? textColor;

  const TrendBadge({
    super.key,
    required this.value,
    this.isPositive = true,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ??
            (isPositive
                ? AppColors.positive.withOpacity(0.15)
                : AppColors.negative.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: 12,
            color: textColor ??
                (isPositive ? AppColors.positive : AppColors.negative),
          ),
          const SizedBox(width: 2),
          Text(
            value,
            style: AppTextStyles.labelSmall.copyWith(
              color: textColor ??
                  (isPositive ? AppColors.positive : AppColors.negative),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Category progress item with percentage bar
class CategoryProgressItem extends StatelessWidget {
  final String title;
  final int percentage;
  final Color color;

  const CategoryProgressItem({
    super.key,
    required this.title,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Text(
            '$percentage%',
            style: AppTextStyles.titleMedium,
          ),
        ],
      ),
    );
  }
}

/// Category list with progress items
class CategoryList extends StatelessWidget {
  final List<CategoryProgressItem> items;

  const CategoryList({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items,
    );
  }
}
