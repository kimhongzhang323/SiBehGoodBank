import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// AI copilot surface that sits above the home page.
/// Shows quick reasoning, tool choices, and a chat-style thread.
class AiChatScreen extends StatelessWidget {
  const AiChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.holographicGradient,
          stops: AppColors.holographicStops,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  children: const [
                    _ChatBanner(),
                    SizedBox(height: AppSpacing.md),
                    _MessageBubble(
                      speaker: 'You',
                      message: 'Review last 7 days spend and flag any anomalies.',
                      alignment: Alignment.centerRight,
                      bubbleColor: Colors.white,
                      textColor: AppColors.textPrimary,
                    ),
                    SizedBox(height: AppSpacing.sm),
                    _MessageBubble(
                      speaker: 'AI Copilot',
                      message:
                          'Got it. I will explain the plan, pick a tool, and run it. Starting with Spend Analyzer to surface anomalies.',
                      alignment: Alignment.centerLeft,
                      bubbleColor: AppColors.glassWhiteLight,
                      textColor: AppColors.textPrimary,
                    ),
                    SizedBox(height: AppSpacing.md),
                    _ToolStrip(),
                    SizedBox(height: AppSpacing.md),
                    _MessageBubble(
                      speaker: 'AI Copilot',
                      message:
                          'Spend Analyzer is running. I will summarize findings and suggest actions if I spot unusual vendors or amounts.',
                      alignment: Alignment.centerLeft,
                      bubbleColor: AppColors.glassWhite,
                      textColor: AppColors.textPrimary,
                    ),
                    SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
              const _Composer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Copilot',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Ask in natural language. I will explain and pick tools for you.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: AppColors.accent,
            size: AppSpacing.iconLg,
          ),
        ),
      ],
    );
  }
}

class _ChatBanner extends StatelessWidget {
  const _ChatBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: Colors.white.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'How it works',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            '1) You give an instruction.\n2) AI explains the plan.\n3) AI picks the right tool and executes.',
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.speaker,
    required this.message,
    required this.alignment,
    required this.bubbleColor,
    required this.textColor,
  });

  final String speaker;
  final String message;
  final Alignment alignment;
  final Color bubbleColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            border: Border.all(color: Colors.white.withOpacity(0.6)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  speaker,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ToolStrip extends StatelessWidget {
  const _ToolStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: const [
          _ToolCard(
            title: 'Spend Analyzer',
            subtitle: 'Looks for weird spikes and vendors.',
            status: 'Running…',
            color: AppColors.accent,
            icon: Icons.analytics_outlined,
          ),
          SizedBox(width: AppSpacing.md),
          _ToolCard(
            title: 'Cash Planner',
            subtitle: 'Projects burn and runway.',
            status: 'Ready',
            color: AppColors.accentBlue,
            icon: Icons.auto_graph,
          ),
          SizedBox(width: AppSpacing.md),
          _ToolCard(
            title: 'Compliance Check',
            subtitle: 'Flags risky merchants.',
            status: 'Queued',
            color: AppColors.positive,
            icon: Icons.verified_user_outlined,
          ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.title,
    required this.subtitle,
    required this.status,
    required this.color,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final String status;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Icon(icon, color: color),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: Colors.white.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.chat_bubble_outline, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Give a directive…',
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
