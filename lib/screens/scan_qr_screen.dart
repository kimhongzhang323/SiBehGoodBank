import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';

/// QR Scanner screen for scanning payment QR codes.
/// 
/// Features:
/// - Camera viewfinder with alignment frame
/// - Flashlight toggle
/// - Upload image to scan QR code
/// - Biometric/password authentication after scanning
/// - Transaction approval/rejection feedback
class ScanQrScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const ScanQrScreen({super.key, this.onBackToHome});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> with WidgetsBindingObserver {
  MobileScannerController? _scannerController;
  bool _isFlashOn = false;
  bool _isScanning = true;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initScanner();
  }

  void _initScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_scannerController == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _scannerController?.start();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        _scannerController?.stop();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scannerController?.dispose();
    super.dispose();
  }

  void _toggleFlash() async {
    if (_scannerController == null) return;
    
    await _scannerController!.toggleTorch();
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  Future<void> _pickImageAndScan() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return;
    
    setState(() => _isScanning = false);
    
    // Analyze the picked image for QR codes
    final result = await _scannerController?.analyzeImage(image.path);
    
    if (result != null && result.barcodes.isNotEmpty) {
      final barcode = result.barcodes.first;
      _handleQrCodeScanned(barcode.rawValue ?? '');
    } else {
      // No QR code found in image
      if (!mounted) return;
      _showErrorDialog(
        'No QR Code Found',
        'The selected image does not contain a valid QR code. Please try another image.',
      );
      setState(() => _isScanning = true);
    }
  }

  void _onQrDetected(BarcodeCapture capture) {
    if (_hasScanned || !_isScanning) return;
    
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;
    
    setState(() {
      _hasScanned = true;
      _isScanning = false;
    });
    
    // Provide haptic feedback
    HapticFeedback.mediumImpact();
    
    _handleQrCodeScanned(barcode.rawValue!);
  }

  void _handleQrCodeScanned(String qrData) {
    // Stop the scanner
    _scannerController?.stop();
    
    // Parse QR data (supports DuitNow and generic QR codes)
    final paymentInfo = _parseQrData(qrData);
    
    // If no amount specified, show amount entry screen first
    if (paymentInfo['amount'] == null || paymentInfo['amount'] == '0.00') {
      _showAmountEntry(paymentInfo);
    } else {
      // Show payment confirmation directly
      _showPaymentConfirmation(paymentInfo);
    }
  }

  Map<String, dynamic> _parseQrData(String qrData) {
    // Try to parse DuitNow QR format
    // DuitNow QR codes typically follow EMVCo format with TLV (Tag-Length-Value)
    // Common tags:
    // 00 - Payload Format Indicator
    // 01 - Point of Initiation Method
    // 26-51 - Merchant Account Information
    // 52 - Merchant Category Code
    // 53 - Transaction Currency
    // 54 - Transaction Amount
    // 58 - Country Code
    // 59 - Merchant Name
    // 60 - Merchant City
    // 62 - Additional Data Field Template
    
    String? merchantName;
    String? merchantId;
    String? amount;
    String? reference;
    
    // Check if it's an EMVCo QR (starts with "00" followed by version)
    if (qrData.startsWith('00')) {
      try {
        // Parse TLV format
        int index = 0;
        while (index < qrData.length - 4) {
          final tag = qrData.substring(index, index + 2);
          final lengthStr = qrData.substring(index + 2, index + 4);
          final length = int.tryParse(lengthStr) ?? 0;
          
          if (length <= 0 || index + 4 + length > qrData.length) break;
          
          final value = qrData.substring(index + 4, index + 4 + length);
          
          switch (tag) {
            case '54': // Transaction Amount
              amount = value;
              break;
            case '59': // Merchant Name
              merchantName = value;
              break;
            case '60': // Merchant City - can use as secondary identifier
              merchantId = value;
              break;
          }
          
          index += 4 + length;
        }
      } catch (e) {
        // Parsing failed, use fallback
      }
    }
    
    // Fallback for non-EMVCo QR codes or if parsing failed
    // Check for URL-style QR codes
    if (merchantName == null && qrData.contains('://')) {
      final uri = Uri.tryParse(qrData);
      if (uri != null) {
        merchantName = uri.host.replaceAll('www.', '').split('.').first;
        merchantName = merchantName[0].toUpperCase() + merchantName.substring(1);
        amount = uri.queryParameters['amount'];
        reference = uri.queryParameters['ref'] ?? uri.queryParameters['reference'];
      }
    }
    
    // Final fallback - use QR data as reference
    return {
      'merchantName': merchantName ?? _extractMerchantName(qrData),
      'merchantId': merchantId ?? 'QR-${qrData.hashCode.abs().toString().substring(0, 6)}',
      'amount': amount ?? (qrData.length < 20 && double.tryParse(qrData) != null ? qrData : null),
      'currency': 'MYR',
      'reference': reference ?? 'TXN${DateTime.now().millisecondsSinceEpoch}',
      'rawData': qrData,
    };
  }
  
  String _extractMerchantName(String qrData) {
    // Try to extract a readable name from QR data
    // If it contains alphabetic sequences, use that
    final nameMatch = RegExp(r'[A-Za-z][A-Za-z\s]{2,20}').firstMatch(qrData);
    if (nameMatch != null) {
      return nameMatch.group(0)!.trim();
    }
    // Otherwise generate a generic name
    return 'Merchant ${qrData.hashCode.abs() % 1000}';
  }

  void _showAmountEntry(Map<String, dynamic> paymentInfo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AmountEntrySheet(
        paymentInfo: paymentInfo,
        onConfirm: (amount) {
          Navigator.pop(context);
          paymentInfo['amount'] = amount;
          _showPaymentConfirmation(paymentInfo);
        },
        onCancel: () {
          Navigator.pop(context);
          _resetScanner();
        },
      ),
    );
  }

  void _showPaymentConfirmation(Map<String, dynamic> paymentInfo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) => _PaymentConfirmationSheet(
        paymentInfo: paymentInfo,
        onConfirm: () {
          Navigator.pop(context);
          _startBiometricAuthentication(paymentInfo);
        },
        onCancel: () {
          Navigator.pop(context);
          _resetScanner();
        },
      ),
    );
  }

  void _startBiometricAuthentication(Map<String, dynamic> paymentInfo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) => _BiometricAuthSheet(
        onSuccess: () {
          Navigator.pop(context);
          _showTransactionResult(true, paymentInfo);
        },
        onFallbackToPassword: () {
          Navigator.pop(context);
          _showPasswordAuthentication(paymentInfo);
        },
      ),
    );
  }

  void _showPasswordAuthentication(Map<String, dynamic> paymentInfo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) => _PasswordAuthSheet(
        onSuccess: () {
          Navigator.pop(context);
          _showTransactionResult(true, paymentInfo);
        },
        onFailure: () {
          Navigator.pop(context);
          _showTransactionResult(false, paymentInfo);
        },
      ),
    );
  }

  void _showTransactionResult(bool success, Map<String, dynamic> paymentInfo) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _TransactionResultDialog(
        success: success,
        paymentInfo: paymentInfo,
        onOkay: () {
          Navigator.pop(context);
          if (widget.onBackToHome != null) {
            widget.onBackToHome!();
          } else {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        ),
        title: Text(title, style: AppTextStyles.headlineSmall),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: AppTextStyles.buttonMedium.copyWith(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  void _resetScanner() {
    setState(() {
      _hasScanned = false;
      _isScanning = true;
    });
    _scannerController?.start();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final scanAreaSize = screenSize.width * 0.7;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          if (_scannerController != null)
            MobileScanner(
              controller: _scannerController!,
              onDetect: _onQrDetected,
            ),

          // Dark overlay with transparent center
          _buildScanOverlay(scanAreaSize),

          // Scan frame corners
          Center(
            child: _buildScanFrame(scanAreaSize),
          ),

          // Top bar with back button and title
          _buildTopBar(),

          // Bottom controls
          _buildBottomControls(),

          // Scanning indicator
          if (_isScanning)
            Center(
              child: SizedBox(
                width: scanAreaSize,
                height: scanAreaSize,
                child: _ScanningAnimation(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScanOverlay(double scanAreaSize) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final centerX = constraints.maxWidth / 2;
        final centerY = constraints.maxHeight / 2;

        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: _ScanOverlayPainter(
            scanRect: Rect.fromCenter(
              center: Offset(centerX, centerY),
              width: scanAreaSize,
              height: scanAreaSize,
            ),
          ),
        );
      },
    );
  }

  Widget _buildScanFrame(double size) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ScanFramePainter(),
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back button
            GestureDetector(
              onTap: widget.onBackToHome ?? () => Navigator.pop(context),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            // Title
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              ),
              child: const Text(
                'Scan QR Code',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Placeholder for alignment
            const SizedBox(width: 44),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xxl,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Instructions
            const Text(
              'Align QR code within the frame',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Flashlight button
                _ControlButton(
                  icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
                  label: 'Flash',
                  isActive: _isFlashOn,
                  onTap: _toggleFlash,
                ),
                // Upload image button
                _ControlButton(
                  icon: Icons.image_outlined,
                  label: 'Upload',
                  onTap: _pickImageAndScan,
                ),
                // Demo button for testing
                _ControlButton(
                  icon: Icons.play_circle_outline,
                  label: 'Demo',
                  onTap: _simulateDemoScan,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Simulates scanning a DuitNow QR code for testing purposes
  void _simulateDemoScan() {
    if (_hasScanned) return;
    
    setState(() {
      _hasScanned = true;
      _isScanning = false;
    });
    
    HapticFeedback.mediumImpact();
    
    // Simulate a DuitNow-style QR code data
    // This simulates a payment to "Kopitiam Mak Cik"
    const demoQrData = '00020101021126530010com.duitnow0111MY1234567890203ABC5204599953033605802MY5915Kopitiam Mak Cik6012Kuala Lumpur6304ABCD';
    
    _handleQrCodeScanned(demoQrData);
  }
}

/// Control button for flashlight and upload
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.accent.withOpacity(0.3)
                  : Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive ? AppColors.accent : Colors.white30,
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? AppColors.accent : Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.accent : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Scanning animation (moving line)
class _ScanningAnimation extends StatefulWidget {
  @override
  State<_ScanningAnimation> createState() => _ScanningAnimationState();
}

class _ScanningAnimationState extends State<_ScanningAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          painter: _ScanLinePainter(_animation.value),
        );
      },
    );
  }
}

