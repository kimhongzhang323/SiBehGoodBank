import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../services/navbar_config_provider.dart';

/// A customizable bottom navigation bar with a prominent center action.
/// 
/// Features:
/// - Up to 5 navigation items
/// - Elevated circular center button for primary action
/// - Glassmorphism styling matching the app theme
/// - Haptic feedback on tap
/// - Accessibility support with semantic labels
/// 
/// The center item is visually emphasized with:
/// - Larger circular container
/// - Elevated/floating appearance
/// - Highlight color and subtle glow
class CustomBottomNavBar extends StatelessWidget {
  /// Callback when a nav item is tapped
  final ValueChanged<int> onItemTapped;
  
  /// Currently selected index
  final int selectedIndex;
  
  /// Optional callback specifically for center action
  final VoidCallback? onCenterActionTap;

  const CustomBottomNavBar({
    super.key,
    required this.onItemTapped,
    required this.selectedIndex,
    this.onCenterActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = NavbarConfigScope.of(context);
    final items = provider.navbarItems;
    
    // Only show center button for odd number of items
    final isOddCount = items.length % 2 == 1;
    final centerIndex = isOddCount ? items.length ~/ 2 : -1;
    
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: SizedBox(
          height: 80,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Background bar
              _buildNavBarBackground(context, items, centerIndex),
              // Center floating button (if odd number of items)
              if (isOddCount && centerIndex >= 0 && centerIndex < items.length)
                _buildCenterButton(context, items[centerIndex], centerIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavBarBackground(BuildContext context, List<QuickAction> items, int centerIndex) {
    // Determine if we have a center button
    final hasCenterButton = centerIndex >= 0;
    
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(items.length, (index) {
          // If center button exists and this is center item, add empty space
          if (hasCenterButton && index == centerIndex) {
            return const SizedBox(width: 70); // Space for floating button
          }
          return _buildNavItem(context, items[index], index);
        }),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, QuickAction action, int index) {
    final isSelected = selectedIndex == index;
    
    return Expanded(
      child: InkWell(
        onTap: () => _handleTap(index),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Semantics(
          label: action.label,
          button: true,
          selected: isSelected,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? action.selectedIcon : action.icon,
                    key: ValueKey(isSelected),
                    color: isSelected 
                        ? AppColors.accent 
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  action.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected 
                        ? AppColors.accent 
                        : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterButton(
    BuildContext context, 
    QuickAction action, 
    int index,
  ) {
    final isSelected = selectedIndex == index;
    
    return Positioned(
      top: -12, // Float above the bar
      child: GestureDetector(
        onTap: () {
          _handleTap(index);
          onCenterActionTap?.call();
        },
        child: Semantics(
          label: '${action.label} - Primary action',
          button: true,
          selected: isSelected,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [
                        AppColors.accent,
                        AppColors.accent.withOpacity(0.8),
                      ]
                    : [
                        AppColors.lilac,
                        AppColors.softPurple,
                      ],
              ),
              boxShadow: [
                // Primary shadow
                BoxShadow(
                  color: (isSelected ? AppColors.accent : AppColors.lilac)
                      .withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                  spreadRadius: 0,
                ),
                // Subtle glow
                BoxShadow(
                  color: (isSelected ? AppColors.accent : AppColors.softPurple)
                      .withOpacity(0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 2),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              isSelected ? action.selectedIcon : action.icon,
              color: isSelected ? Colors.white : AppColors.textPrimary,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(int index) {
    // Haptic feedback for better UX
    HapticFeedback.lightImpact();
    onItemTapped(index);
  }
}

/// A simplified version without provider dependency for standalone use
class SimpleCustomBottomNavBar extends StatelessWidget {
  final List<QuickAction> items;
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final int? primaryIndex;

  const SimpleCustomBottomNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemTapped,
    this.primaryIndex,
  });

  @override
  Widget build(BuildContext context) {
    // Only show center button for odd number of items
    final isOddCount = items.length % 2 == 1;
    final centerIndex = isOddCount 
        ? (primaryIndex ?? (items.length ~/ 2)) 
        : -1;
    final hasCenterButton = isOddCount && centerIndex >= 0;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: SizedBox(
          height: 80,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              // Background bar
              Container(
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(items.length, (index) {
                    if (hasCenterButton && index == centerIndex) {
                      return const SizedBox(width: 70);
                    }
                    return _buildNavItem(context, items[index], index);
                  }),
                ),
              ),
              // Center button
              if (hasCenterButton)
                _buildCenterButton(context, items[centerIndex], centerIndex),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, QuickAction action, int index) {
    final isSelected = selectedIndex == index;
    
    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onItemTapped(index);
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Semantics(
          label: action.label,
          button: true,
          selected: isSelected,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? action.selectedIcon : action.icon,
                  color: isSelected ? AppColors.accent : AppColors.textSecondary,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  action.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? AppColors.accent : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCenterButton(
    BuildContext context,
    QuickAction action,
    int index,
  ) {
    final isSelected = selectedIndex == index;
    
    return Positioned(
      top: -12,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onItemTapped(index);
        },
        child: Semantics(
          label: '${action.label} - Primary action',
          button: true,
          selected: isSelected,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [AppColors.accent, AppColors.accent.withOpacity(0.8)]
                    : [AppColors.lilac, AppColors.softPurple],
              ),
              boxShadow: [
                BoxShadow(
                  color: (isSelected ? AppColors.accent : AppColors.lilac)
                      .withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: (isSelected ? AppColors.accent : AppColors.softPurple)
                      .withOpacity(0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 2),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              isSelected ? action.selectedIcon : action.icon,
              color: isSelected ? Colors.white : AppColors.textPrimary,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}
