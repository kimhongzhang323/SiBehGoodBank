import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import 'home_screen.dart';
import 'ai_chat_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';

/// Root shell that manages the customizable bottom navigation bar.
/// 
/// This widget:
/// - Displays the custom bottom navbar with a floating center action
/// - Handles navigation between main screens
/// - Integrates with NavbarConfigProvider for customization
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  // -1 means Home (not in navbar), 0+ means navbar index
  int _navbarIndex = -1;
  
  // Whether we're showing Home (always accessible, even if not in navbar)
  bool get _isOnHome => _navbarIndex < 0;

  void _goToHome() {
    setState(() => _navbarIndex = -1);
  }

  @override
  Widget build(BuildContext context) {
    final provider = NavbarConfigScope.of(context);
    final navItems = provider.navbarItems;
    
    // Check if Home is in the navbar
    final homeNavIndex = navItems.indexWhere((a) => a.type == QuickActionType.home);
    
    // Build screens: Home is always available, plus all navbar items (except Home to avoid duplicate)
    final List<Widget> allScreens = [
      const HomeScreen(), // Index 0 is always Home
      ...navItems
          .where((a) => a.type != QuickActionType.home)
          .map((a) => _getScreenForAction(a.type, onBackToHome: _goToHome)),
    ];
    
    // Calculate which screen to show in IndexedStack
    int displayIndex;
    if (_navbarIndex < 0) {
      // Show Home
      displayIndex = 0;
    } else if (homeNavIndex >= 0 && _navbarIndex == homeNavIndex) {
      // Home button in navbar tapped
      displayIndex = 0;
    } else {
      // Map navbar index to screen index (accounting for Home at 0)
      // Count non-home items before this navbar index
      int screenIndex = 1; // Start after Home
      for (int i = 0; i < _navbarIndex && i < navItems.length; i++) {
        if (navItems[i].type != QuickActionType.home) {
          screenIndex++;
        }
      }
      displayIndex = screenIndex.clamp(0, allScreens.length - 1);
    }
    
    return PopScope(
      canPop: _isOnHome,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Back button pressed - go to Home
          _goToHome();
        }
      },
      child: Scaffold(
        body: IndexedStack(
          index: displayIndex,
          children: allScreens,
        ),
        bottomNavigationBar: CustomBottomNavBar(
          // If on Home and Home is in navbar, highlight it; otherwise use navbar index
          selectedIndex: _isOnHome ? (homeNavIndex >= 0 ? homeNavIndex : -1) : _navbarIndex,
          onItemTapped: (index) {
            setState(() => _navbarIndex = index);
          },
          onCenterActionTap: () {
            // Center action is the primary action
          },
        ),
      ),
    );
  }

  /// Maps QuickActionType to the corresponding screen widget.
  /// Screens get a callback to return to Home.
  Widget _getScreenForAction(QuickActionType type, {required VoidCallback onBackToHome}) {
    switch (type) {
      case QuickActionType.home:
        return const HomeScreen();
      case QuickActionType.ai:
        return AiChatScreen(onBackToHome: onBackToHome);
      case QuickActionType.analytics:
        return AnalyticsScreen(onBackToHome: onBackToHome);
      case QuickActionType.scanQr:
        return _PlaceholderScreen(title: 'Scan QR', icon: Icons.qr_code_scanner, onBackToHome: onBackToHome);
      case QuickActionType.transfer:
        return _PlaceholderScreen(title: 'Transfer', icon: Icons.swap_horiz, onBackToHome: onBackToHome);
      case QuickActionType.contacts:
        return _PlaceholderScreen(title: 'Contacts', icon: Icons.contacts, onBackToHome: onBackToHome);
      case QuickActionType.accounts:
        return _PlaceholderScreen(title: 'Accounts', icon: Icons.account_balance, onBackToHome: onBackToHome);
      case QuickActionType.family:
        return _PlaceholderScreen(title: 'Family', icon: Icons.family_restroom, onBackToHome: onBackToHome);
      case QuickActionType.cards:
        return _PlaceholderScreen(title: 'Cards', icon: Icons.credit_card, onBackToHome: onBackToHome);
      case QuickActionType.bills:
        return _PlaceholderScreen(title: 'Bills', icon: Icons.receipt_long, onBackToHome: onBackToHome);
      case QuickActionType.topUp:
        return _PlaceholderScreen(title: 'Top-up', icon: Icons.add_circle, onBackToHome: onBackToHome);
      case QuickActionType.rewards:
        return _PlaceholderScreen(title: 'Rewards', icon: Icons.card_giftcard, onBackToHome: onBackToHome);
      case QuickActionType.support:
        return _PlaceholderScreen(title: 'Support', icon: Icons.support_agent, onBackToHome: onBackToHome);
      case QuickActionType.settings:
        return SettingsScreen(onBackToHome: onBackToHome);
    }
  }
}

/// Placeholder screen for features not yet implemented.
/// Displays the feature name and icon with a "Coming Soon" message.
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onBackToHome;

  const _PlaceholderScreen({
    required this.title,
    required this.icon,
    this.onBackToHome,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: onBackToHome != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: onBackToHome,
              )
            : null,
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.holographicGradient.sublist(0, 3),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.headlineLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Coming Soon',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
