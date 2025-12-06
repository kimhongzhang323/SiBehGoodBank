import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';

enum TransactionType { sent, received }

class TransactionReceiptScreen extends StatelessWidget {
  final TransactionType type;
  final String amount;
  final String peerName; // Sender or Receiver name
  final String peerAccount;

  const TransactionReceiptScreen({
    super.key,
    required this.type,
    required this.amount,
    required this.peerName,
    required this.peerAccount,
  });

  @override
  Widget build(BuildContext context) {
    // Determine UI elements based on transaction type
    final isReceived = type == TransactionType.received;
    final title = isReceived ? 'Money Received' : 'Transfer Successful';
    final amountPrefix = isReceived ? '+' : '-';
    final amountColor = isReceived ? AppColors.positive : AppColors.textPrimary;
    final icon =
        isReceived ? Icons.arrow_downward_rounded : Icons.check_rounded;
    final iconColor = isReceived ? AppColors.positive : AppColors.accent;
    final peerLabel = isReceived ? 'From' : 'To';

    // Manual date formatting
    final now = DateTime.now();
    final dateStr = "${_getMonth(now.month)} ${now.day}, ${now.year}";
    final timeStr =
        "${_formatHour(now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
    final refId = 'REF-${now.millisecondsSinceEpoch.toString().substring(5)}';

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
                        // Status Icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: iconColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: iconColor,
                            size: 40,
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          title,
                          style: AppTextStyles.headlineSmall,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '$amountPrefix\$$amount',
                          style: AppTextStyles.amountLarge.copyWith(
                            color: amountColor,
                          ),
                        ),

                        const SizedBox(height: 32),
                        const Divider(color: AppColors.glassBorder),
                        const SizedBox(height: 24),

                        // Details
                        _buildRow(peerLabel, peerName),
                        const SizedBox(height: 16),
                        _buildRow('Account', peerAccount),
                        const SizedBox(height: 16),
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
                                backgroundColor: AppColors.accent,
                                textColor: Colors.white,
                                onPressed: () {
                                  // Return to Home
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