/// Overlay painter that darkens everything except the scan area
class _ScanOverlayPainter extends CustomPainter {
  final Rect scanRect;

  _ScanOverlayPainter({required this.scanRect});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withOpacity(0.6);

    // Draw the full screen
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Cut out the scan area with rounded corners
    final scanPath = Path()
      ..addRRect(RRect.fromRectAndRadius(scanRect, const Radius.circular(20)));

    // Combine paths using difference
    final combinedPath = Path.combine(PathOperation.difference, path, scanPath);

    canvas.drawPath(combinedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ScanOverlayPainter oldDelegate) =>
      scanRect != oldDelegate.scanRect;
}

/// Frame painter for scan area corners
class _ScanFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    const cornerLength = 30.0;
    const radius = 20.0;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(0, cornerLength)
        ..lineTo(0, radius)
        ..quadraticBezierTo(0, 0, radius, 0)
        ..lineTo(cornerLength, 0),
      paint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, 0)
        ..lineTo(size.width - radius, 0)
        ..quadraticBezierTo(size.width, 0, size.width, radius)
        ..lineTo(size.width, cornerLength),
      paint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height - cornerLength)
        ..lineTo(0, size.height - radius)
        ..quadraticBezierTo(0, size.height, radius, size.height)
        ..lineTo(cornerLength, size.height),
      paint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(size.width - cornerLength, size.height)
        ..lineTo(size.width - radius, size.height)
        ..quadraticBezierTo(size.width, size.height, size.width, size.height - radius)
        ..lineTo(size.width, size.height - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Scan line painter for animation
class _ScanLinePainter extends CustomPainter {
  final double progress;

  _ScanLinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.accent.withOpacity(0.8),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 4));

    final y = size.height * progress;
    canvas.drawRect(
      Rect.fromLTWH(10, y, size.width - 20, 3),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) =>
      progress != oldDelegate.progress;
}

