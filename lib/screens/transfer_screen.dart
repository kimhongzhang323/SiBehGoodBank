import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';
import 'transfer_receipt_screen.dart';

class TransferScreen extends StatefulWidget {
  final String currencySymbol;

  const TransferScreen({
    super.key,
    required this.currencySymbol,
  });

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _amountController = TextEditingController();
  bool _isLoading = false;

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

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TransferReceiptScreen(
          amount: _amountController.text,
          currencySymbol: widget.currencySymbol,
          recipientName: 'John Doe',
          recipientAccount: '**** 4589',
          isReceiving: false,
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
            const SizedBox(height: AppSpacing.xl),
            const Text('To', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            const GlassCard(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.pastelBlue,
                    child: Icon(Icons.person, color: AppColors.accentBlue),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('John Doe', style: AppTextStyles.titleMedium),
                      Text('**** 4589', style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
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
