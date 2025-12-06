import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';
import 'transfer_receipt_screen.dart';

class ReceiveScreen extends StatefulWidget {
  final String currencySymbol; // Added currency symbol

  const ReceiveScreen({
    super.key,
    required this.currencySymbol,
  });

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  final _amountController = TextEditingController();
  bool _isLoading = false;

  void _initiateReceive() {
    if (_amountController.text.isEmpty) return;

    setState(() => _isLoading = true);

    // Sender Authentication (on Receive Screen)
    _showBiometricPrompt(
        context: context,
        userRole: 'Sender', // Authenticating the Sender
        onAuthenticated: () {
          Navigator.pop(context);
          _completeReceive();
        },
        onPasswordSelected: () {
          Navigator.pop(context);
          _showPasswordPrompt(context, 'Sender');
        });
  }

  void _completeReceive() {
    setState(() => _isLoading = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => TransferReceiptScreen(
          amount: _amountController.text,
          currencySymbol: widget.currencySymbol, // Pass symbol to receipt
          recipientName: 'Sender Name',
          recipientAccount: '**** 1234',
          isReceiving: true,
        ),
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
        title: const Text('Receive Money', style: AppTextStyles.headlineSmall),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Amount to Receive', style: AppTextStyles.labelLarge),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              autofocus: true,
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.displayMedium,
              decoration: InputDecoration(
                prefixText: '${widget.currencySymbol} ', // Use dynamic symbol
                hintText: '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: AppColors.softPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppColors.positive, width: 2),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Instruction
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.positive.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.positive),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hand device to Sender for authentication to confirm receipt.',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              text: 'Verify & Receive',
              isLoading: _isLoading,
              onPressed: _initiateReceive,
              backgroundColor: AppColors.positive,
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  // Reuse the Biometric UI Logic
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
      builder: (context) => _ReceiveBiometricSheet(
        role: userRole,
        onSuccess: onAuthenticated,
        onUsePassword: onPasswordSelected,
      ),
    );
  }

  void _showPasswordPrompt(BuildContext context, String userRole) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$userRole Password'),
        content: const TextField(
          autofocus: true,
          obscureText: true,
          decoration: InputDecoration(hintText: 'Enter password'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _completeReceive();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _ReceiveBiometricSheet extends StatefulWidget {
  final String role;
  final VoidCallback onSuccess;
  final VoidCallback onUsePassword;

  const _ReceiveBiometricSheet({
    required this.role,
    required this.onSuccess,
    required this.onUsePassword,
  });

  @override
  State<_ReceiveBiometricSheet> createState() => _ReceiveBiometricSheetState();
}

class _ReceiveBiometricSheetState extends State<_ReceiveBiometricSheet> {
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
                _buildIcon(Icons.face, 0),
                Container(
                    width: 40,
                    height: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: AppColors.glassBorder),
                _buildIcon(Icons.fingerprint, 1),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(_statusText,
              style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.positive, fontWeight: FontWeight.w600)),
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

  Widget _buildIcon(IconData icon, int stepIndex) {
    bool isActive = _stage == stepIndex;
    bool isDone = _stage > stepIndex;
    Color color = isDone
        ? AppColors.positive
        : (isActive
            ? AppColors.positive
            : AppColors.textLight.withOpacity(0.3));

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
