import 'package:flutter/material.dart';

/// Represents a single quick action that can appear in the bottom navigation bar.
/// 
/// Each quick action has:
/// - A unique [id] for identification and persistence
/// - A display [label] for UI
/// - [icon] and [selectedIcon] for visual representation
/// - A [route] for navigation
/// - An [order] for default sorting
enum QuickActionType {
  transfer,
  contacts,
  scanQr,
  accounts,
  family,
  cards,
  bills,
  topUp,
  analytics,
  rewards,
  support,
  home,
  ai,
}

/// Model representing a quick action available in the banking app.
/// 
/// This is the core data model for navbar items. Each action can be
/// placed in the navbar and optionally set as the primary (center) action.
class QuickAction {
  /// Unique identifier for this action
  final QuickActionType type;
  
  /// Display label shown below the icon
  final String label;
  
  /// Icon shown when item is not selected
  final IconData icon;
  
  /// Icon shown when item is selected (typically filled variant)
  final IconData selectedIcon;
  
  /// Navigation route for this action
  final String route;
  
  /// Default order priority (lower = higher priority)
  final int defaultOrder;
  
  /// Whether this action can be set as primary (center) action
  final bool canBePrimary;

  const QuickAction({
    required this.type,
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.route,
    required this.defaultOrder,
    this.canBePrimary = true,
  });

  /// Converts the action to a JSON map for persistence
  Map<String, dynamic> toJson() => {
    'type': type.name,
    'label': label,
    'route': route,
    'defaultOrder': defaultOrder,
    'canBePrimary': canBePrimary,
  };

  /// Creates a QuickAction from a JSON map
  factory QuickAction.fromJson(Map<String, dynamic> json) {
    final type = QuickActionType.values.firstWhere(
      (t) => t.name == json['type'],
    );
    return allActions.firstWhere((a) => a.type == type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuickAction &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'QuickAction($type)';
}

/// All available quick actions in the banking app.
/// 
/// These are the complete set of features users can add to their navbar.
/// Modeled after modern e-wallet/banking apps like Touch 'n Go, GrabPay, etc.
const List<QuickAction> allActions = [
  QuickAction(
    type: QuickActionType.home,
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_rounded,
    route: '/home',
    defaultOrder: 0,
    canBePrimary: false, // Home should stay as regular nav item
  ),
  QuickAction(
    type: QuickActionType.transfer,
    label: 'Transfer',
    icon: Icons.swap_horiz_outlined,
    selectedIcon: Icons.swap_horiz,
    route: '/transfer',
    defaultOrder: 1,
  ),
  QuickAction(
    type: QuickActionType.contacts,
    label: 'Contacts',
    icon: Icons.contacts_outlined,
    selectedIcon: Icons.contacts,
    route: '/contacts',
    defaultOrder: 2,
  ),
  QuickAction(
    type: QuickActionType.scanQr,
    label: 'Scan QR',
    icon: Icons.qr_code_scanner_outlined,
    selectedIcon: Icons.qr_code_scanner,
    route: '/scan',
    defaultOrder: 3,
  ),
  QuickAction(
    type: QuickActionType.accounts,
    label: 'Accounts',
    icon: Icons.account_balance_outlined,
    selectedIcon: Icons.account_balance,
    route: '/accounts',
    defaultOrder: 4,
  ),
  QuickAction(
    type: QuickActionType.family,
    label: 'Family',
    icon: Icons.family_restroom_outlined,
    selectedIcon: Icons.family_restroom,
    route: '/family',
    defaultOrder: 5,
  ),
  QuickAction(
    type: QuickActionType.cards,
    label: 'Cards',
    icon: Icons.credit_card_outlined,
    selectedIcon: Icons.credit_card,
    route: '/cards',
    defaultOrder: 6,
  ),
  QuickAction(
    type: QuickActionType.bills,
    label: 'Bills',
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
    route: '/bills',
    defaultOrder: 7,
  ),
  QuickAction(
    type: QuickActionType.topUp,
    label: 'Top-up',
    icon: Icons.add_circle_outline,
    selectedIcon: Icons.add_circle,
    route: '/topup',
    defaultOrder: 8,
  ),
  QuickAction(
    type: QuickActionType.analytics,
    label: 'Analytics',
    icon: Icons.bar_chart_outlined,
    selectedIcon: Icons.bar_chart,
    route: '/analytics',
    defaultOrder: 9,
  ),
  QuickAction(
    type: QuickActionType.rewards,
    label: 'Rewards',
    icon: Icons.card_giftcard_outlined,
    selectedIcon: Icons.card_giftcard,
    route: '/rewards',
    defaultOrder: 10,
  ),
  QuickAction(
    type: QuickActionType.support,
    label: 'Support',
    icon: Icons.support_agent_outlined,
    selectedIcon: Icons.support_agent,
    route: '/support',
    defaultOrder: 11,
  ),
  QuickAction(
    type: QuickActionType.ai,
    label: 'AI',
    icon: Icons.auto_awesome_outlined,
    selectedIcon: Icons.auto_awesome,
    route: '/ai',
    defaultOrder: 12,
  ),
];

/// Helper to get a QuickAction by its type
QuickAction getActionByType(QuickActionType type) {
  return allActions.firstWhere((a) => a.type == type);
}
