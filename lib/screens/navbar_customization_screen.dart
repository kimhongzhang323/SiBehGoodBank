import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../services/navbar_config_provider.dart';
import '../widgets/custom_bottom_nav_bar.dart';

/// Screen for customizing the bottom navigation bar.
/// 
/// Allows users to:
/// - Select which quick actions appear in the navbar (max 5)
/// - Choose which item is the primary (center) action
/// - Reorder items via drag and drop
/// - Preview changes in real-time
/// 
/// Follows banking app best practices:
/// - Clear visual feedback
/// - Confirmation before saving
/// - Easy reset to defaults
class NavbarCustomizationScreen extends StatefulWidget {
  const NavbarCustomizationScreen({super.key});

  @override
  State<NavbarCustomizationScreen> createState() =>
      _NavbarCustomizationScreenState();
}

class _NavbarCustomizationScreenState extends State<NavbarCustomizationScreen> {
  // Working copy of selected items (not saved until user confirms)
  List<QuickActionType> _selectedItems = [];
  QuickActionType? _primaryAction;
  
  // Track if changes have been made
  bool _hasChanges = false;
  
  // Error message to display
  String? _errorMessage;
  
  // Whether data has been loaded
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Initialize from provider after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentConfig();
    });
  }

  void _loadCurrentConfig() {
    final provider = NavbarConfigScope.of(context);
    setState(() {
      _selectedItems = List.from(provider.config.selectedItems);
      _primaryAction = provider.config.primaryAction;
      _hasChanges = false;
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading until initialized
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: AppColors.cardBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Customize Navigation'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Preview section
          _buildPreviewSection(),
          
          // Divider
          const Divider(height: 1),
          
          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSelectedItemsSection(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildAvailableActionsSection(),
                ],
              ),
            ),
          ),
          
          // Bottom action buttons
          _buildBottomActions(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => _handleBackPress(),
      ),
      title: const Text(
        'Customize Navigation',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        TextButton(
          onPressed: _resetToDefault,
          child: const Text('Reset'),
        ),
      ],
    );
  }

  Widget _buildPreviewSection() {
    // Create preview items from current selection
    final previewItems = _selectedItems
        .map((type) => getActionByType(type))
        .toList();
    
    // Only show center button for odd number of items and if primary is set
    final isOddCount = _selectedItems.length % 2 == 1;
    final centerIndex = isOddCount && _primaryAction != null
        ? _selectedItems.indexOf(_primaryAction!)
        : -1;

    return Container(
      color: AppColors.cardBackgroundAlt,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          const Text(
            'Preview',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Simplified preview navbar
          _buildPreviewNavbar(previewItems, centerIndex),
        ],
      ),
    );
  }

  Widget _buildPreviewNavbar(List<QuickAction> items, int primaryIndex) {
    if (items.isEmpty) {
      return Container(
        height: 68,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: AppColors.textSecondary.withOpacity(0.2),
            style: BorderStyle.solid,
          ),
        ),
        child: const Center(
          child: Text(
            'Select items below',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    // Reorder to put primary in center if 5 items
    final orderedItems = List<QuickAction>.from(items);
    int displayPrimaryIndex = primaryIndex;
    if (items.length == 5 && primaryIndex != 2 && primaryIndex >= 0) {
      final primary = orderedItems.removeAt(primaryIndex);
      orderedItems.insert(2, primary);
      displayPrimaryIndex = 2;
    }

    return SimpleCustomBottomNavBar(
      items: orderedItems,
      selectedIndex: displayPrimaryIndex >= 0 ? displayPrimaryIndex : 0,
      onItemTapped: (_) {}, // Preview only
      primaryIndex: displayPrimaryIndex >= 0 ? displayPrimaryIndex : null,
    );
  }

  Widget _buildSelectedItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Selected Items',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '${_selectedItems.length}/${UserNavbarConfig.maxItems}',
              style: TextStyle(
                fontSize: 14,
                color: _selectedItems.length == UserNavbarConfig.maxItems
                    ? AppColors.accent
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          _selectedItems.length % 2 == 1
              ? 'Tap ★ to set as primary action. Long press to reorder.'
              : 'Long press to reorder. Add/remove items for primary selection.',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Error message
        if (_errorMessage != null)
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.negative.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, 
                    color: AppColors.negative, size: 16),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.negative,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        
        // Reorderable list of selected items
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: _selectedItems.length,
          onReorder: _onReorder,
          proxyDecorator: (child, index, animation) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: child,
                );
              },
              child: child,
            );
          },
          itemBuilder: (context, index) {
            final type = _selectedItems[index];
            final action = getActionByType(type);
            final isPrimary = type == _primaryAction;
            // Only show star button for odd number of items
            final showStarButton = _selectedItems.length % 2 == 1;
            
            return _buildSelectedItemTile(
              key: ValueKey(type),
              index: index,
              action: action,
              isPrimary: isPrimary,
              showStarButton: showStarButton,
              onRemove: () => _removeItem(type),
              onSetPrimary: () => _setPrimaryAction(type),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSelectedItemTile({
    required Key key,
    required int index,
    required QuickAction action,
    required bool isPrimary,
    required bool showStarButton,
    required VoidCallback onRemove,
    required VoidCallback onSetPrimary,
  }) {
    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      decoration: BoxDecoration(
        color: isPrimary ? AppColors.accent.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isPrimary 
              ? AppColors.accent.withOpacity(0.3) 
              : AppColors.glassBorder,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isPrimary 
                ? AppColors.accent.withOpacity(0.2)
                : AppColors.cardBackgroundAlt,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(
            action.icon,
            color: isPrimary ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
        title: Text(
          action.label,
          style: TextStyle(
            fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: isPrimary
            ? const Text(
                'Primary action (center)',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.accent,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Set as primary button - only shown for odd item count
            if (showStarButton && action.canBePrimary)
              IconButton(
                icon: Icon(
                  isPrimary ? Icons.star : Icons.star_border,
                  color: isPrimary ? AppColors.accent : AppColors.textSecondary,
                ),
                onPressed: onSetPrimary,
                tooltip: 'Set as primary action',
              ),
            // Remove button
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: AppColors.negative.withOpacity(0.7),
              onPressed: onRemove,
              tooltip: 'Remove from navbar',
            ),
            // Drag handle with ReorderableDragStartListener
            ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle, color: AppColors.textLight, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableActionsSection() {
    // Filter out already selected items
    final availableActions = allActions
        .where((action) => !_selectedItems.contains(action.type))
        .toList();

    if (availableActions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Tap to add to your navigation bar',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: availableActions.map((action) {
            final canAdd = _selectedItems.length < UserNavbarConfig.maxItems;
            
            return ActionChip(
              avatar: Icon(
                action.icon,
                size: 18,
                color: canAdd ? AppColors.textPrimary : AppColors.textLight,
              ),
              label: Text(
                action.label,
                style: TextStyle(
                  color: canAdd ? AppColors.textPrimary : AppColors.textLight,
                ),
              ),
              backgroundColor: canAdd 
                  ? AppColors.cardBackgroundAlt 
                  : AppColors.cardBackgroundAlt.withOpacity(0.5),
              side: BorderSide(
                color: AppColors.glassBorder,
              ),
              onPressed: canAdd ? () => _addItem(action.type) : null,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _hasChanges ? _discardChanges : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: _hasChanges 
                        ? AppColors.textSecondary 
                        : AppColors.textLight,
                  ),
                ),
                child: Text(
                  'Discard',
                  style: TextStyle(
                    color: _hasChanges 
                        ? AppColors.textSecondary 
                        : AppColors.textLight,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _hasChanges ? _saveChanges : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Actions
  // ─────────────────────────────────────────────────────────────────────────

  void _addItem(QuickActionType type) {
    if (_selectedItems.length >= UserNavbarConfig.maxItems) {
      _showError('Maximum ${UserNavbarConfig.maxItems} items allowed');
      return;
    }
    
    HapticFeedback.lightImpact();
    setState(() {
      _selectedItems.add(type);
      _hasChanges = true;
      _errorMessage = null;
    });
  }

  void _removeItem(QuickActionType type) {
    if (_selectedItems.length <= UserNavbarConfig.minItems) {
      _showError('Minimum ${UserNavbarConfig.minItems} items required');
      return;
    }
    
    HapticFeedback.lightImpact();
    setState(() {
      _selectedItems.remove(type);
      
      // If we removed the primary action, pick a new one
      if (_primaryAction == type) {
        _primaryAction = _selectedItems.firstWhere(
          (t) => getActionByType(t).canBePrimary,
          orElse: () => _selectedItems.first,
        );
      }
      
      _hasChanges = true;
      _errorMessage = null;
    });
  }

  void _setPrimaryAction(QuickActionType type) {
    final action = getActionByType(type);
    if (!action.canBePrimary) {
      _showError('${action.label} cannot be set as primary action');
      return;
    }
    
    HapticFeedback.mediumImpact();
    setState(() {
      _primaryAction = type;
      _hasChanges = true;
      _errorMessage = null;
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _selectedItems.removeAt(oldIndex);
      _selectedItems.insert(newIndex, item);
      _hasChanges = true;
    });
  }

  Future<void> _saveChanges() async {
    // Ensure we have a valid primary action for odd item counts
    final isOddCount = _selectedItems.length % 2 == 1;
    QuickActionType effectivePrimary;
    
    if (isOddCount && _primaryAction != null && _selectedItems.contains(_primaryAction)) {
      effectivePrimary = _primaryAction!;
    } else {
      // For even counts or if no primary set, use first eligible item
      effectivePrimary = _selectedItems.firstWhere(
        (type) => getActionByType(type).canBePrimary,
        orElse: () => _selectedItems.first,
      );
    }
    
    // Validate configuration
    final config = UserNavbarConfig(
      selectedItems: _selectedItems,
      primaryAction: effectivePrimary,
    );
    
    final error = config.validate();
    if (error != null) {
      _showError(error);
      return;
    }

    final provider = NavbarConfigScope.of(context);
    final success = await provider.updateConfig(config);
    
    if (success) {
      setState(() => _hasChanges = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Navigation bar updated'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      _showError(provider.error ?? 'Failed to save changes');
    }
  }

  void _discardChanges() {
    HapticFeedback.lightImpact();
    _loadCurrentConfig();
    setState(() => _errorMessage = null);
  }

  void _resetToDefault() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Default?'),
        content: const Text(
          'This will restore the navigation bar to its default configuration.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _applyDefaultConfig();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _applyDefaultConfig() {
    final defaultConfig = UserNavbarConfig.defaultConfig();
    setState(() {
      _selectedItems = List.from(defaultConfig.selectedItems);
      _primaryAction = defaultConfig.primaryAction;
      _hasChanges = true;
    });
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
  }

  Future<void> _handleBackPress() async {
    if (!_hasChanges) {
      Navigator.pop(context);
      return;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text(
          'You have unsaved changes. Are you sure you want to leave?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.negative,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (shouldDiscard == true && mounted) {
      Navigator.pop(context);
    }
  }
}
