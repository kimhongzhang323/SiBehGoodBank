import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';
import 'transfer_receipt_screen.dart';

class TransferScreen extends StatefulWidget {
  final String currencySymbol;
  final VoidCallback? onBackToHome;

  const TransferScreen({
    super.key,
    required this.currencySymbol,
    this.onBackToHome,
  });

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _amountController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _searchController = TextEditingController();

  bool _isLoading = false;
  String _searchQuery = '';

  // Selected values
  String _selectedPaymentMethod = 'DuitNow';
  String? _selectedSourceAccount;
  String? _selectedBank;
  Map<String, String>? _selectedFavourite;

  // Current step in the transfer flow
  int _currentStep = 0;

  // Mock user accounts
  static const List<Map<String, dynamic>> _userAccounts = [
    {
      'id': 'acc-001',
      'name': 'Main Savings',
      'number': '8012-3456-7890',
      'balance': 15847.50,
      'type': 'Savings',
      'icon': Icons.savings,
    },
    {
      'id': 'acc-002',
      'name': 'Current Account',
      'number': '8012-9999-1234',
      'balance': 5230.00,
      'type': 'Current',
      'icon': Icons.account_balance_wallet,
    },
    {
      'id': 'acc-003',
      'name': 'Investment Account',
      'number': '8012-7777-5678',
      'balance': 25000.00,
      'type': 'Investment',
      'icon': Icons.trending_up,
    },
  ];

  // Favourite transfer recipients
  static const List<Map<String, String>> _favouriteRecipients = [
    {
      'id': 'fav-001',
      'name': 'Ahmad bin Abdullah',
      'bank': 'Maybank',
      'accountNumber': '1234-5678-9012',
      'avatar': 'A',
      'nickname': 'Ahmad',
    },
    {
      'id': 'fav-002',
      'name': 'Sarah Lee',
      'bank': 'CIMB Bank',
      'accountNumber': '9876-5432-1098',
      'avatar': 'S',
      'nickname': 'Sarah',
    },
    {
      'id': 'fav-003',
      'name': 'Muhammad Rizal',
      'bank': 'Public Bank',
      'accountNumber': '5555-1234-7890',
      'avatar': 'M',
      'nickname': 'Rizal',
    },
    {
      'id': 'fav-004',
      'name': 'Jenny Tan',
      'bank': 'Hong Leong Bank',
      'accountNumber': '7777-8888-9999',
      'avatar': 'J',
      'nickname': 'Jenny',
    },
    {
      'id': 'fav-005',
      'name': 'Kumar a/l Rajan',
      'bank': 'RHB Bank',
      'accountNumber': '3333-4444-5555',
      'avatar': 'K',
      'nickname': 'Kumar',
    },
    {
      'id': 'fav-006',
      'name': 'Nurul Aisyah',
      'bank': 'Bank Islam',
      'accountNumber': '6666-7777-8888',
      'avatar': 'N',
      'nickname': 'Nurul',
    },
  ];

  // Malaysian banks list
  static const List<Map<String, dynamic>> _malaysianBanks = [
    {
      'name': 'Maybank',
      'logo': 'assets/images/may.png',
      'color': Color(0xFFFFC107)
    },
    {
      'name': 'CIMB Bank',
      'logo': 'assets/images/cimb.png',
      'color': Color(0xFFE91E63)
    },
    {
      'name': 'Public Bank',
      'logo': 'assets/images/public.png',
      'color': Color(0xFF4CAF50)
    },
    {
      'name': 'RHB Bank',
      'logo': 'assets/images/RHB.png',
      'color': Color(0xFF2196F3)
    },
    {
      'name': 'Hong Leong Bank',
      'logo': 'assets/images/hl1.png',
      'color': Color(0xFF9C27B0)
    },
    {
      'name': 'AmBank',
      'logo': 'assets/images/ambank.png',
      'color': Color(0xFFFF5722)
    },
    {
      'name': 'Bank Islam',
      'logo': 'assets/images/bankislam.png',
      'color': Color(0xFF009688)
    },
    {
      'name': 'OCBC Bank',
      'logo': 'assets/images/ocbc.png',
      'color': Color(0xFFE53935)
    },
    {
      'name': 'UOB Bank',
      'logo': 'assets/images/uob.png',
      'color': Color(0xFF3F51B5)
    },
    {
      'name': 'HSBC Bank',
      'logo': 'assets/images/hsbc.png',
      'color': Color(0xFFE53935)
    },
    {
      'name': 'Standard Chartered',
      'logo': 'assets/images/strandardchartered.png',
      'color': Color(0xFF00796B)
    },
    {
      'name': 'Bank Rakyat',
      'logo': 'assets/images/bankrakyat.jpg',
      'color': Color(0xFF1976D2)
    },
  ];

