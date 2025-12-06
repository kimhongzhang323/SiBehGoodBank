import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';
import '../services/receipt_services.dart';

class TransferReceiptScreen extends StatefulWidget {
  final String amount;
  final String currencySymbol;
  final String recipientName;
  final String recipientAccount;
  final bool isReceiving;

  const TransferReceiptScreen({
    super.key,
    required this.amount,
    required this.currencySymbol,
    required this.recipientName,
    required this.recipientAccount,
    this.isReceiving = false,
  });

  @override
  State<TransferReceiptScreen> createState() => _TransferReceiptScreenState();
}

class _TransferReceiptScreenState extends State<TransferReceiptScreen> {
  // Manual date formatting
  final now = DateTime.now();
  late String dateStr;
  late String timeStr;
  late String refId;

  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    dateStr = "${_getMonth(now.month)} ${now.day}, ${now.year}";
    timeStr =
        "${_formatHour(now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
    refId = 'REF-${now.millisecondsSinceEpoch.toString().substring(5)}';
  }

  Future<void> _handleViewReceipt() async {
    setState(() => _isSharing = true);

    try {
      await ReceiptService.generateAndShowReceipt(
        amount: widget.amount,
        currencySymbol: widget.currencySymbol,
        recipientName: widget.recipientName,
        recipientAccount: widget.recipientAccount,
        dateStr: dateStr,
        timeStr: timeStr,
        refId: refId,
        isReceiving: widget.isReceiving,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to generate receipt: $e"),
            backgroundColor: AppColors.negative,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor =
        widget.isReceiving ? AppColors.positive : AppColors.accent;
    final titleText =
        widget.isReceiving ? 'Money Received' : 'Transfer Successful';
    final amountSign = widget.isReceiving ? '+' : '-';
    final amountColor =
        widget.isReceiving ? AppColors.positive : AppColors.textPrimary;
    final userLabel = widget.isReceiving ? 'From' : 'To';

    return Scaffold(
      body: Stack(
        children: [
          const HolographicBackground(
            child: SizedBox.expand(),
          ),
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding),
                  child: GlassCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(32),
                    backgroundColor: Colors.white, // <--- CHANGED: Set to solid white
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.isReceiving
                                ? Icons.download_rounded
                                : Icons.check_rounded,
                            color: statusColor,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          titleText,
                          style: AppTextStyles.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$amountSign${widget.currencySymbol} ${widget.amount}',
                          style: AppTextStyles.amountLarge.copyWith(
                            color: amountColor,
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Divider(color: AppColors.glassBorder),
                        const SizedBox(height: 24),
                        _buildRow(userLabel, widget.recipientName),
                        const SizedBox(height: 16),
                        _buildRow('Account', widget.recipientAccount),
                        const SizedBox(height: 16),
                        _buildRow('Date', '$dateStr • $timeStr'),
                        const SizedBox(height: 16),
                        _buildRow('Ref ID', refId),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: SecondaryButton(
                                text: 'Receipt',
                                icon: Icons.picture_as_pdf,
                                isLoading: _isSharing,
                                onPressed: _isSharing ? null : _handleViewReceipt,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: PrimaryButton(
                                text: 'Done',
                                backgroundColor: widget.isReceiving
                                    ? AppColors.positive
                                    : AppColors.accent,
                                textColor: Colors.white,
                                onPressed: () {
                                  Navigator.of(context)
                                      .popUntil((route) => route.isFirst);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _getMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  int _formatHour(int hour) {
    if (hour == 0) return 12;
    if (hour > 12) return hour - 12;
    return hour;
  }
}
