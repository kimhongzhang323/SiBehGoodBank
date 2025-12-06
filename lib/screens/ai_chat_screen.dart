import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// AI copilot surface that sits above the home page.
/// Shows quick reasoning, tool choices, and a chat-style thread.
class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleUserMessage(String message) {
    setState(() {
      _messages.add({
        'speaker': 'You',
        'message': message,
        'alignment': Alignment.centerRight,
      });
    });

    _scrollToBottom();
    _processAgentResponse(message);
  }

  void _processAgentResponse(String userMessage) async {
    // Simulate agent planning (internal - not shown to user)
    await Future.delayed(const Duration(milliseconds: 500));

    final lowerMessage = userMessage.toLowerCase();

    // Check if message contains transfer keywords in any language
    if (lowerMessage.contains('transfer') || 
        lowerMessage.contains('send') ||
        lowerMessage.contains('转账') ||
        lowerMessage.contains('转') ||
        lowerMessage.contains('汇款') ||
        lowerMessage.contains('pay')) {
      
      // Step 1: Show processing
      setState(() {
        _messages.add({
          'speaker': 'Agent',
          'message': '🔄 Processing your transfer request...',
          'alignment': Alignment.centerLeft,
          'isProcessing': true,
        });
      });
      _scrollToBottom();

      await Future.delayed(const Duration(milliseconds: 1500));

      // Step 2: Show tool selection options
      setState(() {
        _messages.removeLast(); // Remove processing message
        _messages.add({
          'speaker': 'Agent',
          'message': '✓ Analysis complete. Please select transfer method:',
          'alignment': Alignment.centerLeft,
          'showToolSelection': true,
        });
      });
      _scrollToBottom();

    } else {
      setState(() {
        _messages.add({
          'speaker': 'Agent',
          'message': 'I can help you with transfers, balance checks, and more. Try asking "Transfer money to TNG".',
          'alignment': Alignment.centerLeft,
        });
      });
      _scrollToBottom();
    }
  }

  void _handleToolSelection(String tool) async {
    setState(() {
      _messages.add({
        'speaker': 'Agent',
        'message': 'You selected: $tool',
        'alignment': Alignment.centerLeft,
      });
      _messages.add({
        'speaker': 'Agent',
        'message': 'Please provide the following details:',
        'alignment': Alignment.centerLeft,
        'showTransferForm': true,
        'selectedTool': tool,
      });
    });
    _scrollToBottom();
  }

  void _handleFormSubmit(Map<String, String> formData, String tool) async {
    setState(() {
      _messages.add({
        'speaker': 'Agent',
        'message': 'Preparing transfer summary...',
        'alignment': Alignment.centerLeft,
      });
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _messages.removeLast();
      _messages.add({
        'speaker': 'Agent',
        'message': 'Please review and approve your transfer:',
        'alignment': Alignment.centerLeft,
        'showSummaryCard': true,
        'formData': formData,
        'selectedTool': tool,
      });
    });
    _scrollToBottom();
  }

  void _handleApproval(Map<String, String> formData, String tool) async {
    setState(() {
      _messages.add({
        'speaker': 'Agent',
        'message': '🔐 Please verify with your fingerprint...',
        'alignment': Alignment.centerLeft,
      });
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 2000));

    setState(() {
      _messages.add({
        'speaker': 'Agent',
        'message': '📸 Now verifying with face recognition...',
        'alignment': Alignment.centerLeft,
      });
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 2000));

    setState(() {
      _messages.add({
        'speaker': 'Agent',
        'message': '✓ Verification successful! Processing transfer...',
        'alignment': Alignment.centerLeft,
      });
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _messages.add({
        'speaker': 'Agent',
        'message': '✓ Transfer completed successfully!',
        'alignment': Alignment.centerLeft,
        'showReceipt': true,
        'formData': formData,
        'selectedTool': tool,
      });
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

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
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const _ChatBanner(),
                    const SizedBox(height: AppSpacing.md),
                    ..._messages.map((msg) {
                      if (msg['showToolSelection'] == true) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: _MessageBubble(
                                speaker: msg['speaker'],
                                message: msg['message'],
                                alignment: msg['alignment'],
                                bubbleColor: AppColors.glassWhiteLight,
                                textColor: AppColors.textPrimary,
                              ),
                            ),
                            _ToolSelectionGrid(onToolSelected: _handleToolSelection),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        );
                      } else if (msg['showTransferForm'] == true) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: _MessageBubble(
                                speaker: msg['speaker'],
                                message: msg['message'],
                                alignment: msg['alignment'],
                                bubbleColor: AppColors.glassWhiteLight,
                                textColor: AppColors.textPrimary,
                              ),
                            ),
                            _TransferForm(
                              tool: msg['selectedTool'],
                              onSubmit: (data) => _handleFormSubmit(data, msg['selectedTool']),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        );
                      } else if (msg['showSummaryCard'] == true) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: _MessageBubble(
                                speaker: msg['speaker'],
                                message: msg['message'],
                                alignment: msg['alignment'],
                                bubbleColor: AppColors.glassWhiteLight,
                                textColor: AppColors.textPrimary,
                              ),
                            ),
                            _TransferSummaryCard(
                              formData: msg['formData'],
                              tool: msg['selectedTool'],
                              onApprove: () => _handleApproval(msg['formData'], msg['selectedTool']),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        );
                      } else if (msg['showReceipt'] == true) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                              child: _MessageBubble(
                                speaker: msg['speaker'],
                                message: msg['message'],
                                alignment: msg['alignment'],
                                bubbleColor: AppColors.glassWhiteLight,
                                textColor: AppColors.textPrimary,
                              ),
                            ),
                            _TransferReceipt(
                              formData: msg['formData'],
                              tool: msg['selectedTool'],
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _MessageBubble(
                            speaker: msg['speaker'],
                            message: msg['message'],
                            alignment: msg['alignment'],
                            bubbleColor: msg['alignment'] == Alignment.centerRight
                                ? Colors.white
                                : AppColors.glassWhiteLight,
                            textColor: AppColors.textPrimary,
                          ),
                        );
                      }
                    }),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
              _Composer(onSend: _handleUserMessage),
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
                'Digital Banking Agent',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Autonomous agent that reasons, calls tools, and executes tasks.',
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

