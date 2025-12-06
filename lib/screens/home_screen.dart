import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';
import 'analytics_screen.dart';
import 'ai_chat_screen.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'transfer_screen.dart';
import 'receive_screen.dart';

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

  CurrencyInfo get selectedCurrency => currencies[_selectedCurrencyIndex];

  String formatAmount(double amountMYR, {bool allowHide = true}) {
    if (_isBalanceHidden && allowHide) {
      return '${selectedCurrency.symbol}••••••';
    }
    final converted = amountMYR * selectedCurrency.exchangeRate;
    final formatted = converted.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '${selectedCurrency.symbol}$formatted';
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.holographicGradient,
          stops: AppColors.holographicStops,
        ),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Avatar - tap to go to profile
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
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
                  // Currency Switcher
                  GestureDetector(
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
                              width: 24,
                              height: 18,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 24,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Icon(Icons.flag, size: 14),
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
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 18,
                            color: AppColors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Notification bell
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
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
                              size: 24,
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 12,
                            child: Container(
                              width: 8,
                              height: 8,
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
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Total Balance label with hide/show toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Balance',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isBalanceHidden = !_isBalanceHidden;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _isBalanceHidden
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.sm),

              // Balance amount
              Text(
                formatAmount(totalBalanceMYR),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -1.5,
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Balance cards
              OverlappingBalanceCards(
                checkingBalance: formatAmount(checkingBalanceMYR),
                savingsBalance: formatAmount(savingsBalanceMYR),
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
        vertical: AppSpacing.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          QuickActionButton(
            icon: Icons.swap_horiz,
            label: 'Transfer',
            iconColor: AppColors.accent,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TransferScreen(
                        // Pass current currency symbol
                        currencySymbol: selectedCurrency.symbol,
                      )));
            },
          ),
          QuickActionButton(
            icon: Icons.arrow_downward,
            label: 'Receive',
            iconColor: AppColors.positive,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ReceiveScreen(
                        // Pass current currency symbol
                        currencySymbol: selectedCurrency.symbol,
                      )));
            },
          ),
          QuickActionButton(
            icon: Icons.bar_chart,
            label: 'Analytics',
            iconColor: AppColors.accentBlue,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AnalyticsScreen()));
            },
          ),
          QuickActionButton(
            icon: Icons.more_horiz,
            label: 'More',
            iconColor: AppColors.textSecondary,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const AiChatScreen()));
            },
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
