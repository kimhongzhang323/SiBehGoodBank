import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';

class TransferReceiptScreen extends StatelessWidget {
  final String amount;
  final String currencySymbol;
  final String recipientName;
  final String recipientAccount;
  final String? description;
  final bool isReceiving;
  final VoidCallback? onDone;

  const TransferReceiptScreen({
    super.key,
    required this.amount,
    required this.currencySymbol,
    required this.recipientName,
    required this.recipientAccount,
    this.description,
    this.isReceiving = false,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    // Manual date formatting
    final now = DateTime.now();
    final dateStr = "${_getMonth(now.month)} ${now.day}, ${now.year}";
    final timeStr =
        "${_formatHour(now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
    final refId = 'REF-${now.millisecondsSinceEpoch.toString().substring(5)}';

    // UI Configuration based on type
    final statusColor = isReceiving ? AppColors.positive : AppColors.accent;
    final titleText = isReceiving ? 'Money Received' : 'Transfer Successful';
    final amountSign = isReceiving ? '+' : '-';
    final amountColor =
        isReceiving ? AppColors.positive : AppColors.textPrimary;
    final userLabel = isReceiving ? 'From' : 'To';

    return Scaffold(
      body: Stack(
        children: [
          // Background
          const HolographicBackground(
            child: SizedBox.expand(),
          ),

          SafeArea(
            child: Column(
              children: [
                const Spacer(),

                // Receipt Card
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.screenPadding),
                  child: GlassCard(
                    borderRadius: 24,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Success Icon (Dynamic Color)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isReceiving
                                ? Icons.download_rounded
                                : Icons.check_rounded,
                            color: statusColor,
                            size: 40,
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Dynamic Title
                        Text(
                          titleText,
                          style: AppTextStyles.headlineSmall,
                        ),

                        const SizedBox(height: 8),

// Dynamic Amount with Currency Symbol
                        Text(
                          '$amountSign$currencySymbol $amount', // Added space here
                          style: AppTextStyles.amountLarge.copyWith(
                            color: amountColor,
                          ),
                        ),

                        const SizedBox(height: 32),
                        const Divider(color: AppColors.glassBorder),
                        const SizedBox(height: 24),

                        // Details
                        _buildRow(userLabel, recipientName),
                        const SizedBox(height: 16),
                        _buildRow('Account', recipientAccount),
                        const SizedBox(height: 16),
                        if (description != null && description!.isNotEmpty) ...[
                          _buildRow('Description', description!),
                          const SizedBox(height: 16),
                        ],
                        _buildRow('Date', '$dateStr • $timeStr'),
                        const SizedBox(height: 16),
                        _buildRow('Ref ID', refId),

                        const SizedBox(height: 32),

                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: SecondaryButton(
                                text: 'Share',
                                icon: Icons.share_outlined,
                                onPressed: () {},
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: PrimaryButton(
                                text: 'Done',
                                backgroundColor: isReceiving
                                    ? AppColors.positive
                                    : AppColors.accent,
                                textColor: Colors.white,
                                onPressed: () {
                                  // If onDone callback provided, use it to navigate back to home
                                  if (onDone != null) {
                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                    onDone!();
                                  } else {
                                    Navigator.of(context).popUntil((route) => route.isFirst);
                                  }
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
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  int _formatHour(int hour) {
    if (hour == 0) return 12;
    if (hour > 12) return hour - 12;
    return hour;
  }
}
