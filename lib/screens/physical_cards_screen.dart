import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';

/// Physical Cards Screen for applying and managing physical cards
class PhysicalCardsScreen extends StatefulWidget {
  const PhysicalCardsScreen({super.key});

  @override
  State<PhysicalCardsScreen> createState() => _PhysicalCardsScreenState();
}

class _PhysicalCardsScreenState extends State<PhysicalCardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_PhysicalCard> _myCards = [
    _PhysicalCard(
      id: '1',
      cardNumber: '**** **** **** 4521',
      cardType: 'Debit',
      cardName: 'SiBeh Platinum',
      status: 'Active',
      expiryDate: '12/27',
      color: const Color(0xFF1A1A2E),
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
                    _buildMyCardsTab(),
                    _buildApplyCardTab(),
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
            child: Text(
              'Physical Cards',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
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
          Tab(text: 'My Cards'),
          Tab(text: 'Apply New'),
        ],
      ),
    );
  }

  Widget _buildMyCardsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ..._myCards.map((card) => _buildCardItem(card)),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Card Services',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildServiceGrid(),
        ],
      ),
    );
  }

  Widget _buildCardItem(_PhysicalCard card) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: card.color.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                card.color,
                card.color.withOpacity(0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned(
                right: -30,
                top: -30,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -40,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
              // Card content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          card.cardName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: card.status == 'Active'
                                ? Colors.green.withOpacity(0.3)
                                : Colors.orange.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            card.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: card.status == 'Active'
                                  ? Colors.greenAccent
                                  : Colors.orangeAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Chip
                    Container(
                      width: 45,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.sim_card,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      card.cardNumber,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'VALID THRU',
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.white60,
                              ),
                            ),
                            Text(
                              card.expiryDate,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          card.cardType.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceGrid() {
    final services = [
      {'icon': Icons.lock, 'label': 'Block Card', 'color': Colors.red},
      {'icon': Icons.pin, 'label': 'Reset PIN', 'color': Colors.blue},
      {'icon': Icons.credit_card_off, 'label': 'Replace Card', 'color': Colors.orange},
      {'icon': Icons.settings, 'label': 'Card Settings', 'color': Colors.purple},
      {'icon': Icons.attach_money, 'label': 'Set Limit', 'color': Colors.green},
      {'icon': Icons.receipt_long, 'label': 'Statements', 'color': Colors.teal},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.0,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return GestureDetector(
          onTap: () => _showComingSoon(),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (service['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    service['icon'] as IconData,
                    color: service['color'] as Color,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  service['label'] as String,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildApplyCardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose Your Card',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildCardOption(
            name: 'SiBeh Classic Debit',
            description: 'Perfect for everyday spending',
            annualFee: 'FREE',
            color: const Color(0xFF4A90E2),
            features: [
              'Free ATM withdrawals',
              'Cashback on retail',
              'No minimum balance',
            ],
          ),
          _buildCardOption(
            name: 'SiBeh Platinum Debit',
            description: 'Premium benefits & rewards',
            annualFee: 'RM 50/year',
            color: const Color(0xFF1A1A2E),
            features: [
              '2x rewards points',
              'Airport lounge access',
              'Travel insurance',
              'Concierge service',
            ],
            isPopular: true,
          ),
          _buildCardOption(
            name: 'SiBeh Gold Credit',
            description: 'Build your credit score',
            annualFee: 'RM 100/year',
            color: const Color(0xFFD4AF37),
            features: [
              '5% cashback on dining',
              '3% on groceries',
              'Flexible payment plans',
              'Zero liability protection',
            ],
          ),
          _buildCardOption(
            name: 'SiBeh Business Card',
            description: 'For entrepreneurs & SMEs',
            annualFee: 'RM 150/year',
            color: const Color(0xFF6C63FF),
            features: [
              'Expense tracking',
              'Employee cards',
              'Higher credit limit',
              'Business rewards',
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardOption({
    required String name,
    required String description,
    required String annualFee,
    required Color color,
    required List<String> features,
    bool isPopular = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          if (isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSpacing.radiusLg),
                ),
              ),
              child: const Center(
                child: Text(
                  '⭐ MOST POPULAR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.credit_card,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        annualFee,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(height: 1),
                const SizedBox(height: AppSpacing.md),
                ...features.map((feature) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: color,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            feature,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showApplicationFlow(name, color),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Apply Now',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showApplicationFlow(String cardName, Color color) {
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
        builder: (context, scrollController) => _CardApplicationForm(
          cardName: cardName,
          color: color,
          scrollController: scrollController,
        ),
      ),
    );
  }

  void _showComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Coming Soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: AppColors.accent,
      ),
    );
  }
}

class _CardApplicationForm extends StatefulWidget {
  final String cardName;
  final Color color;
  final ScrollController scrollController;

  const _CardApplicationForm({
    required this.cardName,
    required this.color,
    required this.scrollController,
  });

  @override
  State<_CardApplicationForm> createState() => _CardApplicationFormState();
}

class _CardApplicationFormState extends State<_CardApplicationForm> {
  int _currentStep = 0;
  bool _agreedToTerms = false;
  String _deliveryOption = 'Standard';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
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
          Text(
            'Apply for ${ widget.cardName}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildStepIndicator(),
          const SizedBox(height: AppSpacing.xl),
          _buildCurrentStep(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStep(0, 'Verify'),
        _buildStepConnector(0),
        _buildStep(1, 'Delivery'),
        _buildStepConnector(1),
        _buildStep(2, 'Confirm'),
      ],
    );
  }

  Widget _buildStep(int step, String label) {
    final isActive = step <= _currentStep;
    final isCurrent = step == _currentStep;
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? widget.color : Colors.grey[300],
              border: isCurrent
                  ? Border.all(color: widget.color, width: 2)
                  : null,
            ),
            child: Center(
              child: isActive && !isCurrent
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : Colors.grey,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? widget.color : Colors.grey,
              fontWeight: isCurrent ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int beforeStep) {
    final isActive = beforeStep < _currentStep;
    return Container(
      width: 40,
      height: 2,
      color: isActive ? widget.color : Colors.grey[300],
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildVerifyStep();
      case 1:
        return _buildDeliveryStep();
      case 2:
        return _buildConfirmStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildVerifyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.positive.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_user, color: AppColors.positive),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Identity Verified',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.positive,
                      ),
                    ),
                    Text(
                      'Your identity has been verified via eKYC',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const Text(
          'Delivery Address',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ahmad bin Abdullah',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '123 Jalan Bukit Bintang\n55100 Kuala Lumpur',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text('Edit'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            text: 'Continue',
            onPressed: () => setState(() => _currentStep = 1),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Delivery Option',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildDeliveryOption(
          'Standard',
          'Free delivery within 7-10 business days',
          'FREE',
        ),
        _buildDeliveryOption(
          'Express',
          'Delivery within 3-5 business days',
          'RM 15',
        ),
        _buildDeliveryOption(
          'Same Day',
          'Delivery within 24 hours (KL/Selangor)',
          'RM 30',
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 0),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: widget.color),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: widget.color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton(
                onPressed: () => setState(() => _currentStep = 2),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryOption(String title, String description, String price) {
    final isSelected = _deliveryOption == title;
    
    return GestureDetector(
      onTap: () => setState(() => _deliveryOption = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? widget.color.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? widget.color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? widget.color : Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected ? widget.color : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? widget.color : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSummaryRow('Card Type', widget.cardName),
              const Divider(),
              _buildSummaryRow('Delivery', _deliveryOption),
              const Divider(),
              _buildSummaryRow(
                'Delivery Fee',
                _deliveryOption == 'Standard'
                    ? 'FREE'
                    : _deliveryOption == 'Express'
                        ? 'RM 15'
                        : 'RM 30',
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _agreedToTerms,
              onChanged: (value) => setState(() => _agreedToTerms = value ?? false),
              activeColor: widget.color,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                child: const Text(
                  'I agree to the Terms & Conditions and understand the card features and fees.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep = 1),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: widget.color),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: widget.color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ElevatedButton(
                onPressed: _agreedToTerms ? () => _submitApplication() : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _agreedToTerms ? widget.color : Colors.grey[300],
                  foregroundColor: _agreedToTerms ? Colors.white : Colors.grey[600],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Submit Application',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _submitApplication() {
    Navigator.pop(context);
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
              'Application Submitted!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your ${widget.cardName} application has been submitted. You\'ll receive your card within the selected delivery timeframe.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
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
  }
}

class _PhysicalCard {
  final String id;
  final String cardNumber;
  final String cardType;
  final String cardName;
  final String status;
  final String expiryDate;
  final Color color;

  _PhysicalCard({
    required this.id,
    required this.cardNumber,
    required this.cardType,
    required this.cardName,
    required this.status,
    required this.expiryDate,
    required this.color,
  });
}
