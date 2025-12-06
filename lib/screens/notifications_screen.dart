import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';

class NotificationItem {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconColor;
  final bool isRead;
  final NotificationType type;

  const NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
    required this.type,
  });
}

enum NotificationType {
  transaction,
  security,
  promotion,
  reminder,
  alert,
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedTab = 0;
  final List<String> _tabs = ['All', 'Transactions', 'Security', 'Promotions'];

  final List<NotificationItem> _notifications = [
    // Today
    NotificationItem(
      title: 'Transfer Received',
      message: 'You received RM1,260.00 from Sarah Tan. Reference: Family allowance Dec 2025',
      time: '2 mins ago',
      icon: Icons.arrow_downward,
      iconColor: AppColors.positive,
      type: NotificationType.transaction,
    ),
    NotificationItem(
      title: 'Security Alert',
      message: 'New login detected from iPhone 15 Pro in Kuala Lumpur. If this wasn\'t you, please secure your account.',
      time: '35 mins ago',
      icon: Icons.security,
      iconColor: AppColors.negative,
      type: NotificationType.security,
    ),
    NotificationItem(
      title: 'Bill Payment Successful',
      message: 'Your Tenaga Nasional bill of RM245.80 has been paid successfully.',
      time: '1 hour ago',
      icon: Icons.receipt_long,
      iconColor: AppColors.accent,
      type: NotificationType.transaction,
      isRead: true,
    ),
    NotificationItem(
      title: 'Fixed Deposit Maturity',
      message: 'Your FD of RM50,000 will mature in 7 days. Tap to view renewal options.',
      time: '2 hours ago',
      icon: Icons.savings,
      iconColor: const Color(0xFFFFB300),
      type: NotificationType.reminder,
    ),
    // Yesterday
    NotificationItem(
      title: 'Cashback Earned!',
      message: 'You earned RM15.60 cashback from your Grab payment. Total cashback this month: RM89.20',
      time: 'Yesterday, 8:30 PM',
      icon: Icons.card_giftcard,
      iconColor: AppColors.positive,
      type: NotificationType.promotion,
      isRead: true,
    ),
    NotificationItem(
      title: 'Large Transaction Alert',
      message: 'A payment of RM5,500.00 was made to IKEA Malaysia. Please verify this transaction.',
      time: 'Yesterday, 3:45 PM',
      icon: Icons.warning_amber,
      iconColor: const Color(0xFFFF9800),
      type: NotificationType.alert,
      isRead: true,
    ),
    NotificationItem(
      title: 'Salary Credited',
      message: 'Your salary of RM8,500.00 from ABC Corporation has been credited to your account.',
      time: 'Yesterday, 10:00 AM',
      icon: Icons.account_balance_wallet,
      iconColor: AppColors.positive,
      type: NotificationType.transaction,
      isRead: true,
    ),
    // This week
    NotificationItem(
      title: 'New Feature: AI Assistant',
      message: 'Meet SiBeh AI! Your personal finance assistant is now available. Tap to try it out.',
      time: 'Dec 4, 2025',
      icon: Icons.auto_awesome,
      iconColor: AppColors.accent,
      type: NotificationType.promotion,
      isRead: true,
    ),
    NotificationItem(
      title: 'Password Changed',
      message: 'Your account password was successfully changed. If you didn\'t make this change, contact support immediately.',
      time: 'Dec 3, 2025',
      icon: Icons.lock,
      iconColor: AppColors.accentBlue,
      type: NotificationType.security,
      isRead: true,
    ),
    NotificationItem(
      title: 'Investment Update',
      message: 'Your ASB portfolio grew by 2.3% this month! Current value: RM25,680.00',
      time: 'Dec 2, 2025',
      icon: Icons.trending_up,
      iconColor: AppColors.positive,
      type: NotificationType.transaction,
      isRead: true,
    ),
    NotificationItem(
      title: 'Exclusive Offer',
      message: 'Get 5% extra interest on new Fixed Deposits! Limited time offer until Dec 31.',
      time: 'Dec 1, 2025',
      icon: Icons.local_offer,
      iconColor: const Color(0xFFE91E63),
      type: NotificationType.promotion,
      isRead: true,
    ),
    NotificationItem(
      title: 'Family Chain Alert',
      message: 'Unusual spending detected on your monitored account. RM850 at Electronics Store.',
      time: 'Nov 30, 2025',
      icon: Icons.family_restroom,
      iconColor: const Color(0xFFFF9800),
      type: NotificationType.alert,
      isRead: true,
    ),
  ];

  List<NotificationItem> get _filteredNotifications {
    if (_selectedTab == 0) return _notifications;
    
    NotificationType? filterType;
    switch (_selectedTab) {
      case 1:
        filterType = NotificationType.transaction;
        break;
      case 2:
        filterType = NotificationType.security;
        break;
      case 3:
        filterType = NotificationType.promotion;
        break;
    }
    
    if (filterType != null) {
      return _notifications.where((n) => n.type == filterType).toList();
    }
    return _notifications;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: HolographicBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: AppSpacing.md),
              _buildTabs(),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: _buildNotificationsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    
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
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (unreadCount > 0)
                  Text(
                    '$unreadCount unread',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                // Mark all as read
                for (var i = 0; i < _notifications.length; i++) {
                  _notifications[i] = NotificationItem(
                    title: _notifications[i].title,
                    message: _notifications[i].message,
                    time: _notifications[i].time,
                    icon: _notifications[i].icon,
                    iconColor: _notifications[i].iconColor,
                    type: _notifications[i].type,
                    isRead: true,
                  );
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Mark all read',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        children: List.generate(
          _tabs.length,
          (index) => Padding(
            padding: EdgeInsets.only(right: index < _tabs.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedTab == index
                      ? AppColors.accent
                      : Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _selectedTab == index
                        ? Colors.white
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    final filtered = _filteredNotifications;
    
    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final notification = filtered[index];
        final showDateHeader = index == 0 ||
            _getDateHeader(filtered[index - 1].time) !=
                _getDateHeader(notification.time);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader)
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: Text(
                  _getDateHeader(notification.time),
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            _buildNotificationCard(notification),
          ],
        );
      },
    );
  }

  String _getDateHeader(String time) {
    if (time.contains('ago') || time.contains('hour')) {
      return 'Today';
    } else if (time.contains('Yesterday')) {
      return 'Yesterday';
    } else {
      return 'This Week';
    }
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          // Handle notification tap
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.white.withValues(alpha: 0.7)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: notification.isRead
                ? null
                : Border.all(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    width: 1,
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: notification.iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification.icon,
                  color: notification.iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.time,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
