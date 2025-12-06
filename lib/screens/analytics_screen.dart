import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';

/// Analytics Dashboard screen with charts and statistics
class AnalyticsScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  
  const AnalyticsScreen({super.key, this.onBackToHome});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedTabIndex = 0;
  final List<String> _tabs = ['Cash Flow', 'Expense Tracking', 'Income Statement'];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App bar
              _buildAppBar(),

              const SizedBox(height: AppSpacing.md),

              // Tab control
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: SegmentedTabControl(
                  tabs: _tabs,
                  selectedIndex: _selectedTabIndex,
                  onTabChanged: (index) {
                    setState(() {
                      _selectedTabIndex = index;
                    });
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Cash Report Card
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: _buildCashReportCard(),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Category breakdown
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: _buildCategoryBreakdown(),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Revenue Analysis Card
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: _buildRevenueAnalysisCard(),
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (widget.onBackToHome != null) {
                widget.onBackToHome!();
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Text(
            'Analytics',
            style: AppTextStyles.headlineLarge,
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.more_horiz,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashReportCard() {
    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Cash Report',
                style: AppTextStyles.titleLarge,
              ),
              const TrendBadge(
                value: '12%',
                isPositive: true,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            '\$72,858.00',
            style: AppTextStyles.amountLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Flow chart
          FlowChart(
            dataLines: [
              [0.3, 0.5, 0.4, 0.7, 0.5, 0.8, 0.6, 0.7],
              [0.5, 0.3, 0.6, 0.4, 0.7, 0.5, 0.8, 0.6],
              [0.2, 0.4, 0.3, 0.5, 0.4, 0.6, 0.5, 0.7],
            ],
            lineColors: const [
              AppColors.accent,
              AppColors.pastelBlue,
              AppColors.pinkTint,
            ],
            height: 150,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: AppTextStyles.titleLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          CategoryList(
            items: [
              CategoryProgressItem(
                title: 'Operations',
                percentage: 54,
                color: AppColors.accent,
              ),
              CategoryProgressItem(
                title: 'Financing Activities',
                percentage: 31,
                color: AppColors.pastelBlue,
              ),
              CategoryProgressItem(
                title: 'Investments',
                percentage: 15,
                color: AppColors.pinkTint,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueAnalysisCard() {
    return SolidCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Revenue Analysis',
                style: AppTextStyles.titleLarge,
              ),
              const SizedBox(width: AppSpacing.sm),
              TrendBadge(
                value: '5%',
                isPositive: true,
                backgroundColor: AppColors.accentBlue.withOpacity(0.15),
                textColor: AppColors.accentBlue,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'April Revenue',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    '+\$52,456.00',
                    style: AppTextStyles.amountSmall,
                  ),
                ],
              ),
              MiniLineChart(
                data: const [0.4, 0.6, 0.5, 0.8, 0.6, 0.4, 0.7, 0.3],
                lineColor: AppColors.accentBlue,
                showTooltip: true,
                tooltipValue: '-44k',
                highlightIndex: 7,
                width: 120,
                height: 50,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
