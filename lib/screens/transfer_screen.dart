import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';
import 'transfer_receipt_screen.dart';

// Recent contact model
class RecentContact {
  final String name;
  final String accountNumber;
  final String avatarColor;
  final IconData icon;

  const RecentContact({
    required this.name,
    required this.accountNumber,
    required this.avatarColor,
    this.icon = Icons.person,
  });
}

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
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  
  // Selected recipient
  RecentContact? _selectedRecipient;
  
  // Recent contacts list
  static const List<RecentContact> _recentContacts = [
    RecentContact(
      name: 'John Doe',
      accountNumber: '**** 4589',
      avatarColor: 'blue',
    ),
    RecentContact(
      name: 'Sarah Lim',
      accountNumber: '**** 7823',
      avatarColor: 'pink',
    ),
    RecentContact(
      name: 'Ahmad Razak',
      accountNumber: '**** 1256',
      avatarColor: 'green',
    ),
    RecentContact(
      name: 'Michelle Tan',
      accountNumber: '**** 9034',
      avatarColor: 'purple',
    ),
    RecentContact(
      name: 'David Wong',
      accountNumber: '**** 5567',
      avatarColor: 'orange',
    ),
    RecentContact(
      name: 'Priya Kumar',
      accountNumber: '**** 3321',
      avatarColor: 'teal',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Set default recipient
    _selectedRecipient = _recentContacts.first;
    // Set default description
    _descriptionController.text = 'Transfer';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Color _getAvatarColor(String colorName) {
    switch (colorName) {
      case 'blue':
        return AppColors.pastelBlue;
      case 'pink':
        return const Color(0xFFFFD6E0);
      case 'green':
        return const Color(0xFFD4EDDA);
      case 'purple':
        return AppColors.softPurple;
      case 'orange':
        return const Color(0xFFFFE5D0);
      case 'teal':
        return const Color(0xFFD0F0F0);
      default:
        return AppColors.pastelBlue;
    }
  }

  Color _getIconColor(String colorName) {
    switch (colorName) {
      case 'blue':
        return AppColors.accentBlue;
      case 'pink':
        return const Color(0xFFE91E63);
      case 'green':
        return const Color(0xFF28A745);
      case 'purple':
        return AppColors.accent;
      case 'orange':
        return const Color(0xFFFF9800);
      case 'teal':
        return const Color(0xFF009688);
      default:
        return AppColors.accentBlue;
    }
  }

  void _initiateTransfer() {
    // 1. Error Handling: Empty Input
    if (_amountController.text.isEmpty) {
      _showError('Please enter an amount.');
      return;
    }

    // 2. Error Handling: Invalid Amount
    final value = double.tryParse(_amountController.text);
    if (value == null || value <= 0) {
      _showError('Please enter a valid amount greater than 0.');
      return;
    }

    setState(() => _isLoading = true);

    _showBiometricPrompt(
        context: context,
        userRole: 'Sender',
        onAuthenticated: () {
          Navigator.pop(context); // Close Sender Prompt
          _completeTransfer();
        },
        onPasswordSelected: () {
          Navigator.pop(context); // Close Biometric Sheet
          _showPasswordPrompt(context, 'Sender');
        });
  }

  void _completeTransfer() {
    setState(() => _isLoading = false);

    final recipient = _selectedRecipient ?? _recentContacts.first;
    final description = _descriptionController.text.isEmpty 
        ? 'Transfer' 
        : _descriptionController.text;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TransferReceiptScreen(
          amount: _amountController.text,
          currencySymbol: widget.currencySymbol,
          recipientName: recipient.name,
          recipientAccount: recipient.accountNumber,
          description: description,
          isReceiving: false,
          onDone: widget.onBackToHome,
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Transfer Money', style: AppTextStyles.headlineSmall),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter Amount', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              autofocus: true,
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.displayMedium,
              decoration: InputDecoration(
                prefixText: '${widget.currencySymbol} ',
                hintText: '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.softPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.accent, width: 2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Description field
            const Text('Description', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _descriptionController,
              style: AppTextStyles.bodyLarge,
              decoration: InputDecoration(
                hintText: 'What is this for?',
                hintStyle: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.softPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.accent, width: 2),
                ),
                prefixIcon: const Icon(Icons.note_outlined, color: AppColors.textSecondary),
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),
            const Text('To', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            
            // Selected recipient card
            if (_selectedRecipient != null)
              GestureDetector(
                onTap: () => _showRecipientSelector(),
                child: GlassCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getAvatarColor(_selectedRecipient!.avatarColor),
                        child: Icon(Icons.person, color: _getIconColor(_selectedRecipient!.avatarColor)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selectedRecipient!.name, style: AppTextStyles.titleMedium),
                            Text(_selectedRecipient!.accountNumber, style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Recent transfers section
            const Text('Recent Transfers', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recentContacts.length,
                itemBuilder: (context, index) {
                  final contact = _recentContacts[index];
                  final isSelected = _selectedRecipient?.name == contact.name;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedRecipient = contact;
                      });
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: AppSpacing.sm),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: isSelected 
                                  ? Border.all(color: AppColors.accent, width: 3)
                                  : null,
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: _getAvatarColor(contact.avatarColor),
                              child: Icon(
                                Icons.person, 
                                color: _getIconColor(contact.avatarColor),
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            contact.name.split(' ').first,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.accent : AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: AppSpacing.xl),
            PrimaryButton(
              text: 'Transfer',
              isLoading: _isLoading,
              onPressed: _initiateTransfer,
              backgroundColor: AppColors.accent,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  void _showRecipientSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const Text('Select Recipient', style: AppTextStyles.headlineSmall),
            const SizedBox(height: AppSpacing.lg),
            ..._recentContacts.map((contact) => ListTile(
              leading: CircleAvatar(
                backgroundColor: _getAvatarColor(contact.avatarColor),
                child: Icon(Icons.person, color: _getIconColor(contact.avatarColor)),
              ),
              title: Text(contact.name, style: AppTextStyles.titleMedium),
              subtitle: Text(contact.accountNumber, style: AppTextStyles.bodySmall),
              trailing: _selectedRecipient?.name == contact.name
                  ? const Icon(Icons.check_circle, color: AppColors.accent)
                  : null,
              onTap: () {
                setState(() {
                  _selectedRecipient = contact;
                });
                Navigator.pop(context);
              },
            )),
            const SizedBox(height: AppSpacing.lg),
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
    ).then((_) {
      if (mounted && _isLoading) {
        // If sheet dismissed without explicit action, stop loading is handled
        // by specific callbacks, but purely safe guard here isn't easy without state flags.
        // Reliance on explicit Cancel/Confirm logic below is safer.
      }
    });
  }

  void _showPasswordPrompt(BuildContext context, String userRole) {
    final passwordController = TextEditingController();
    // Using a local variable for error text inside the dialog
    String? errorText;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        // StatefulBuilder allows us to update the Dialog UI (error message)
        // without rebuilding the whole screen
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('$userRole Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: passwordController,
                  autofocus: true,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Enter password',
                    errorText: errorText, // Displays error if set
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // Stop loading on cancel
                  setState(() => _isLoading = false);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final password = passwordController.text;

                  // 3. Password Validation Logic
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

                  // If valid
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

// Reusable Biometric Sheet
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
