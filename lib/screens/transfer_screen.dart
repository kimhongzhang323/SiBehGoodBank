import 'package:flutter/material.dart';
import 'dart:async';
import '../constants/constants.dart';
import '../widgets/widgets.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _amountController = TextEditingController();
  bool _isLoading = false;

  // Simulate the transfer process
  void _initiateTransfer() {
    if (_amountController.text.isEmpty) return;

    setState(() => _isLoading = true);

    // Step 1: Sender Authentication
    _showBiometricPrompt(
        context: context,
        userRole: 'Sender',
        onAuthenticated: () {
          Navigator.pop(context); // Close Sender Prompt

          // Step 2: Receiver Authentication
          Future.delayed(const Duration(milliseconds: 500), () {
            if (!mounted) return;
            _showBiometricPrompt(
              context: context,
              userRole: 'Receiver',
              onAuthenticated: () {
                Navigator.pop(context); // Close Receiver Prompt
                _completeTransfer();
              },
              // FIX: Add the required onPasswordSelected parameter here
              onPasswordSelected: () {
                Navigator.pop(context);
                _showPasswordPrompt(context, 'Receiver');
              },
            );
          });
        },
        onPasswordSelected: () {
          Navigator.pop(context); // Close Sender Prompt
          _showPasswordPrompt(context, 'Sender');
        });
  }

  void _completeTransfer() {
    setState(() => _isLoading = false);
    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppColors.positive, size: 64),
            const SizedBox(height: 16),
            Text('Transfer Successful!', style: AppTextStyles.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '\$${_amountController.text} sent successfully.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              text: 'Done',
              onPressed: () {
                Navigator.of(ctx).pop(); // Close Dialog
                Navigator.of(context).pop(); // Go back to Home
              },
            )
          ],
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
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.displayMedium,
              decoration: InputDecoration(
                prefixText: '\$ ',
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

            // Recipient Mock
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

  // Double-Layer Biometric Prompt Widget
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

  // Fallback Password Prompt
  void _showPasswordPrompt(BuildContext context, String userRole) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$userRole Password'),
        content: const TextField(
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
              // If sender uses password, proceed to receiver
              if (userRole == 'Sender') {
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (!mounted) return;
                  _showBiometricPrompt(
                      context: context,
                      userRole: 'Receiver',
                      onAuthenticated: () {
                        Navigator.pop(context);
                        _completeTransfer();
                      },
                      onPasswordSelected: () {
                        Navigator.pop(context);
                        _completeTransfer(); // Assume receiver password success
                      });
                });
              } else {
                _completeTransfer();
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
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
  int _stage = 0; // 0: Scanning Face, 1: Scanning Fingerprint, 2: Success
  String _statusText = 'Scanning Face ID...';

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _startSimulation() async {
    // Simulate Face ID
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _stage = 1;
      _statusText = 'Place Finger on Sensor...';
    });

    // Simulate Fingerprint
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _stage = 2;
      _statusText = 'Verified';
    });

    // Complete
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
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${widget.role} Verification',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: 32),

          // Biometric Icons Animation
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
                  color: AppColors.glassBorder,
                ),
                _buildBiometricIcon(Icons.fingerprint,
                    isActive: _stage == 1, isDone: _stage > 1),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text(
            _statusText,
            style: AppTextStyles.bodyLarge
                .copyWith(color: AppColors.accent, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 32),

          TextButton(
            onPressed: widget.onUsePassword,
            child: Text(
              'Use Password Instead',
              style: AppTextStyles.buttonMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildBiometricIcon(IconData icon,
      {required bool isActive, required bool isDone}) {
    Color color;
    if (isDone) {
      color = AppColors.positive;
    } else if (isActive) {
      color = AppColors.accent;
    } else {
      color = AppColors.textLight.withOpacity(0.3);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 80 : 60,
      height: isActive ? 80 : 60,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: 2,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Icon(
        isDone ? Icons.check : icon,
        color: color,
        size: isActive ? 40 : 30,
      ),
    );
  }
}