class _ToolSelectionGrid extends StatelessWidget {
  const _ToolSelectionGrid({required this.onToolSelected});

  final void Function(String) onToolSelected;

  @override
  Widget build(BuildContext context) {
    final tools = [
      {'name': 'Touch n Go (TNG)', 'icon': Icons.phone_android, 'color': AppColors.accent},
      {'name': 'CIMB Bank', 'icon': Icons.account_balance, 'color': AppColors.accentBlue},
      {'name': 'Maybank', 'icon': Icons.account_balance, 'color': AppColors.positive},
      {'name': 'Public Bank', 'icon': Icons.account_balance, 'color': Color(0xFFFF6B9D)},
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Transfer Destination',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...tools.map((tool) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => onToolSelected(tool['name'] as String),
                style: ElevatedButton.styleFrom(
                  backgroundColor: (tool['color'] as Color).withOpacity(0.15),
                  foregroundColor: tool['color'] as Color,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    side: BorderSide(
                      color: (tool['color'] as Color).withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (tool['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Icon(
                        tool['icon'] as IconData,
                        color: tool['color'] as Color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        tool['name'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: (tool['color'] as Color),
                    ),
                  ],
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _TransferForm extends StatefulWidget {
  const _TransferForm({required this.tool, required this.onSubmit});

  final String tool;
  final void Function(Map<String, String>) onSubmit;

  @override
  State<_TransferForm> createState() => _TransferFormState();
}

class _TransferFormState extends State<_TransferForm> {
  final _amountController = TextEditingController();
  final _recipientController = TextEditingController();
  final _phoneController = TextEditingController();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _recipientController.dispose();
    _phoneController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_amountController.text.isEmpty || 
        _recipientController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      return;
    }

    widget.onSubmit({
      'amount': _amountController.text,
      'recipient': _recipientController.text,
      'phone': _phoneController.text,
      'reason': _reasonController.text.isEmpty ? 'Payment' : _reasonController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Amount (RM)', _amountController, TextInputType.number),
          const SizedBox(height: AppSpacing.md),
          _buildTextField('Recipient Name', _recipientController, TextInputType.name),
          const SizedBox(height: AppSpacing.md),
          _buildTextField('Phone Number', _phoneController, TextInputType.phone),
          const SizedBox(height: AppSpacing.md),
          _buildTextField('Reason (Optional)', _reasonController, TextInputType.text),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              borderSide: const BorderSide(color: AppColors.accent, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
      ],
    );
  }
}

class _TransferSummaryCard extends StatelessWidget {
  const _TransferSummaryCard({
    required this.formData,
    required this.tool,
    required this.onApprove,
  });

  final Map<String, String> formData;
  final String tool;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.accent.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transfer Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildRow('Transfer Method', tool),
          _buildRow('Amount', 'RM ${formData['amount']}'),
          _buildRow('Recipient', formData['recipient'] ?? ''),
          _buildRow('Phone Number', formData['phone'] ?? ''),
          _buildRow('Reason', formData['reason'] ?? ''),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onApprove,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.positive,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: const Text('Approve Transfer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransferReceipt extends StatelessWidget {
  const _TransferReceipt({
    required this.formData,
    required this.tool,
  });

  final Map<String, String> formData;
  final String tool;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final transactionId = 'TXN${now.millisecondsSinceEpoch.toString().substring(7)}';
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.positive.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.positive.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.positive.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle, color: AppColors.positive, size: 36),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Transfer Successful',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            transactionId,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              children: [
                _buildRow('Amount', 'RM ${formData['amount']}', isHighlight: true),
                const Divider(height: AppSpacing.lg),
                _buildRow('Method', tool),
                _buildRow('Recipient', formData['recipient'] ?? ''),
                _buildRow('Phone', formData['phone'] ?? ''),
                _buildRow('Reason', formData['reason'] ?? ''),
                _buildRow('Date', '${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2, '0')}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHighlight ? 16 : 14,
              color: AppColors.textSecondary,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 18 : 14,
              fontWeight: FontWeight.w700,
              color: isHighlight ? AppColors.positive : AppColors.textPrimary,
            ),
          ),
        ],
      ),
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
            'Agentic Digital Banking',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            '1) You give an instruction.\n2) Agent plans internally (you won\'t see this).\n3) Agent selects and launches the right tool.\n4) You interact directly with the tool.',
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
            title: 'TNG Transfer',
            subtitle: 'Transfer money via Touch n Go.',
            status: 'Active',
            color: AppColors.accent,
            icon: Icons.payment,
          ),
          SizedBox(width: AppSpacing.md),
          _ToolCard(
            title: 'Balance Check',
            subtitle: 'Verify sufficient funds.',
            status: 'Complete',
            color: AppColors.positive,
            icon: Icons.account_balance_wallet,
          ),
          SizedBox(width: AppSpacing.md),
          _ToolCard(
            title: 'Transaction Log',
            subtitle: 'Record transfer details.',
            status: 'Ready',
            color: AppColors.accentBlue,
            icon: Icons.receipt_long,
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

class _Composer extends StatefulWidget {
  const _Composer({required this.onSend});

  final void Function(String) onSend;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_controller.text.trim().isEmpty) return;
    
    widget.onSend(_controller.text.trim());
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Ask the agent to do something…',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => _handleSend(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