/// Amount entry sheet for QR codes without specified amount
class _AmountEntrySheet extends StatefulWidget {
  final Map<String, dynamic> paymentInfo;
  final Function(String amount) onConfirm;
  final VoidCallback onCancel;

  const _AmountEntrySheet({
    required this.paymentInfo,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  State<_AmountEntrySheet> createState() => _AmountEntrySheetState();
}

class _AmountEntrySheetState extends State<_AmountEntrySheet> {
  final _amountController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _validateAndProceed() {
    final text = _amountController.text.trim();
    
    if (text.isEmpty) {
      setState(() => _errorText = 'Please enter an amount');
      return;
    }
    
    final amount = double.tryParse(text);
    if (amount == null || amount <= 0) {
      setState(() => _errorText = 'Please enter a valid amount');
      return;
    }
    
    if (amount > 10000) {
      setState(() => _errorText = 'Maximum amount is MYR 10,000');
      return;
    }
    
    widget.onConfirm(amount.toStringAsFixed(2));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            const Text(
              'Enter Payment Amount',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Merchant info
            GlassCard(
              backgroundColor: AppColors.cardBackgroundAlt,
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.pastelBlue,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(
                      Icons.store,
                      color: AppColors.accent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.paymentInfo['merchantName'] ?? 'Merchant',
                          style: AppTextStyles.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.paymentInfo['merchantId'] ?? '',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: AppSpacing.lg),

            // Amount input
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: AppTextStyles.displayMedium,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                prefixText: 'MYR ',
                prefixStyle: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                hintText: '0.00',
                hintStyle: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.textLight,
                ),
                errorText: _errorText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(color: AppColors.softPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(color: AppColors.accent, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
              onChanged: (_) {
                if (_errorText != null) {
                  setState(() => _errorText = null);
                }
              },
              onSubmitted: (_) => _validateAndProceed(),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    text: 'Cancel',
                    onPressed: widget.onCancel,
                    backgroundColor: AppColors.cardBackground,
                    textColor: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: PrimaryButton(
                    text: 'Continue',
                    onPressed: _validateAndProceed,
                    backgroundColor: AppColors.accent,
                    textColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

/// Payment confirmation sheet
class _PaymentConfirmationSheet extends StatelessWidget {
  final Map<String, dynamic> paymentInfo;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const _PaymentConfirmationSheet({
    required this.paymentInfo,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Title
          const Text(
            'Confirm Payment',
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Merchant info
          GlassCard(
            backgroundColor: AppColors.cardBackgroundAlt,
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppColors.pastelBlue,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: const Icon(
                        Icons.store,
                        color: AppColors.accent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            paymentInfo['merchantName'] ?? 'Unknown Merchant',
                            style: AppTextStyles.titleLarge,
                          ),
                          Text(
                            paymentInfo['merchantId'] ?? '',
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Amount',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${paymentInfo['currency']} ${paymentInfo['amount']}',
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Buttons
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  text: 'Cancel',
                  onPressed: onCancel,
                  backgroundColor: AppColors.cardBackground,
                  textColor: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PrimaryButton(
                  text: 'Pay Now',
                  onPressed: onConfirm,
                  backgroundColor: AppColors.accent,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

/// Biometric authentication sheet
class _BiometricAuthSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onFallbackToPassword;

  const _BiometricAuthSheet({
    required this.onSuccess,
    required this.onFallbackToPassword,
  });

  @override
  State<_BiometricAuthSheet> createState() => _BiometricAuthSheetState();
}

class _BiometricAuthSheetState extends State<_BiometricAuthSheet> {
  int _stage = 0; // 0: Scanning Face, 1: Scanning Fingerprint, 2: Success
  String _statusText = 'Scanning Face ID...';
  int _failedAttempts = 0;

  @override
  void initState() {
    super.initState();
    _startBiometricSimulation();
  }

  void _startBiometricSimulation() async {
    // Simulate Face ID
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Simulate random success/failure for demo
    final success = DateTime.now().second % 3 != 0; // 66% success rate

    if (success) {
      setState(() {
        _stage = 1;
        _statusText = 'Place Finger on Sensor...';
      });

      // Simulate Fingerprint
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;

      setState(() {
        _stage = 2;
        _statusText = 'Verified Successfully!';
      });

      // Complete
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      widget.onSuccess();
    } else {
      _failedAttempts++;
      if (_failedAttempts >= 3) {
        // Fall back to password after 3 failed attempts
        setState(() {
          _statusText = 'Biometric failed. Using password...';
        });
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        widget.onFallbackToPassword();
      } else {
        setState(() {
          _statusText = 'Try again (${3 - _failedAttempts} attempts left)';
        });
        await Future.delayed(const Duration(seconds: 1));
        if (!mounted) return;
        setState(() {
          _stage = 0;
          _statusText = 'Scanning Face ID...';
        });
        _startBiometricSimulation();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          const Text(
            'Verify Your Identity',
            style: AppTextStyles.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Biometric Icons Animation
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBiometricIcon(
                  Icons.face,
                  isActive: _stage == 0,
                  isDone: _stage > 0,
                ),
                Container(
                  width: 40,
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: AppColors.glassBorder,
                ),
                _buildBiometricIcon(
                  Icons.fingerprint,
                  isActive: _stage == 1,
                  isDone: _stage > 1,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          Text(
            _statusText,
            style: AppTextStyles.bodyLarge.copyWith(
              color: _stage == 2 ? AppColors.positive : AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          TextButton(
            onPressed: widget.onFallbackToPassword,
            child: Text(
              'Use Password Instead',
              style: AppTextStyles.buttonMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Widget _buildBiometricIcon(IconData icon, {required bool isActive, required bool isDone}) {
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
        border: Border.all(color: color, width: 2),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
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

/// Password authentication sheet
class _PasswordAuthSheet extends StatefulWidget {
  final VoidCallback onSuccess;
  final VoidCallback onFailure;

  const _PasswordAuthSheet({
    required this.onSuccess,
    required this.onFailure,
  });

  @override
  State<_PasswordAuthSheet> createState() => _PasswordAuthSheetState();
}

class _PasswordAuthSheetState extends State<_PasswordAuthSheet> {
  final _passwordController = TextEditingController();
  int _failedAttempts = 0;
  bool _isLoading = false;
  String? _errorText;
  bool _obscureText = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _verifyPassword() async {
    if (_passwordController.text.isEmpty) {
      setState(() => _errorText = 'Please enter your password');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    // Simulate verification
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // Mock password check - accept "123456" as valid
    if (_passwordController.text == '123456') {
      widget.onSuccess();
    } else {
      _failedAttempts++;
      if (_failedAttempts >= 3) {
        widget.onFailure();
      } else {
        setState(() {
          _isLoading = false;
          _errorText = 'Wrong password (${3 - _failedAttempts} attempts left)';
          _passwordController.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            const Text(
              'Enter Password',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Biometric verification failed. Please enter your password.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Password field
            TextField(
              controller: _passwordController,
              obscureText: _obscureText,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Enter password',
                errorText: _errorText,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(color: AppColors.softPurple),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(color: AppColors.accent, width: 2),
                ),
              ),
              onSubmitted: (_) => _verifyPassword(),
            ),
            const SizedBox(height: AppSpacing.xl),

            PrimaryButton(
              text: 'Verify',
              isLoading: _isLoading,
              onPressed: _verifyPassword,
              backgroundColor: AppColors.accent,
              textColor: Colors.white,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

/// Transaction result dialog
class _TransactionResultDialog extends StatelessWidget {
  final bool success;
  final Map<String, dynamic> paymentInfo;
  final VoidCallback onOkay;

  const _TransactionResultDialog({
    required this.success,
    required this.paymentInfo,
    required this.onOkay,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: (success ? AppColors.positive : AppColors.negative)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                success ? Icons.check_circle : Icons.cancel,
                size: 50,
                color: success ? AppColors.positive : AppColors.negative,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              success ? 'Payment Successful!' : 'Payment Failed',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Description
            Text(
              success
                  ? 'Your payment of ${paymentInfo['currency']} ${paymentInfo['amount']} to ${paymentInfo['merchantName']} was successful.'
                  : 'Your payment could not be completed due to authentication failure. Please try again.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            if (success) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  'Ref: ${paymentInfo['reference']}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            // OK button
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: 'Okay',
                onPressed: onOkay,
                backgroundColor: success ? AppColors.positive : AppColors.accent,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
