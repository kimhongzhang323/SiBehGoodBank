import 'dart:convert';
import 'quick_action.dart';

/// Configuration model for the user's customized bottom navigation bar.
/// 
/// This model:
/// - Stores which quick actions the user has selected (max 5)
/// - Tracks which item is the primary (center) action
/// - Provides validation to ensure constraints are met
/// - Supports JSON serialization for persistence
class UserNavbarConfig {
  /// Maximum number of items allowed in the navbar
  static const int maxItems = 5;
  
  /// Minimum number of items required
  static const int minItems = 3;

  /// List of selected quick action types in display order.
  /// The primary action should be at index 2 (center position).
  final List<QuickActionType> selectedItems;
  
  /// The type of the primary (center) action
  final QuickActionType primaryAction;
  
  /// Timestamp of last modification (for sync purposes)
  final DateTime? lastModified;

  const UserNavbarConfig({
    required this.selectedItems,
    required this.primaryAction,
    this.lastModified,
  });

  /// Default configuration for new users
  factory UserNavbarConfig.defaultConfig() {
    return UserNavbarConfig(
      selectedItems: [
        QuickActionType.home,
        QuickActionType.analytics,
        QuickActionType.scanQr, // Primary action (center)
        QuickActionType.ai,
        QuickActionType.settings,
      ],
      primaryAction: QuickActionType.scanQr,
      lastModified: DateTime.now(),
    );
  }

  /// Validates the configuration
  /// Returns null if valid, or an error message if invalid
  String? validate() {
    // Check item count
    if (selectedItems.length < minItems) {
      return 'Please select at least $minItems items';
    }
    if (selectedItems.length > maxItems) {
      return 'Maximum $maxItems items allowed';
    }
    
    // Check for duplicates
    if (selectedItems.toSet().length != selectedItems.length) {
      return 'Duplicate items are not allowed';
    }
    
    // Check primary action is in selected items
    if (!selectedItems.contains(primaryAction)) {
      return 'Primary action must be one of the selected items';
    }
    
    // Check primary action is allowed to be primary
    final primaryQuickAction = getActionByType(primaryAction);
    if (!primaryQuickAction.canBePrimary) {
      return '${primaryQuickAction.label} cannot be set as primary action';
    }
    
    return null; // Valid
  }

  /// Returns true if the configuration is valid
  bool get isValid => validate() == null;

  /// Gets the list of QuickAction objects in order
  List<QuickAction> get actions =>
      selectedItems.map((type) => getActionByType(type)).toList();

  /// Gets the index of the primary action in the selected items
  int get primaryActionIndex => selectedItems.indexOf(primaryAction);

  /// Gets the QuickAction for the primary action
  QuickAction get primaryQuickAction => getActionByType(primaryAction);

  /// Creates a copy with modified fields
  UserNavbarConfig copyWith({
    List<QuickActionType>? selectedItems,
    QuickActionType? primaryAction,
    DateTime? lastModified,
  }) {
    return UserNavbarConfig(
      selectedItems: selectedItems ?? this.selectedItems,
      primaryAction: primaryAction ?? this.primaryAction,
      lastModified: lastModified ?? DateTime.now(),
    );
  }

  /// Returns items in navbar order with primary action at center
  /// This reorders items so the primary action is always in the middle
  /// Only applies to odd item counts (3, 5)
  List<QuickAction> get orderedActionsWithPrimaryCenter {
    final isOddCount = selectedItems.length % 2 == 1;
    
    if (!isOddCount) {
      // For even counts, no center button - return as-is
      return actions;
    }
    
    final items = List<QuickAction>.from(actions);
    final primaryIdx = primaryActionIndex;
    final centerIdx = selectedItems.length ~/ 2; // Center for any odd count
    
    if (primaryIdx >= 0 && primaryIdx != centerIdx) {
      // Swap primary to center
      final temp = items[centerIdx];
      items[centerIdx] = items[primaryIdx];
      items[primaryIdx] = temp;
    }
    
    return items;
  }

  /// Converts to JSON for persistence
  Map<String, dynamic> toJson() => {
    'selectedItems': selectedItems.map((t) => t.name).toList(),
    'primaryAction': primaryAction.name,
    'lastModified': lastModified?.toIso8601String(),
  };

  /// Creates from JSON
  factory UserNavbarConfig.fromJson(Map<String, dynamic> json) {
    return UserNavbarConfig(
      selectedItems: (json['selectedItems'] as List<dynamic>)
          .map((name) => QuickActionType.values.firstWhere((t) => t.name == name))
          .toList(),
      primaryAction: QuickActionType.values.firstWhere(
        (t) => t.name == json['primaryAction'],
      ),
      lastModified: json['lastModified'] != null
          ? DateTime.parse(json['lastModified'])
          : null,
    );
  }

  /// Serializes to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Creates from JSON string
  factory UserNavbarConfig.fromJsonString(String jsonString) {
    return UserNavbarConfig.fromJson(jsonDecode(jsonString));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserNavbarConfig &&
          runtimeType == other.runtimeType &&
          _listEquals(selectedItems, other.selectedItems) &&
          primaryAction == other.primaryAction;

  @override
  int get hashCode => Object.hash(
    Object.hashAll(selectedItems),
    primaryAction,
  );

  @override
  String toString() => 'UserNavbarConfig('
      'items: ${selectedItems.length}, '
      'primary: $primaryAction)';
}

/// Helper function to compare lists
bool _listEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
