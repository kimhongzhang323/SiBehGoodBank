import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
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
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _voiceText = '';
  double _soundLevel = 0.0;
  bool _useSimulatedVoice = true; // Use simulated voice for demo
  bool _showAttachmentMenu = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _startSimulatedListening(Function(String) onResult) async {
    setState(() {
      _isListening = true;
      _voiceText = '';
    });

    // Simulate voice animation for 2 seconds
    for (int i = 0; i < 20; i++) {
      if (!_isListening) break;
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          _soundLevel = (i % 4) * 0.25; // Simulate wave pattern
        });
      }
    }

    // Auto-send "transfer money" after animation
    if (_isListening && mounted) {
      setState(() {
        _voiceText = 'Transfer money to TNG';
        _soundLevel = 0.0;
        _isListening = false;
      });
      onResult('Transfer money to TNG');
    }
  }

  void _stopSimulatedListening() {
    if (mounted) {
      setState(() {
        _isListening = false;
        _soundLevel = 0.0;
      });
    }
  }

  void _toggleAttachmentMenu() {
    setState(() {
      _showAttachmentMenu = !_showAttachmentMenu;
    });
  }

  void _handleReceiptUpload(String source) async {
    setState(() {
      _showAttachmentMenu = false;
      _messages.add({
        'speaker': 'Agent',
        'message': '📸 Analyzing receipt from $source...',
        'alignment': Alignment.centerLeft,
      });
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 1500));

    // Generate simulated receipt data
    final receiptData = {
      'source': 'Touch n Go eWallet',
      'items': [
        {'name': 'Starbucks Coffee', 'price': 'RM 18.50'},
        {'name': 'Croissant', 'price': 'RM 8.90'},
      ],
      'total': 'RM 27.40',
      'date': '6 Dec 2025',
      'time': '14:35',
      'merchant': 'Starbucks KLCC',
      'merchantType': 'Food & Beverage',
    };

    setState(() {
      _messages.add({
        'speaker': 'Agent',
        'message': '✓ Receipt analysis complete!',
        'alignment': Alignment.centerLeft,
        'showReceiptCard': true,
        'receiptData': receiptData,
      });
    });
    _scrollToBottom();
  }

  void _handleReceiptAction(String action, Map<String, dynamic> receiptData) {
    setState(() {
      // Find and update the receipt card message
      for (var msg in _messages) {
        if (msg['showReceiptCard'] == true && msg['receiptData'] == receiptData) {
          msg['receiptAction'] = action;
          break;
        }
      }
    });

    // Show confirmation message
    String confirmationText;
    if (action == 'ignore') {
      confirmationText = 'Receipt ignored';
    } else {
      // Get the date from receipt data and show it in the confirmation
      final receiptDate = receiptData['date'] as String;
      confirmationText = 'Saved to $receiptDate bills';
    }

    setState(() {
      _messages.add({
        'speaker': 'Agent',
        'message': confirmationText,
        'alignment': Alignment.centerLeft,
      });
    });
    _scrollToBottom();
  }

  Future<void> _startListening(Function(String) onResult) async {
    // Request microphone permission first
    final status = await Permission.microphone.request();
    
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required for voice input'),
            backgroundColor: AppColors.negative,
          ),
        );
      }
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        if (status == 'done' || status == 'notListening') {
          if (mounted) {
            setState(() {
              _isListening = false;
              _soundLevel = 0.0;
            });
          }
        }
      },
      onError: (error) {
        print('Speech recognition error: $error');
        if (mounted) {
          setState(() {
            _isListening = false;
            _soundLevel = 0.0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.errorMsg}'),
              backgroundColor: AppColors.negative,
            ),
          );
        }
      },
    );

    if (available) {
      setState(() {
        _isListening = true;
        _voiceText = '';
      });
      
      _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _voiceText = result.recognizedWords;
            });
          }
          
          if (result.finalResult && _voiceText.isNotEmpty) {
            print('Final result: $_voiceText');
            _speech.stop();
            if (mounted) {
              setState(() => _isListening = false);
              onResult(_voiceText);
            }
          }
        },
        onSoundLevelChange: (level) {
          if (mounted) {
            setState(() {
              _soundLevel = level.clamp(0.0, 1.0);
            });
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        cancelOnError: true,
        partialResults: true,
        listenMode: stt.ListenMode.confirmation,
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech recognition not available. Please check permissions.'),
            backgroundColor: AppColors.negative,
          ),
        );
      }
    }
  }

  void _stopListening() {
    _speech.stop();
    if (mounted) {
      setState(() {
        _isListening = false;
        _soundLevel = 0.0;
      });
    }
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
                      } else if (msg['showReceiptCard'] == true) {
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
                            _ReceiptAnalysisCard(
                              receiptData: msg['receiptData'],
                              action: msg['receiptAction'],
                              onAction: (action) => _handleReceiptAction(action, msg['receiptData']),
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
              _Composer(
                onSend: _handleUserMessage,
                isListening: _isListening,
                voiceText: _voiceText,
                soundLevel: _soundLevel,
                onVoiceStart: () => _startSimulatedListening(_handleUserMessage),
                onVoiceStop: _stopSimulatedListening,
                showAttachmentMenu: _showAttachmentMenu,
                onToggleAttachment: _toggleAttachmentMenu,
                onReceiptUpload: _handleReceiptUpload,
              ),
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

class _ReceiptAnalysisCard extends StatelessWidget {
  const _ReceiptAnalysisCard({
    required this.receiptData,
    required this.onAction,
    this.action,
  });

  final Map<String, dynamic> receiptData;
  final void Function(String) onAction;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: AppColors.accent.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(Icons.receipt_long, color: AppColors.accent, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Receipt Analysis',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      receiptData['source'] ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Items purchased
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Items Purchased',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...((receiptData['items'] as List?) ?? []).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        item['price'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                )),
                const Divider(height: AppSpacing.lg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      receiptData['total'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Details
          _buildDetailRow('Date & Time', '${receiptData['date']} • ${receiptData['time']}'),
          _buildDetailRow('Merchant', receiptData['merchant'] ?? ''),
          _buildDetailRow('Category', receiptData['merchantType'] ?? ''),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Action buttons or status
          if (action == null) ...[
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onAction('ignore'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    child: const Text('Ignore', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onAction('save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark, size: 18),
                        SizedBox(width: AppSpacing.xs),
                        Text('Save in Bill', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: action == 'ignore' 
                    ? AppColors.textSecondary.withOpacity(0.1)
                    : AppColors.positive.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    action == 'ignore' ? Icons.block : Icons.bookmark,
                    color: action == 'ignore' ? AppColors.textSecondary : AppColors.positive,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    action == 'ignore' ? 'Ignored' : 'Saved to Bills',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: action == 'ignore' ? AppColors.textSecondary : AppColors.positive,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
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
  const _Composer({
    required this.onSend,
    required this.isListening,
    required this.voiceText,
    required this.soundLevel,
    required this.onVoiceStart,
    required this.onVoiceStop,
    required this.showAttachmentMenu,
    required this.onToggleAttachment,
    required this.onReceiptUpload,
  });

  final void Function(String) onSend;
  final bool isListening;
  final String voiceText;
  final double soundLevel;
  final VoidCallback onVoiceStart;
  final VoidCallback onVoiceStop;
  final bool showAttachmentMenu;
  final VoidCallback onToggleAttachment;
  final void Function(String) onReceiptUpload;

  @override
  State<_Composer> createState() => _ComposerState();
}

class _ComposerState extends State<_Composer> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void didUpdateWidget(_Composer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isListening && widget.voiceText.isNotEmpty) {
      _controller.text = widget.voiceText;
    }
  }

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Attachment menu
        if (widget.showAttachmentMenu) ...[
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              children: [
                _AttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Choose from Gallery',
                  color: AppColors.accent,
                  onTap: () => widget.onReceiptUpload('gallery'),
                ),
                const SizedBox(height: AppSpacing.sm),
                _AttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Take Photo',
                  color: AppColors.accentBlue,
                  onTap: () => widget.onReceiptUpload('camera'),
                ),
              ],
            ),
          ),
        ],
        
        // Main composer
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: widget.isListening 
                  ? AppColors.accent.withOpacity(0.6)
                  : Colors.white.withOpacity(0.4),
              width: widget.isListening ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isListening) ...[
                _VoiceWaveAnimation(soundLevel: widget.soundLevel),
                const SizedBox(height: AppSpacing.sm),
              ],
              Row(
                children: [
                  // Attachment button
                  GestureDetector(
                    onTap: widget.onToggleAttachment,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.showAttachmentMenu
                            ? AppColors.accent.withOpacity(0.15)
                            : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.showAttachmentMenu ? Icons.close : Icons.add,
                        color: widget.showAttachmentMenu ? AppColors.accent : AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Voice button
                  GestureDetector(
                    onLongPressStart: (_) {
                      print('Long press started!');
                      widget.onVoiceStart();
                    },
                    onLongPressEnd: (_) {
                      print('Long press ended!');
                      widget.onVoiceStop();
                    },
                    onTap: () {
                      print('Microphone tapped! Try long press instead.');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Hold the microphone button to speak'),
                          duration: Duration(seconds: 2),
                          backgroundColor: AppColors.accent,
                        ),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.isListening 
                            ? AppColors.accent.withOpacity(0.15)
                            : Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.isListening 
                              ? AppColors.accent
                              : AppColors.textSecondary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        widget.isListening ? Icons.mic : Icons.mic_none,
                        color: widget.isListening ? AppColors.accent : AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: widget.isListening 
                            ? 'Listening...' 
                            : 'Ask the agent or hold mic to speak…',
                        hintStyle: TextStyle(
                          color: widget.isListening 
                              ? AppColors.accent 
                              : AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleSend,
                      borderRadius: BorderRadius.circular(22),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _controller.text.trim().isNotEmpty
                              ? AppColors.accent
                              : AppColors.textSecondary.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_upward, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AttachmentOption extends StatelessWidget {
  const _AttachmentOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoiceWaveAnimation extends StatelessWidget {
  const _VoiceWaveAnimation({required this.soundLevel});

  final double soundLevel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(5, (index) {
          final baseHeight = 8.0;
          final maxHeight = 32.0;
          final animatedHeight = baseHeight + (maxHeight - baseHeight) * soundLevel;
          final delay = index * 0.1;
          final heightMultiplier = (1 + soundLevel) * (0.5 + (index % 3) * 0.3);
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 4,
              height: animatedHeight * heightMultiplier,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

