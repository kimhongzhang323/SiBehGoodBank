import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

/// Service for persisting navbar configuration to local storage.
/// 
/// Uses SharedPreferences for simple key-value storage.
/// In a production app, consider using secure storage for sensitive data.
class NavbarStorageService {
  static const String _configKey = 'navbar_config';
  
  /// Saves the navbar configuration
  Future<bool> saveConfig(UserNavbarConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.setString(_configKey, config.toJsonString());
    } catch (e) {
      debugPrint('Error saving navbar config: $e');
      return false;
    }
  }

  /// Loads the navbar configuration
  /// Returns null if no config is stored
  Future<UserNavbarConfig?> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_configKey);
      if (jsonString == null) return null;
      return UserNavbarConfig.fromJsonString(jsonString);
    } catch (e) {
      debugPrint('Error loading navbar config: $e');
      return null;
    }
  }

  /// Clears the stored configuration
  Future<bool> clearConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.remove(_configKey);
    } catch (e) {
      debugPrint('Error clearing navbar config: $e');
      return false;
    }
  }
}

/// Provider for managing navbar configuration state.
/// 
/// This uses the ChangeNotifier pattern for simplicity.
/// For larger apps, consider using Riverpod, Bloc, or another 
/// state management solution.
/// 
/// Key responsibilities:
/// - Load/save user preferences
/// - Validate configuration changes
/// - Notify listeners of updates
class NavbarConfigProvider extends ChangeNotifier {
  final NavbarStorageService _storage;
  
  UserNavbarConfig _config;
  bool _isLoading = false;
  String? _error;

  NavbarConfigProvider({
    NavbarStorageService? storage,
    UserNavbarConfig? initialConfig,
  })  : _storage = storage ?? NavbarStorageService(),
        _config = initialConfig ?? UserNavbarConfig.defaultConfig();

  /// Current navbar configuration
  UserNavbarConfig get config => _config;

  /// Whether the provider is loading data
  bool get isLoading => _isLoading;

  /// Last error message, if any
  String? get error => _error;

  /// Selected quick actions in navbar order
  List<QuickAction> get navbarItems => _config.orderedActionsWithPrimaryCenter;

  /// The primary action
  QuickAction get primaryAction => _config.primaryQuickAction;

  /// Index of primary action in the navbar
  int get primaryActionIndex => 2; // Always center when we have 5 items

  /// Initialize by loading saved configuration
  Future<void> initialize() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final savedConfig = await _storage.loadConfig();
      if (savedConfig != null && savedConfig.isValid) {
        _config = savedConfig;
      }
    } catch (e) {
      _error = 'Failed to load configuration';
      debugPrint('NavbarConfigProvider init error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the entire configuration
  Future<bool> updateConfig(UserNavbarConfig newConfig) async {
    // Validate first
    final validationError = newConfig.validate();
    if (validationError != null) {
      _error = validationError;
      notifyListeners();
      return false;
    }

    _error = null;
    _config = newConfig;
    notifyListeners();

    // Persist in background
    final saved = await _storage.saveConfig(_config);
    if (!saved) {
      debugPrint('Warning: Failed to persist navbar config');
    }

    return true;
  }

  /// Updates selected items while keeping current primary if possible
  Future<bool> updateSelectedItems(List<QuickActionType> items) async {
    // If current primary is still in items, keep it; otherwise use first eligible
    QuickActionType newPrimary = _config.primaryAction;
    if (!items.contains(newPrimary)) {
      final eligiblePrimary = items.firstWhere(
        (type) => getActionByType(type).canBePrimary,
        orElse: () => items.first,
      );
      newPrimary = eligiblePrimary;
    }

    return updateConfig(_config.copyWith(
      selectedItems: items,
      primaryAction: newPrimary,
    ));
  }

  /// Sets a new primary action
  Future<bool> setPrimaryAction(QuickActionType type) async {
    if (!_config.selectedItems.contains(type)) {
      _error = 'Cannot set primary action that is not in navbar';
      notifyListeners();
      return false;
    }

    final action = getActionByType(type);
    if (!action.canBePrimary) {
      _error = '${action.label} cannot be set as primary action';
      notifyListeners();
      return false;
    }

    return updateConfig(_config.copyWith(primaryAction: type));
  }

  /// Adds an item to the navbar
  Future<bool> addItem(QuickActionType type) async {
    if (_config.selectedItems.length >= UserNavbarConfig.maxItems) {
      _error = 'Maximum ${UserNavbarConfig.maxItems} items allowed';
      notifyListeners();
      return false;
    }

    if (_config.selectedItems.contains(type)) {
      _error = 'Item already in navbar';
      notifyListeners();
      return false;
    }

    final newItems = [..._config.selectedItems, type];
    return updateSelectedItems(newItems);
  }

  /// Removes an item from the navbar
  Future<bool> removeItem(QuickActionType type) async {
    if (_config.selectedItems.length <= UserNavbarConfig.minItems) {
      _error = 'Minimum ${UserNavbarConfig.minItems} items required';
      notifyListeners();
      return false;
    }

    if (!_config.selectedItems.contains(type)) {
      return true; // Already removed
    }

    final newItems = _config.selectedItems.where((t) => t != type).toList();
    return updateSelectedItems(newItems);
  }

  /// Reorders items in the navbar
  Future<bool> reorderItems(int oldIndex, int newIndex) async {
    final items = List<QuickActionType>.from(_config.selectedItems);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    return updateSelectedItems(items);
  }

  /// Resets to default configuration
  Future<bool> resetToDefault() async {
    return updateConfig(UserNavbarConfig.defaultConfig());
  }

  /// Clears any error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

/// InheritedWidget wrapper for providing NavbarConfigProvider down the tree.
/// 
/// Usage:
/// ```dart
/// NavbarConfigScope(
///   provider: NavbarConfigProvider(),
///   child: MyApp(),
/// )
/// ```
/// 
/// Access via:
/// ```dart
/// NavbarConfigScope.of(context).config
/// ```
class NavbarConfigScope extends InheritedNotifier<NavbarConfigProvider> {
  const NavbarConfigScope({
    super.key,
    required NavbarConfigProvider provider,
    required super.child,
  }) : super(notifier: provider);

  static NavbarConfigProvider of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<NavbarConfigScope>();
    assert(scope != null, 'No NavbarConfigScope found in context');
    return scope!.notifier!;
  }

  static NavbarConfigProvider? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<NavbarConfigScope>();
    return scope?.notifier;
  }
}
