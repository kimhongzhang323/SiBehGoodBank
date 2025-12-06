import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';

/// SecureTAC - Transaction Authorization Code service
class SecureTacScreen extends StatefulWidget {
  final String? transactionType;
  final String? transactionAmount;
  final String? recipientInfo;
  final VoidCallback? onVerified;

  const SecureTacScreen({
    super.key,
    this.transactionType,
    this.transactionAmount,
    this.recipientInfo,
    this.onVerified,
  });

  @override
  State<SecureTacScreen> createState() => _SecureTacScreenState();
}

class _SecureTacScreenState extends State<SecureTacScreen>
    with TickerProviderStateMixin {
  final List<TextEditingController> _tacControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  bool _isVerifying = false;
  bool _isVerified = false;
  bool _isError = false;
  int _remainingTime = 180; // 3 minutes
  int _attemptsRemaining = 3;
  late AnimationController _timerController;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _remainingTime),
    )..addListener(() {
        setState(() {
          _remainingTime = (180 * (1 - _timerController.value)).round();
        });
      });
    _timerController.forward();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    for (var controller in _tacControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timerController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  String get _enteredTac =>
      _tacControllers.map((c) => c.text).join();

  void _onTacDigitChanged(int index, String value) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_enteredTac.length == 6) {
      _verifyTac();
    }
    setState(() {
      _isError = false;
    });
  }

  void _onKeyPressed(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _tacControllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  Future<void> _verifyTac() async {
    setState(() {
      _isVerifying = true;
      _isError = false;
    });

    // Simulate verification delay
    await Future.delayed(const Duration(seconds: 2));

    // Demo: TAC "123456" is valid
    if (_enteredTac == '123456') {
      setState(() {
        _isVerifying = false;
        _isVerified = true;
      });
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        widget.onVerified?.call();
        Navigator.of(context).pop(true);
      }
    } else {
      setState(() {
        _isVerifying = false;
        _isError = true;
        _attemptsRemaining--;
      });
      HapticFeedback.vibrate();
      _shakeController.forward(from: 0);
      
      if (_attemptsRemaining <= 0) {
        _showLockedDialog();
      }
    }
  }

  void _showLockedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock, color: AppColors.negative),
            SizedBox(width: 12),
            Text('Account Locked'),
          ],
        ),
        content: const Text(
          'Too many failed attempts. Your SecureTAC has been temporarily locked. Please try again in 30 minutes or contact support.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(false);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _resendTac() {
    HapticFeedback.lightImpact();
    setState(() {
      _remainingTime = 180;
      for (var controller in _tacControllers) {
        controller.clear();
      }
    });
    _timerController.reset();
    _timerController.forward();
    _focusNodes[0].requestFocus();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('New TAC sent to your registered device'),
          ],
        ),
        backgroundColor: AppColors.positive,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _useBiometric() async {
    HapticFeedback.mediumImpact();
    
    // Simulate biometric prompt
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fingerprint,
                size: 48,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Touch sensor to verify',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Use fingerprint to authorize transaction',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Simulate Success'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isVerified = true);
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        widget.onVerified?.call();
        Navigator.of(context).pop(true);
      }
    }
  }

  String get _formattedTime {
    final minutes = _remainingTime ~/ 60;
    final seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        title: const Text(
          'SecureTAC',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              // Security Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accent,
                      AppColors.accent.withOpacity(0.7),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: _isVerified
                    ? const Icon(Icons.check, size: 48, color: Colors.white)
                    : const Icon(Icons.security, size: 48, color: Colors.white),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Transaction Details
              if (widget.transactionType != null) ...[
                GlassCard(
                  child: Column(
                    children: [
                      _buildTransactionRow(
                        'Transaction Type',
                        widget.transactionType!,
                      ),
                      if (widget.transactionAmount != null) ...[
                        const Divider(height: 24),
                        _buildTransactionRow(
                          'Amount',
                          widget.transactionAmount!,
                        ),
                      ],
                      if (widget.recipientInfo != null) ...[
                        const Divider(height: 24),
                        _buildTransactionRow(
                          'Recipient',
                          widget.recipientInfo!,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Instructions
              Text(
                _isVerified
                    ? 'Verification Successful!'
                    : 'Enter the 6-digit TAC sent to your device',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w500,
                  color: _isVerified ? AppColors.positive : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.md),

              // Timer
              if (!_isVerified) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _remainingTime < 60
                        ? AppColors.negative.withOpacity(0.1)
                        : AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        size: 18,
                        color: _remainingTime < 60
                            ? AppColors.negative
                            : AppColors.accent,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Expires in $_formattedTime',
                        style: TextStyle(
                          color: _remainingTime < 60
                              ? AppColors.negative
                              : AppColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // TAC Input Fields
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        _shakeController.isAnimating
                            ? _shakeAnimation.value *
                                ((_shakeController.value * 10).round() % 2 == 0
                                    ? 1
                                    : -1)
                            : 0,
                        0,
                      ),
                      child: child,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Container(
                        width: 48,
                        height: 56,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: RawKeyboardListener(
                          focusNode: FocusNode(),
                          onKey: (event) => _onKeyPressed(index, event),
                          child: TextField(
                            controller: _tacControllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: _isError
                                  ? AppColors.negative.withOpacity(0.1)
                                  : Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _isError
                                      ? AppColors.negative
                                      : Colors.grey[300]!,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _isError
                                      ? AppColors.negative
                                      : Colors.grey[300]!,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: _isError
                                      ? AppColors.negative
                                      : AppColors.accent,
                                  width: 2,
                                ),
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) =>
                                _onTacDigitChanged(index, value),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                if (_isError) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Invalid TAC. $_attemptsRemaining attempt${_attemptsRemaining == 1 ? '' : 's'} remaining.',
                    style: const TextStyle(
                      color: AppColors.negative,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),

                // Verify Button
                if (_isVerifying)
                  const CircularProgressIndicator(color: AppColors.accent)
                else
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: 'Verify TAC',
                      onPressed: _enteredTac.length == 6 ? _verifyTac : null,
                    ),
                  ),

                const SizedBox(height: AppSpacing.lg),

                // Alternative Options
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton.icon(
                      onPressed: _resendTac,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Resend TAC'),
                    ),
                    const SizedBox(width: 16),
                    TextButton.icon(
                      onPressed: _useBiometric,
                      icon: const Icon(Icons.fingerprint, size: 18),
                      label: const Text('Use Biometric'),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: AppSpacing.xl),

              // Security Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Never share your TAC with anyone. SibehGood Bank will never ask for your TAC via phone or email.',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                        ),
                      ),
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

  Widget _buildTransactionRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
