import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';
import 'analytics_screen.dart';
import 'gamification_screen.dart';
import 'more_screen.dart';
import 'news_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'secure_tac_screen.dart';
import 'transfer_screen.dart';
import 'receive_screen.dart';
import 'settings_screen.dart';

// Currency data model
class CurrencyInfo {
  final String code;
  final String symbol;
  final String name;
  final String flag;
  final double exchangeRate; // Rate relative to MYR (base)

  const CurrencyInfo({
    required this.code,
    required this.symbol,
    required this.name,
    required this.flag,
    required this.exchangeRate,
  });
}

/// Home / Balance Overview screen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Available currencies
  static const List<CurrencyInfo> currencies = [
    CurrencyInfo(
        code: 'MYR',
        symbol: 'RM',
        name: 'Malaysian Ringgit',
        flag: 'my',
        exchangeRate: 1.0),
    CurrencyInfo(
        code: 'SGD',
        symbol: 'S\$',
        name: 'Singapore Dollar',
        flag: 'sg',
        exchangeRate: 0.29),
    CurrencyInfo(
        code: 'USD',
        symbol: '\$',
        name: 'US Dollar',
        flag: 'us',
        exchangeRate: 0.21),
    CurrencyInfo(
        code: 'EUR', symbol: '€', name: 'Euro', flag: 'de', exchangeRate: 0.20),
    CurrencyInfo(
        code: 'GBP',
        symbol: '£',
        name: 'British Pound',
        flag: 'gb',
        exchangeRate: 0.17),
    CurrencyInfo(
        code: 'JPY',
        symbol: '¥',
        name: 'Japanese Yen',
        flag: 'jp',
        exchangeRate: 32.5),
    CurrencyInfo(
        code: 'CNY',
        symbol: '¥',
        name: 'Chinese Yuan',
        flag: 'cn',
        exchangeRate: 1.53),
    CurrencyInfo(
        code: 'THB',
        symbol: '฿',
        name: 'Thai Baht',
        flag: 'th',
        exchangeRate: 7.38),
    CurrencyInfo(
        code: 'IDR',
        symbol: 'Rp',
        name: 'Indonesian Rupiah',
        flag: 'id',
        exchangeRate: 3450),
  ];

  // Base amounts in MYR
  static const double totalBalanceMYR = 565051.20;
  static const double checkingBalanceMYR = 268508.00;
  static const double savingsBalanceMYR = 145000.00;
  static const double fixedDepositMYR = 50000.00;
  static const double investmentMYR = 25680.00;
  static const double emergencyFundMYR = 35000.00;
  static const double goalSavingsMYR = 40863.20;

  int _selectedCurrencyIndex = 0;
  bool _isBalanceHidden = false;

  // Carousel state
  final PageController _carouselController = PageController();
  int _currentCarouselIndex = 0;

  @override
  void dispose() {
    _carouselController.dispose();
    super.dispose();
  }

  CurrencyInfo get selectedCurrency => currencies[_selectedCurrencyIndex];

  String formatAmount(double amountMYR, {bool allowHide = true}) {
    if (_isBalanceHidden && allowHide) {
      return '${selectedCurrency.symbol} ••••••';
    }
    final converted = amountMYR * selectedCurrency.exchangeRate;
    final formatted = converted.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '${selectedCurrency.symbol} $formatted';
  }

  void _showCurrencyPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Currency',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: currencies.length,
                itemBuilder: (context, index) {
                  final currency = currencies[index];
                  final isSelected = index == _selectedCurrencyIndex;
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Image.asset(
                        'assets/images/countryFlag/${currency.flag}.png',
                        width: 32,
                        height: 24,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 32,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.flag, size: 18),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      currency.code,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      currency.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle,
                            color: AppColors.positive)
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedCurrencyIndex = index;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            _buildQuickActions(context),
            const SizedBox(height: AppSpacing.sm),

            // Services row (small icons)
            _buildServicesRow(context),

            const SizedBox(height: AppSpacing.lg),

            // News carousel section
            _buildNewsCarousel(context),

            const SizedBox(height: AppSpacing.lg),

            // Multi-account cards section
            _buildAccountsSection(),

            const SizedBox(height: AppSpacing.lg),

            // Recent activity section
            _buildRecentActivity(context),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.softGreen,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with avatar, currency switcher (centered), and action buttons
              SizedBox(
                height: 40,
                child: Stack(
                  children: [
                    // Left: Avatar
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ProfileScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            image: const DecorationImage(
                              image: AssetImage(
                                'assets/images/profile.jpg',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Center: Currency Switcher (absolute center of screen)
                    Center(
                      child: GestureDetector(
                        onTap: () => _showCurrencyPicker(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: Image.asset(
                                  'assets/images/countryFlag/${selectedCurrency.flag}.png',
                                  width: 20,
                                  height: 15,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 20,
                                      height: 15,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: const Icon(Icons.flag, size: 12),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                selectedCurrency.code,
                                style: AppTextStyles.labelMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                Icons.keyboard_arrow_down,
                                size: 16,
                                color: AppColors.textPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Right: Notification and Settings buttons
                    Positioned(
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Notification bell
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationsScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Stack(
                                children: [
                                  const Center(
                                    child: Icon(
                                      Icons.notifications_outlined,
                                      color: AppColors.textPrimary,
                                      size: 20,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 9,
                                    child: Container(
                                      width: 7,
                                      height: 7,
                                      decoration: const BoxDecoration(
                                        color: AppColors.negative,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Settings button
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => const SettingsScreen(),
                                ),
                              );
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.settings_outlined,
                                  color: AppColors.textPrimary,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Total Balance label with hide/show toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Balance',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary.withOpacity(0.8),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 40,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBalanceHidden = !_isBalanceHidden;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _isBalanceHidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.textPrimary.withOpacity(0.7),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Balance amount
              Text(
                formatAmount(totalBalanceMYR),
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.screenPadding,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMainActionButton(
            context,
            icon: Icons.swap_horiz,
            label: 'Transfer',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TransferScreen(
                        currencySymbol: selectedCurrency.symbol,
                      )));
            },
          ),
          _buildMainActionButton(
            context,
            icon: Icons.arrow_downward,
            label: 'Receive',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ReceiveScreen(
                        currencySymbol: selectedCurrency.symbol,
                      )));
            },
          ),
          _buildMainActionButton(
            context,
            icon: Icons.bar_chart,
            label: 'Analytics',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AnalyticsScreen()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.accent,
              size: 32,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildServiceIcon(
            context,
            icon: Icons.security,
            label: 'SecureTAC',
            color: AppColors.accent,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SecureTacScreen()),
            ),
          ),
          _buildServiceIcon(
            context,
            icon: Icons.emoji_events,
            label: 'Rewards',
            color: AppColors.accent,
            badge: '2.4k',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => const GamificationScreen()),
            ),
          ),
          _buildServiceIcon(
            context,
            icon: Icons.receipt_long,
            label: 'Bills',
            color: AppColors.accent,
            onTap: () {},
          ),
          _buildServiceIcon(
            context,
            icon: Icons.phone_android,
            label: 'Top Up',
            color: AppColors.accent,
            onTap: () {},
          ),
          _buildServiceIcon(
            context,
            icon: Icons.more_horiz,
            label: 'More',
            color: AppColors.accent,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const MoreScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceIcon(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              if (badge != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.negative,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCarousel(BuildContext context) {
    final banners = [
      'assets/images/banner1.png',
      'assets/images/banner2.png',
      'assets/images/banner3.png',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'News & Updates',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const NewsScreen()),
                ),
                child: Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Carousel that sizes to image
          SizedBox(
            height: 240, // Larger banner height
            child: PageView.builder(
              controller: _carouselController,
              itemCount: banners.length,
              onPageChanged: (index) {
                setState(() {
                  _currentCarouselIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const NewsScreen()),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        banners[index],
                        fit: BoxFit.fitWidth,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 240,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.accent.withOpacity(0.8),
                                  AppColors.lightGreen,
                                ],
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.campaign,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Promo ${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Carousel indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              banners.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentCarouselIndex == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentCarouselIndex == index
                      ? AppColors.accent
                      : AppColors.accent.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountsSection() {
    final accounts = [
      AccountData(
        accountType: 'Checking',
        balance: formatAmount(checkingBalanceMYR),
        icon: Icons.account_balance_wallet,
        color: AppColors.accent,
        subtitle: '****8834',
      ),
      AccountData(
        accountType: 'Savings',
        balance: formatAmount(savingsBalanceMYR),
        icon: Icons.savings,
        color: AppColors.positive,
        subtitle: '****2156',
      ),
      AccountData(
        accountType: 'Fixed Deposit',
        balance: formatAmount(fixedDepositMYR),
        icon: Icons.lock_clock,
        color: const Color(0xFFFFB300),
        maturityDate: 'Matures: Dec 15, 2025',
        interestRate: 3.75,
      ),
      AccountData(
        accountType: 'ASB Investment',
        balance: formatAmount(investmentMYR),
        icon: Icons.trending_up,
        color: AppColors.accentBlue,
        interestRate: 5.1,
      ),
      AccountData(
        accountType: 'Emergency Fund',
        balance: formatAmount(emergencyFundMYR),
        icon: Icons.shield,
        color: AppColors.negative,
        subtitle: 'Goal: RM50,000',
      ),
      AccountData(
        accountType: 'Goal Savings',
        balance: formatAmount(goalSavingsMYR),
        icon: Icons.flag,
        color: const Color(0xFF9C27B0),
        subtitle: 'House Downpayment',
      ),
    ];

    return MultiAccountCards(
      accounts: accounts,
      onViewAll: () {
        // Navigate to all accounts
      },
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    // Base amounts in MYR
    const slackMYR = 1532.79;
    const payrollMYR = 341466.36;
    const transferMYR = 5905.20;
    const officeExpensesMYR = 2145.72;

    final activities = [
      ActivityItemData(
        title: 'Slack',
        subtitle: 'Dec 5, 2025 • 2:30 PM',
        amount: formatAmount(slackMYR),
        isPositive: false,
        icon: Icons.tag,
        iconBackgroundColor: const Color(0xFF4A154B),
      ),
      ActivityItemData(
        title: 'Payroll',
        subtitle: 'Dec 4, 2025 • 9:00 AM',
        amount: formatAmount(payrollMYR),
        isPositive: false,
        icon: Icons.people_outline,
        iconBackgroundColor: AppColors.accentBlue,
      ),
      ActivityItemData(
        title: 'Transfer',
        subtitle: 'Dec 3, 2025 • 4:15 PM',
        amount: formatAmount(transferMYR),
        isPositive: true,
        icon: Icons.arrow_downward,
        iconBackgroundColor: AppColors.positive,
      ),
      ActivityItemData(
        title: 'Office Expenses',
        subtitle: 'Dec 2, 2025 • 11:45 AM',
        amount: formatAmount(officeExpensesMYR),
        isPositive: false,
        icon: Icons.business_center_outlined,
        iconBackgroundColor: AppColors.accent,
      ),
      ActivityItemData(
        title: 'Office Expenses',
        subtitle: 'Dec 1, 2025 • 3:20 PM',
        amount: formatAmount(officeExpensesMYR),
        isPositive: false,
        icon: Icons.business_center_outlined,
        iconBackgroundColor: AppColors.accent,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: SolidCard(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: ActivityList(
          title: 'Recent Activity',
          activities: activities,
          onSeeAllTap: () {},
        ),
      ),
    );
  }
}
