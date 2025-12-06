import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';

/// Goal-based Investment Screen for investing towards specific goals
class GoalInvestmentScreen extends StatefulWidget {
  const GoalInvestmentScreen({super.key});

  @override
  State<GoalInvestmentScreen> createState() => _GoalInvestmentScreenState();
}

class _GoalInvestmentScreenState extends State<GoalInvestmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_InvestmentGoal> _activeGoals = [
    _InvestmentGoal(
      id: '1',
      name: 'Retirement Fund',
      targetAmount: 500000.00,
      currentAmount: 125000.00,
      monthlyInvestment: 2000.00,
      riskLevel: 'Moderate',
      portfolioType: 'Balanced',
      expectedReturn: 7.5,
      icon: Icons.elderly,
      color: const Color(0xFF6C63FF),
      targetDate: DateTime(2045, 1, 1),
    ),
    _InvestmentGoal(
      id: '2',
      name: 'Child\'s Education',
      targetAmount: 200000.00,
      currentAmount: 45000.00,
      monthlyInvestment: 1000.00,
      riskLevel: 'Moderate-High',
      portfolioType: 'Growth',
      expectedReturn: 9.0,
      icon: Icons.school,
      color: const Color(0xFF4CAF50),
      targetDate: DateTime(2035, 9, 1),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: HolographicBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.md),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMyInvestmentsTab(),
                    _buildNewGoalTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Goal Investment',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Invest towards your dreams',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.insights,
              size: 20,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        labelPadding: const EdgeInsets.symmetric(horizontal: 16),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: 'My Investments'),
          Tab(text: 'New Goal'),
        ],
      ),
    );
  }

  Widget _buildMyInvestmentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPortfolioSummary(),
          const SizedBox(height: AppSpacing.lg),
          _buildMarketOverview(),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Your Investment Goals',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ..._activeGoals.map((goal) => _buildGoalCard(goal)),
        ],
      ),
    );
  }

  Widget _buildPortfolioSummary() {
    final totalInvested = _activeGoals.fold<double>(
      0,
      (sum, goal) => sum + goal.currentAmount,
    );
    final monthlyTotal = _activeGoals.fold<double>(
      0,
      (sum, goal) => sum + goal.monthlyInvestment,
    );

    // Simulated returns
    final totalReturns = totalInvested * 0.12;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF667eea),
            Color(0xFF764ba2),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667eea).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Portfolio',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up, size: 14, color: Colors.greenAccent),
                    const SizedBox(width: 4),
                    Text(
                      '+${(totalReturns / totalInvested * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'RM ${totalInvested.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Icon(Icons.arrow_upward, size: 14, color: Colors.greenAccent),
              const SizedBox(width: 4),
              Text(
                'RM ${totalReturns.toStringAsFixed(2)} returns',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.greenAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Monthly', 'RM ${monthlyTotal.toStringAsFixed(0)}'),
                Container(width: 1, height: 30, color: Colors.white24),
                _buildSummaryItem('Goals', '${_activeGoals.length}'),
                Container(width: 1, height: 30, color: Colors.white24),
                _buildSummaryItem('Avg Return', '8.2%'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white60,
          ),
        ),
      ],
    );
  }

  Widget _buildMarketOverview() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Market Overview',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMarketItem('KLCI', '1,632.45', '+0.85%', true),
              _buildMarketItem('S&P 500', '5,123.41', '+1.2%', true),
              _buildMarketItem('Gold', '\$2,045', '-0.3%', false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketItem(String name, String value, String change, bool isPositive) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          change,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isPositive ? AppColors.positive : AppColors.negative,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(_InvestmentGoal goal) {
    final progress = goal.currentAmount / goal.targetAmount;
    final yearsToGoal = goal.targetDate.difference(DateTime.now()).inDays / 365;

    return GestureDetector(
      onTap: () => _showGoalDetails(goal),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: [
            BoxShadow(
              color: goal.color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: goal.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(goal.icon, color: goal.color, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: goal.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              goal.portfolioType,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: goal.color,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${goal.expectedReturn}% expected',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: goal.color,
                      ),
                    ),
                    Text(
                      '${yearsToGoal.toStringAsFixed(1)} yrs left',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RM ${goal.currentAmount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: goal.color,
                  ),
                ),
                Text(
                  'RM ${goal.targetAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: goal.color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                const Icon(Icons.autorenew, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'RM ${goal.monthlyInvestment.toStringAsFixed(0)}/month auto-invest',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewGoalTab() {
    return _NewGoalForm();
  }

  void _showGoalDetails(_InvestmentGoal goal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: goal.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(goal.icon, color: goal.color, size: 28),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${goal.portfolioType} Portfolio',
                          style: TextStyle(
                            fontSize: 14,
                            color: goal.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Portfolio Allocation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildAllocationBar(goal),
              const SizedBox(height: AppSpacing.lg),
              _buildDetailRow('Current Value', 'RM ${goal.currentAmount.toStringAsFixed(2)}'),
              _buildDetailRow('Target Amount', 'RM ${goal.targetAmount.toStringAsFixed(2)}'),
              _buildDetailRow('Monthly Investment', 'RM ${goal.monthlyInvestment.toStringAsFixed(2)}'),
              _buildDetailRow('Risk Level', goal.riskLevel),
              _buildDetailRow('Expected Return', '${goal.expectedReturn}% p.a.'),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Top Up'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: goal.color,
                        side: BorderSide(color: goal.color),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.tune),
                      label: const Text('Adjust'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goal.color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllocationBar(_InvestmentGoal goal) {
    // Sample allocation based on portfolio type
    final allocations = goal.portfolioType == 'Growth'
        ? [
            {'name': 'Equity', 'percent': 70, 'color': const Color(0xFF4CAF50)},
            {'name': 'Bonds', 'percent': 20, 'color': const Color(0xFF2196F3)},
            {'name': 'Cash', 'percent': 10, 'color': const Color(0xFF9E9E9E)},
          ]
        : [
            {'name': 'Equity', 'percent': 50, 'color': const Color(0xFF4CAF50)},
            {'name': 'Bonds', 'percent': 35, 'color': const Color(0xFF2196F3)},
            {'name': 'Cash', 'percent': 15, 'color': const Color(0xFF9E9E9E)},
          ];

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: allocations.map((a) {
              return Expanded(
                flex: a['percent'] as int,
                child: Container(
                  height: 12,
                  color: a['color'] as Color,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: allocations.map((a) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: a['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${a['name']} ${a['percent']}%',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NewGoalForm extends StatefulWidget {
  @override
  State<_NewGoalForm> createState() => _NewGoalFormState();
}

class _NewGoalFormState extends State<_NewGoalForm> {
  final _targetController = TextEditingController();
  final _monthlyController = TextEditingController();
  String _selectedGoalType = 'Retirement';
  String _selectedRiskLevel = 'Moderate';
  int _targetYears = 20;

  final _goalTypes = [
    {'name': 'Retirement', 'icon': Icons.elderly},
    {'name': 'Education', 'icon': Icons.school},
    {'name': 'House', 'icon': Icons.home},
    {'name': 'Wedding', 'icon': Icons.favorite},
    {'name': 'Custom', 'icon': Icons.flag},
  ];

  final _riskLevels = ['Conservative', 'Moderate', 'Aggressive'];

  @override
  void dispose() {
    _targetController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGoalTypeSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildAmountSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildTimelineSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildRiskSection(),
          const SizedBox(height: AppSpacing.lg),
          _buildProjection(),
          const SizedBox(height: AppSpacing.xl),
          _buildStartButton(),
        ],
      ),
    );
  }

  Widget _buildGoalTypeSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What are you investing for?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _goalTypes.map((type) {
              final isSelected = type['name'] == _selectedGoalType;
              return GestureDetector(
                onTap: () => setState(() => _selectedGoalType = type['name'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.accent
                        : AppColors.accent.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accent
                          : AppColors.accent.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type['icon'] as IconData,
                        size: 18,
                        color: isSelected ? Colors.white : AppColors.accent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        type['name'] as String,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.accent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How much do you need?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _targetController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              prefixText: 'RM ',
              prefixStyle: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
              hintText: '0',
              border: InputBorder.none,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Monthly investment',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          TextField(
            controller: _monthlyController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              prefixText: 'RM ',
              prefixStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
              hintText: '0',
              border: InputBorder.none,
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Investment Timeline',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '$_targetYears years',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Slider(
            value: _targetYears.toDouble(),
            min: 1,
            max: 40,
            divisions: 39,
            activeColor: AppColors.accent,
            onChanged: (value) => setState(() => _targetYears = value.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('1 year', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text('40 years', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskSection() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Risk Tolerance',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: _riskLevels.map((level) {
              final isSelected = level == _selectedRiskLevel;
              Color color;
              switch (level) {
                case 'Conservative':
                  color = Colors.blue;
                  break;
                case 'Aggressive':
                  color = Colors.orange;
                  break;
                default:
                  color = Colors.green;
              }
              
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRiskLevel = level),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: level != 'Aggressive' ? 8 : 0,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          level,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          level == 'Conservative'
                              ? '4-6%'
                              : level == 'Moderate'
                                  ? '6-9%'
                                  : '9-12%',
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? Colors.white70 : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProjection() {
    final target = double.tryParse(_targetController.text) ?? 0;
    final monthly = double.tryParse(_monthlyController.text) ?? 0;
    
    double expectedReturn;
    switch (_selectedRiskLevel) {
      case 'Conservative':
        expectedReturn = 0.05;
        break;
      case 'Aggressive':
        expectedReturn = 0.10;
        break;
      default:
        expectedReturn = 0.075;
    }

    // Calculate projected value using compound interest formula
    final totalMonths = _targetYears * 12;
    final monthlyRate = expectedReturn / 12;
    final projectedValue = monthly * ((1 + monthlyRate) * (pow(1 + monthlyRate, totalMonths) - 1) / monthlyRate);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_graph, color: AppColors.accent, size: 20),
              SizedBox(width: 8),
              Text(
                'Projection',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Target', style: TextStyle(color: AppColors.textSecondary)),
              Text('RM ${target.toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Projected Value', style: TextStyle(color: AppColors.textSecondary)),
              Text(
                'RM ${projectedValue.toStringAsFixed(0)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: projectedValue >= target ? AppColors.positive : AppColors.negative,
                ),
              ),
            ],
          ),
          if (projectedValue < target && target > 0) ...[
            const SizedBox(height: 8),
            Text(
              'Consider increasing monthly investment or extending timeline',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.negative,
              ),
            ),
          ],
        ],
      ),
    );
  }

  double pow(double x, int n) {
    double result = 1;
    for (int i = 0; i < n; i++) {
      result *= x;
    }
    return result;
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: PrimaryButton(
        text: 'Start Investing',
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.positive.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: AppColors.positive,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Investment Goal Created!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your investment journey has begun. We\'ll start with your first monthly investment.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InvestmentGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final double monthlyInvestment;
  final String riskLevel;
  final String portfolioType;
  final double expectedReturn;
  final IconData icon;
  final Color color;
  final DateTime targetDate;

  _InvestmentGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.monthlyInvestment,
    required this.riskLevel,
    required this.portfolioType,
    required this.expectedReturn,
    required this.icon,
    required this.color,
    required this.targetDate,
  });
}