  // Quick amount presets
  static const List<String> _quickAmounts = [
    '50',
    '100',
    '200',
    '500',
    '1000',
    '2000'
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _accountNumberController.dispose();
    _recipientNameController.dispose();
    _descriptionController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filteredFavourites {
    if (_searchQuery.isEmpty) return _favouriteRecipients;
    final query = _searchQuery.toLowerCase();
    return _favouriteRecipients.where((recipient) {
      return recipient['name']!.toLowerCase().contains(query) ||
          recipient['bank']!.toLowerCase().contains(query) ||
          recipient['accountNumber']!.contains(query) ||
          (recipient['nickname']?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  void _selectFavourite(Map<String, String> favourite) {
    setState(() {
      _selectedFavourite = favourite;
      _recipientNameController.text = favourite['name']!;
      _accountNumberController.text = favourite['accountNumber']!;
      _selectedBank = favourite['bank'];
    });
  }

  void _clearFavouriteSelection() {
    setState(() {
      _selectedFavourite = null;
      _recipientNameController.clear();
      _accountNumberController.clear();
      _selectedBank = null;
    });
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0: // Payment method - always can proceed
        return true;
      case 1: // Source account
        return _selectedSourceAccount != null;
      case 2: // Recipient details
        return _selectedBank != null &&
            _accountNumberController.text.isNotEmpty &&
            _recipientNameController.text.isNotEmpty;
      case 3: // Amount
        final amount = double.tryParse(_amountController.text);
        return amount != null && amount > 0;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_canProceedToNextStep() && _currentStep < 3) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _initiateTransfer() {
    if (_amountController.text.isEmpty) {
      _showError('Please enter an amount.');
      return;
    }

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount greater than 0.');
      return;
    }

    // Check if amount exceeds source account balance
    final sourceAccount = _userAccounts.firstWhere(
      (acc) => acc['id'] == _selectedSourceAccount,
      orElse: () => _userAccounts.first,
    );
    if (amount > (sourceAccount['balance'] as double)) {
      _showError('Insufficient balance in selected account.');
      return;
    }

    setState(() => _isLoading = true);

    _showBiometricPrompt(
      context: context,
      userRole: 'Transfer',
      onAuthenticated: () {
        Navigator.pop(context);
        _completeTransfer();
      },
      onPasswordSelected: () {
        Navigator.pop(context);
        _showPasswordPrompt(context);
      },
    );
  }

  void _completeTransfer() {
    setState(() => _isLoading = false);

    final sourceAccount = _userAccounts.firstWhere(
      (acc) => acc['id'] == _selectedSourceAccount,
      orElse: () => _userAccounts.first,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TransferReceiptScreen(
          amount: _amountController.text,
          currencySymbol: widget.currencySymbol,
          recipientName: _recipientNameController.text,
          recipientAccount: _accountNumberController.text,
          isReceiving: false,
          paymentMethod: _selectedPaymentMethod,
          sourceAccount:
              '${sourceAccount['name']} (${sourceAccount['number']})',
          recipientBank: _selectedBank,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.negative,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (_currentStep > 0) {
              _previousStep();
            } else if (widget.onBackToHome != null) {
              widget.onBackToHome!();
            } else if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              Navigator.of(context).pushReplacementNamed('/');
            }
          },
        ),
        title: const Text('Transfer Money', style: AppTextStyles.headlineSmall),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.screenPadding),
              child: _buildCurrentStep(),
            ),
          ),
          // Bottom action buttons
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Method'),
          _buildStepConnector(0),
          _buildStepIndicator(1, 'From'),
          _buildStepConnector(1),
          _buildStepIndicator(2, 'To'),
          _buildStepConnector(2),
          _buildStepIndicator(3, 'Amount'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isCompleted = _currentStep > step;
    final isActive = _currentStep == step;
    final color = isCompleted
        ? AppColors.positive
        : isActive
            ? AppColors.accent
            : AppColors.textLight;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.positive
                  : (isActive ? AppColors.accent : Colors.white),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? AppColors.accent : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    final isCompleted = _currentStep > step;
    return Container(
      width: 20,
      height: 2,
      margin: const EdgeInsets.only(bottom: 20),
      color: isCompleted
          ? AppColors.positive
          : AppColors.textLight.withOpacity(0.3),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildPaymentMethodStep();
      case 1:
        return _buildSourceAccountStep();
      case 2:
        return _buildRecipientStep();
      case 3:
        return _buildAmountStep();
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 1: Payment Method Selection
  Widget _buildPaymentMethodStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Method',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Choose how you want to transfer money',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        _buildPaymentMethodCard(
          'DuitNow',
          'Instant transfer using phone number, NRIC, or account number',
          Icons.flash_on,
          AppColors.accent,
          isSelected: _selectedPaymentMethod == 'DuitNow',
          features: ['Instant transfer', 'Free', '24/7 available'],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildPaymentMethodCard(
          'IPG',
          'Interbank GIRO transfer for scheduled payments',
          Icons.schedule,
          AppColors.accentBlue,
          isSelected: _selectedPaymentMethod == 'IPG',
          features: [
            'Scheduled transfer',
            'Same day/Next day',
            'Batch payments'
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildPaymentMethodCard(
          'IBG',
          'Interbank GIRO for standard bank transfers',
          Icons.account_balance,
          AppColors.positive,
          isSelected: _selectedPaymentMethod == 'IBG',
          features: ['Standard transfer', 'Low fees', 'All banks supported'],
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
    String title,
    String description,
    IconData icon,
    Color color, {
    required bool isSelected,
    required List<String> features,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = title;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: isSelected ? color : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: features
                        .map((f) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                f,
                                style: TextStyle(
                                    fontSize: 10,
                                    color: color,
                                    fontWeight: FontWeight.w500),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }

  // Step 2: Source Account Selection
  Widget _buildSourceAccountStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transfer From',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Select the account you want to transfer from',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        ..._userAccounts.map((account) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildAccountCard(account),
            )),
      ],
    );
  }

  Widget _buildAccountCard(Map<String, dynamic> account) {
    final isSelected = _selectedSourceAccount == account['id'];
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSourceAccount = account['id'];
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: Border.all(
            color: isSelected ? AppColors.accent : AppColors.glassBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(account['icon'] as IconData,
                  color: AppColors.accent, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account['name'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          isSelected ? AppColors.accent : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account['number'] as String,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.positive.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      account['type'] as String,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.positive,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'RM ${(account['balance'] as double).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Available',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (isSelected)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Step 3: Recipient Selection
  Widget _buildRecipientStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transfer To',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Favourites Section
        if (_selectedFavourite == null) ...[
          const Text(
            '⭐ Favourite Recipients',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Search field
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search favourites...',
              prefixIcon: const Icon(Icons.search,
                  color: AppColors.textSecondary, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Favourites grid
          if (_filteredFavourites.isNotEmpty) ...[
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _filteredFavourites.length,
                itemBuilder: (context, index) {
                  final favourite = _filteredFavourites[index];
                  return Padding(
                    padding: EdgeInsets.only(
                        right: index < _filteredFavourites.length - 1
                            ? AppSpacing.sm
                            : 0),
                    child: _buildFavouriteChip(favourite),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'No favourites found',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          const Divider(color: AppColors.glassBorder),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Or enter new recipient',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ] else ...[
          // Selected favourite display
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.accent,
                  child: Text(
                    _selectedFavourite!['avatar']!,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedFavourite!['name']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${_selectedFavourite!['bank']} • ${_selectedFavourite!['accountNumber']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _clearFavouriteSelection,
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Bank selection
        if (_selectedFavourite == null) ...[
          const Text(
            'Recipient Bank',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildBankDropdown(),
          const SizedBox(height: AppSpacing.md),

          // Account number
          const Text(
            'Account Number',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _accountNumberController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Enter account number',
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Recipient name
          const Text(
            'Recipient Name',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _recipientNameController,
            decoration: InputDecoration(
              hintText: 'Enter recipient name',
              filled: true,
              fillColor: AppColors.cardBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFavouriteChip(Map<String, String> favourite) {
    return GestureDetector(
      onTap: () => _selectFavourite(favourite),
      child: Container(
        width: 85,
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.accent.withOpacity(0.15),
              child: Text(
                favourite['avatar']!,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              favourite['nickname'] ?? favourite['name']!.split(' ').first,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              favourite['bank']!.split(' ').first,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedBank,
          isExpanded: true,
          hint: const Text('Select bank'),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: _malaysianBanks.map((bank) {
            return DropdownMenuItem<String>(
              value: bank['name'] as String,
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: (bank['color'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Image.asset(
                      bank['logo'] as String,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.account_balance,
                          color: bank['color'] as Color,
                          size: 20,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(bank['name'] as String),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedBank = value;
            });
          },
        ),
      ),
    );
  }

  // Build balance preview widget with remaining balance after deduction
  Widget _buildBalancePreview(Map<String, dynamic> sourceAccount) {
    final currentBalance = sourceAccount['balance'] as double;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final remainingBalance = currentBalance - amount;
    final isInsufficient = amount > currentBalance;
    final hasAmount = amount > 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isInsufficient
            ? AppColors.negative.withOpacity(0.1)
            : AppColors.positive.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isInsufficient
              ? AppColors.negative.withOpacity(0.3)
              : AppColors.positive.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    color: isInsufficient
                        ? AppColors.negative
                        : AppColors.positive,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Current Balance',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Text(
                'RM ${currentBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (hasAmount) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.glassBorder),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.remove_circle_outline,
                      color: AppColors.negative,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Transfer Amount',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Text(
                  '- RM ${amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.negative,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isInsufficient
                    ? AppColors.negative.withOpacity(0.15)
                    : AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isInsufficient ? Icons.warning_amber : Icons.savings,
                        color: isInsufficient
                            ? AppColors.negative
                            : AppColors.accent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isInsufficient
                            ? 'Insufficient Balance'
                            : 'Remaining Balance',
                        style: TextStyle(
                          color: isInsufficient
                              ? AppColors.negative
                              : AppColors.accent,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'RM ${remainingBalance.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isInsufficient
                          ? AppColors.negative
                          : AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Step 4: Amount Entry
  Widget _buildAmountStep() {
    final sourceAccount = _userAccounts.firstWhere(
      (acc) => acc['id'] == _selectedSourceAccount,
      orElse: () => _userAccounts.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Amount',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Transfer summary card
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('From:',
                      style: TextStyle(color: AppColors.textSecondary)),
                  Text(
                    sourceAccount['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('To:',
                      style: TextStyle(color: AppColors.textSecondary)),
                  Text(
                    _recipientNameController.text,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bank:',
                      style: TextStyle(color: AppColors.textSecondary)),
                  Text(
                    _selectedBank ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Method:',
                      style: TextStyle(color: AppColors.textSecondary)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectedPaymentMethod,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Available balance indicator with preview after deduction
        _buildBalancePreview(sourceAccount),
        const SizedBox(height: AppSpacing.md),

        // Amount input
        TextField(
          autofocus: true,
          controller: _amountController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: AppTextStyles.displayMedium,
          onChanged: (value) {
            // Trigger rebuild to update balance preview
            setState(() {});
          },
          decoration: InputDecoration(
            prefixText: '${widget.currencySymbol} ',
            hintText: '0.00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.softPurple),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.accent, width: 2),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Quick amounts
        const Text(
          'Quick Amount',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _quickAmounts.map((amount) {
            final isSelected = _amountController.text == amount;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _amountController.text = amount;
                  // Move cursor to end of text
                  _amountController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _amountController.text.length),
                  );
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accent : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color:
                        isSelected ? AppColors.accent : AppColors.glassBorder,
                  ),
                ),
                child: Text(
                  'RM $amount',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Description (optional)
        const Text(
          'Description (Optional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _descriptionController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Add a note for this transfer',
            filled: true,
            fillColor: AppColors.cardBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.accent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: _currentStep > 0 ? 2 : 1,
              child: PrimaryButton(
                text: _currentStep == 3 ? 'Transfer Now' : 'Continue',
                isLoading: _isLoading,
                onPressed: _canProceedToNextStep()
                    ? (_currentStep == 3 ? _initiateTransfer : _nextStep)
                    : null,
                backgroundColor: _canProceedToNextStep()
                    ? AppColors.accent
                    : AppColors.textLight,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBiometricPrompt({
    required BuildContext context,
    required String userRole,
    required VoidCallback onAuthenticated,
    required VoidCallback onPasswordSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) => _BiometricSheet(
        role: userRole,
        onSuccess: onAuthenticated,
        onUsePassword: onPasswordSelected,
      ),
    );
  }

  void _showPasswordPrompt(BuildContext context) {
    final passwordController = TextEditingController();
    String? errorText;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Enter Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: passwordController,
                  autofocus: true,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    errorText: errorText,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() => _isLoading = false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final password = passwordController.text;

                  if (password.isEmpty) {
                    setDialogState(() {
                      errorText = 'Password cannot be empty';
                    });
                    return;
                  }
                  if (password.length < 4) {
                    setDialogState(() {
                      errorText = 'Minimum length is 4 characters';
                    });
                    return;
                  }

                  Navigator.pop(ctx);
                  _completeTransfer();
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        });
      },
    );
  }
}

class _BiometricSheet extends StatefulWidget {
  final String role;
  final VoidCallback onSuccess;
  final VoidCallback onUsePassword;

  const _BiometricSheet({
    required this.role,
    required this.onSuccess,
    required this.onUsePassword,
  });

  @override
  State<_BiometricSheet> createState() => _BiometricSheetState();
}

class _BiometricSheetState extends State<_BiometricSheet> {
  int _stage = 0;
  String _statusText = 'Scanning Face ID...';

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _startSimulation() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _stage = 1;
      _statusText = 'Place Finger on Sensor...';
    });
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _stage = 2;
      _statusText = 'Verified';
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 24),
          Text('${widget.role} Verification',
              style: AppTextStyles.headlineSmall),
          const SizedBox(height: 32),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBiometricIcon(Icons.face,
                    isActive: _stage == 0, isDone: _stage > 0),
                Container(
                    width: 40,
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: AppColors.glassBorder),
                _buildBiometricIcon(Icons.fingerprint,
                    isActive: _stage == 1, isDone: _stage > 1),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(_statusText,
              style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.accent, fontWeight: FontWeight.w600)),
          const SizedBox(height: 32),
          TextButton(
            onPressed: widget.onUsePassword,
            child: Text('Use Password Instead',
                style: AppTextStyles.buttonMedium
                    .copyWith(color: AppColors.textSecondary)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBiometricIcon(IconData icon,
      {required bool isActive, required bool isDone}) {
    Color color = isDone
        ? AppColors.positive
        : (isActive ? AppColors.accent : AppColors.textLight.withOpacity(0.3));
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 80 : 60,
      height: isActive ? 80 : 60,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: isActive
            ? [
                BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2)
              ]
            : [],
      ),
      child: Icon(isDone ? Icons.check : icon,
          color: color, size: isActive ? 40 : 30),
    );
  }
}
