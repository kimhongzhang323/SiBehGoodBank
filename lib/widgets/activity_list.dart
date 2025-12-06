import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// Activity item data model
class ActivityItemData {
  final String title;
  final String subtitle;
  final String amount;
  final bool isPositive;
  final IconData? icon;
  final Color? iconBackgroundColor;

  const ActivityItemData({
    required this.title,
    required this.subtitle,
    required this.amount,
    this.isPositive = false,
    this.icon,
    this.iconBackgroundColor,
  });
}

/// Activity list item widget
class ActivityListItem extends StatelessWidget {
  final ActivityItemData data;
  final VoidCallback? onTap;

  const ActivityListItem({
    super.key,
    required this.data,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 4,
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: AppSpacing.activityIconSize,
              height: AppSpacing.activityIconSize,
              decoration: BoxDecoration(
                color: data.iconBackgroundColor ?? AppColors.accentBlue,
                borderRadius: BorderRadius.circular(AppSpacing.activityIconRadius),
              ),
              child: Icon(
                data.icon ?? Icons.receipt_long_outlined,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Title and subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: AppTextStyles.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Amount
            Text(
              data.isPositive ? '+${data.amount}' : '-${data.amount}',
              style: data.isPositive
                  ? AppTextStyles.amountPositive
                  : AppTextStyles.amountNegative,
            ),
          ],
        ),
      ),
    );
  }
}

/// Activity list with title
class ActivityList extends StatelessWidget {
  final String title;
  final List<ActivityItemData> activities;
  final VoidCallback? onSeeAllTap;

  const ActivityList({
    super.key,
    this.title = 'Recent Activity',
    required this.activities,
    this.onSeeAllTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.headlineSmall),
              if (onSeeAllTap != null)
                TextButton(
                  onPressed: onSeeAllTap,
                  child: Text(
                    'See All',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...activities.map((activity) => ActivityListItem(data: activity)),
      ],
    );
  }
}
