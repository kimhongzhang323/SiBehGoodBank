import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../widgets/widgets.dart';

class TransferReceiptScreen extends StatelessWidget {
  final String amount;
  final String recipientName;
  final String recipientAccount;

  const TransferReceiptScreen({
    super.key,
    required this.amount,
    required this.recipientName,
    required this.recipientAccount,
  });

  @override
  Widget build(BuildContext context) {
    // Manual date formatting
    final now = DateTime.now();
    final dateStr = "${_getMonth(now.month)} ${now.day}, ${now.year}";
    final timeStr =
        "${_formatHour(now.hour)}:${now.minute.toString().padLeft(2, '0')} ${now.hour >= 12 ? 'PM' : 'AM'}";
    final refId = 'REF-${now.millisecondsSinceEpoch.toString().substring(5)}';

    return Scaffold(
      body: Stack(
        children: [
          // Background with required child fix
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
                        // Success Icon
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.positive.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: AppColors.positive,
                            size: 40,
                          ),
                        ),

                        const SizedBox(height: 24),

                        const Text(
                          'Transfer Successful',
                          style: AppTextStyles.headlineSmall,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          '-\$$amount',
                          style: AppTextStyles.amountLarge.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 32),
                        const Divider(color: AppColors.glassBorder),
                        const SizedBox(height: 24),

                        // Details
                        _buildRow('To', recipientName),
                        const SizedBox(height: 16),
                        _buildRow('Account', recipientAccount),
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
                                  // Pop until we reach the Home Screen
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
