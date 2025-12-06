import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../constants/constants.dart';
import '../services/ai_chat_service.dart';

/// AI copilot surface that sits above the home page.
/// Shows quick reasoning, tool choices, and a chat-style thread.
class AiChatScreen extends StatefulWidget {
  final VoidCallback? onBackToHome;
  
  const AiChatScreen({super.key, this.onBackToHome});

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
  
  // AI Chat Service for backend integration
  late AiChatService _aiChatService;
  bool _isAiProcessing = false;
  bool _useAiBackend = true; // Toggle to enable/disable AI backend

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _aiChatService = AiChatService(userId: 'user-001');
    _checkAiServiceHealth();
  }

  Future<void> _checkAiServiceHealth() async {
    final isHealthy = await _aiChatService.checkHealth();
    if (mounted) {
      setState(() {
        _useAiBackend = isHealthy;
      });
      if (!isHealthy) {
        debugPrint('AI backend not available, using local fallback');
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _speech.stop();
    _aiChatService.dispose();
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

  void _handleQuickTransfer() {
    // Simulate user clicking transfer
    _handleUserMessage('Transfer money');
  }

  void _handleQuickCashWithdrawal() {
    // Trigger cash withdrawal flow
    _handleUserMessage('Cash withdrawal');
  }

  void _handleQuickBillPayment() {
    // Trigger bill payment flow
    _handleUserMessage('Bill payment');
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
    final lowerMessage = userMessage.toLowerCase();

    // Check for specific UI-driven flows first (transfer, withdrawal, bill payment)
    // These have custom UI components that are better handled locally
    
    // Check for bill payment FIRST (before transfer, since 'payment' might match other keywords)
    if (lowerMessage.contains('bill') || 
        (lowerMessage.contains('payment') && !lowerMessage.contains('transfer')) ||
        lowerMessage.contains('pay bill') ||
        lowerMessage.contains('账单') ||
        lowerMessage.contains('付款') ||
        lowerMessage.contains('缴费')) {
      
      // Step 1: Show processing
      setState(() {
        _messages.add({
          'speaker': 'Agent',
          'message': '🔄 Processing bill payment request...',
          'alignment': Alignment.centerLeft,
          'isProcessing': true,
        });
      });
      _scrollToBottom();

      await Future.delayed(const Duration(milliseconds: 1500));

      // Step 2: Show bill type selection
      setState(() {
        _messages.removeLast(); // Remove processing message
        _messages.add({
          'speaker': 'Agent',
          'message': '✓ Please select the bill type you want to pay:',
          'alignment': Alignment.centerLeft,
          'showBillTypeSelection': true,
        });
      });
      _scrollToBottom();

    } else if (lowerMessage.contains('transfer') || 
        lowerMessage.contains('send') ||
        lowerMessage.contains('转账') ||
        lowerMessage.contains('转') ||
        lowerMessage.contains('汇款')) {
      
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

      // Step 2: Show transfer form directly with recent accounts
      setState(() {
        _messages.removeLast(); // Remove processing message
        _messages.add({
          'speaker': 'Agent',
          'message': '✓ Who would you like to transfer to?',
          'alignment': Alignment.centerLeft,
          'showTransferForm': true,
          'selectedTool': 'Transfer',
        });
      });
      _scrollToBottom();

    } else if (lowerMessage.contains('cash') || 
               lowerMessage.contains('withdrawal') ||
               lowerMessage.contains('withdraw')) {
      
      // Step 1: Show processing
      setState(() {
        _messages.add({
          'speaker': 'Agent',
          'message': '🔄 Processing cash withdrawal request...',
          'alignment': Alignment.centerLeft,
          'isProcessing': true,
        });
      });
      _scrollToBottom();

      await Future.delayed(const Duration(milliseconds: 1500));

      // Step 2: Show account selection options
      setState(() {
        _messages.removeLast(); // Remove processing message
        _messages.add({
          'speaker': 'Agent',
          'message': '✓ Please select the account to withdraw from:',
          'alignment': Alignment.centerLeft,
          'showWithdrawalAccountSelection': true,
        });
      });
      _scrollToBottom();

    } else {
      // For all other queries, use the AI backend if available
      await _sendToAiBackend(userMessage);
    }
  }

  /// Send message to AI backend and handle response
  Future<void> _sendToAiBackend(String userMessage) async {
    if (!_useAiBackend) {
      // Fallback response when AI backend is not available
      setState(() {
        _messages.add({
          'speaker': 'Agent',
          'message': 'I can help you with transfers, cash withdrawals, bill payments, and more. Try asking "Transfer money", "Cash withdrawal", or "Bill payment".',
          'alignment': Alignment.centerLeft,
        });
      });
      _scrollToBottom();
      return;
    }

    // Show typing indicator
    setState(() {
      _isAiProcessing = true;
      _messages.add({
        'speaker': 'Agent',
        'message': '🤔 Thinking...',
        'alignment': Alignment.centerLeft,
        'isProcessing': true,
      });
    });
    _scrollToBottom();

    try {
      final response = await _aiChatService.sendMessage(userMessage);
      
      if (mounted) {
        setState(() {
          _isAiProcessing = false;
          _messages.removeLast(); // Remove thinking indicator
          _messages.add({
            'speaker': 'Agent',
            'message': response.message,
            'alignment': Alignment.centerLeft,
          });
        });
        _scrollToBottom();
      }
    } on AiChatException catch (e) {
      if (mounted) {
        setState(() {
          _isAiProcessing = false;
          _messages.removeLast(); // Remove thinking indicator
          _messages.add({
            'speaker': 'Agent',
            'message': '❌ Sorry, I encountered an error: ${e.message}. Please try again.',
            'alignment': Alignment.centerLeft,
          });
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAiProcessing = false;
          _messages.removeLast(); // Remove thinking indicator
          _messages.add({
            'speaker': 'Agent',
            'message': 'I can help you with transfers, cash withdrawals, bill payments, and more. Try asking "Transfer money", "Cash withdrawal", or "Bill payment".',
            'alignment': Alignment.centerLeft,
          });
        });
        _scrollToBottom();
      }
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
    // Show biometric verification sheet
    _showBiometricVerification(
      onSuccess: () async {
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
      },
      onCancel: () {
        setState(() {
          _messages.add({
            'speaker': 'Agent',
            'message': '❌ Verification cancelled. Transfer was not processed.',
            'alignment': Alignment.centerLeft,
          });
        });
        _scrollToBottom();
      },
    );
  }

  void _showBiometricVerification({
    required VoidCallback onSuccess,
    required VoidCallback onCancel,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) => _AiBiometricSheet(
        onSuccess: () {
          Navigator.pop(context);
          onSuccess();
        },
        onCancel: () {
          Navigator.pop(context);
          onCancel();
        },
      ),
    );
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

  void _handleWithdrawalAccountSelection(Map<String, String> account) async {
    // Show amount selection after account is chosen
    setState(() {
      _messages.add({
        'speaker': 'Agent',
        'message': '💰 You selected ${account['name']}. How much would you like to withdraw?',
        'alignment': Alignment.centerLeft,
        'showWithdrawalAmountSelection': true,
        'selectedAccount': account,
      });
    });
    _scrollToBottom();
  }

  void _handleWithdrawalAmountSelection(String amount, Map<String, String> account) async {
    // Show branch selection after amount is chosen
    setState(() {
      _messages.add({
        'speaker': 'Agent',
        'message': '📍 Please select a branch for ATM pickup:',
        'alignment': Alignment.centerLeft,
        'showBranchSelection': true,
        'selectedAccount': account,
        'selectedAmount': amount,
      });
    });
    _scrollToBottom();
  }

  void _handleBranchSelection(Map<String, dynamic> branchData, String amount, Map<String, String> account) async {
    // Show biometric verification sheet
    _showBiometricVerification(
      onSuccess: () async {
        setState(() {
          _messages.add({
            'speaker': 'Agent',
            'message': '✓ Verification successful! Generating withdrawal QR code...',
            'alignment': Alignment.centerLeft,
          });
        });
        _scrollToBottom();

        await Future.delayed(const Duration(milliseconds: 800));

        // Generate withdrawal QR code
        final now = DateTime.now();
        final originalBalance = double.tryParse(account['balance']?.replaceAll(',', '') ?? '5000') ?? 5000.0;
        final withdrawalAmount = double.tryParse(amount.replaceAll('RM', '').replaceAll(',', '').trim()) ?? 0.0;
        final newBalance = originalBalance - withdrawalAmount;
        final transactionId = 'WD${now.millisecondsSinceEpoch.toString().substring(7)}';
        final qrCode = 'SGB-${transactionId}-${branchData['atmId']}';

        final withdrawalData = {
          'account': account['name'],
          'accountNumber': account['number'],
          'branch': branchData['name'],
          'branchAddress': branchData['address'],
          'atmId': branchData['atmId'],
          'amount': withdrawalAmount,
          'originalBalance': originalBalance,
          'newBalance': newBalance,
          'date': '${now.day} ${_getMonthName(now.month)} ${now.year}',
          'time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
          'transactionId': transactionId,
          'qrCode': qrCode,
          'googleMapsUrl': 'https://www.google.com/maps/search/?api=1&query=${branchData['lat']},${branchData['lng']}',
          'status': 'pending', // pending, collected
        };

        setState(() {
          _messages.add({
            'speaker': 'Agent',
            'message': '📱 Scan this QR code at the ATM to collect your cash',
            'alignment': Alignment.centerLeft,
            'showWithdrawalQR': true,
            'withdrawalData': withdrawalData,
          });
        });
        _scrollToBottom();
      },
      onCancel: () {
        setState(() {
          _messages.add({
            'speaker': 'Agent',
            'message': '❌ Verification cancelled. Withdrawal was not processed.',
            'alignment': Alignment.centerLeft,
          });
        });
        _scrollToBottom();
      },
    );
  }

  void _handleWithdrawalCollected(Map<String, dynamic> withdrawalData) {
    final now = DateTime.now();
    setState(() {
      _messages.add({
        'speaker': 'Agent',
        'message': '✅ Cash collected successfully!',
        'alignment': Alignment.centerLeft,
        'showWithdrawalReceipt': true,
        'withdrawalData': {
          ...withdrawalData,
          'status': 'collected',
          'collectionTime': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        },
      });
    });
    _scrollToBottom();
  }

  // Legacy handler - keeping for compatibility
  void _handleWithdrawalBankSelection(String bank) async {
    if (bank == 'Other...') {
      // Show custom bank card form
      setState(() {
        _messages.add({
          'speaker': 'Agent',
          'message': '💳 Please enter your bank card details:',
          'alignment': Alignment.centerLeft,
          'showCustomBankForm': true,
        });
      });
      _scrollToBottom();
    } else {
      // Normal bank flow
      setState(() {
        _messages.add({
          'speaker': 'Agent',
          'message': '💳 You selected $bank. How much would you like to withdraw?',
          'alignment': Alignment.centerLeft,
          'showWithdrawalAmountInput': true,
          'selectedBank': bank,
        });
      });
      _scrollToBottom();
    }
  }

  void _handleWithdrawalAmount(String amount, String bank) async {
    // Show biometric verification sheet
    _showBiometricVerification(
      onSuccess: () async {
        setState(() {
          _messages.add({
            'speaker': 'Agent',
            'message': '✓ Verification successful! Processing withdrawal...',
            'alignment': Alignment.centerLeft,
          });
        });
        _scrollToBottom();

        await Future.delayed(const Duration(milliseconds: 1000));

        // Generate withdrawal receipt
        final now = DateTime.now();
        final originalBalance = 5000.00;
        final withdrawalAmount = double.tryParse(amount.replaceAll('RM', '').replaceAll(',', '').trim()) ?? 0.0;
        final newBalance = originalBalance - withdrawalAmount;

        setState(() {
          _messages.add({
            'speaker': 'Agent',
            'message': '✓ Cash withdrawal completed!',
            'alignment': Alignment.centerLeft,
            'showWithdrawalReceipt': true,
            'withdrawalData': {
              'bank': bank,
              'amount': withdrawalAmount,
              'originalBalance': originalBalance,
              'newBalance': newBalance,
              'date': '${now.day} ${_getMonthName(now.month)} ${now.year}',
              'time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
              'transactionId': 'WD${now.millisecondsSinceEpoch.toString().substring(7)}',
            },
          });
        });
        _scrollToBottom();
      },
      onCancel: () {
        setState(() {
          _messages.add({
            'speaker': 'Agent',
            'message': '❌ Verification cancelled. Withdrawal was not processed.',
            'alignment': Alignment.centerLeft,
          });
        });
        _scrollToBottom();
      },
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  void _handleCustomBankSubmit(Map<String, String> bankData) async {
    // Show amount input after custom bank details
    setState(() {
      _messages.add({
        'speaker': 'Agent',
        'message': '💳 Bank card verified. How much would you like to withdraw?',
        'alignment': Alignment.centerLeft,
        'showWithdrawalAmountInput': true,
        'selectedBank': bankData['bankName']!,
      });
    });
    _scrollToBottom();
  }

  void _handleWithdrawalReceiptAction(String action, Map<String, dynamic> withdrawalData) {
    setState(() {
      // Find and update the receipt message
      for (var msg in _messages) {
        if (msg['showWithdrawalReceipt'] == true && msg['withdrawalData'] == withdrawalData) {
          msg['receiptAction'] = action;
          break;
        }
      }
    });

    if (action == 'print') {
      // Show invoice image
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _messages.add({
            'speaker': 'Agent',
            'message': '📄 Generating PDF invoice...',
            'alignment': Alignment.centerLeft,
          });
        });
        _scrollToBottom();

        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            _messages.add({
              'speaker': 'Agent',
              'message': '✓ Invoice generated successfully:',
              'alignment': Alignment.centerLeft,
              'showInvoice': true,
            });
          });
          _scrollToBottom();
        });
      });
    } else {
      // Ignore action
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _messages.add({
            'speaker': 'Agent',
            'message': 'Receipt ignored',
            'alignment': Alignment.centerLeft,
          });
        });
        _scrollToBottom();
      });
    }
  }

  void _handleBillTypeSelection(String category) async {
    // Show provider selection for the chosen category
    setState(() {
      _messages.add({
        'speaker': 'Agent',
        'message': '📋 Select your $category provider:',
        'alignment': Alignment.centerLeft,
        'showBillProviderSelection': true,
        'billCategory': category,
      });
    });
    _scrollToBottom();
  }

  void _handleBillProviderSelection(String provider, String category) async {
    // Generate random bill amount
    final random = Random();
    final billAmount = (random.nextInt(400) + 50).toDouble(); // Random amount between RM50-RM450
    
    // Generate due date (7-30 days from now)
    final dueDate = DateTime.now().add(Duration(days: random.nextInt(24) + 7));

    setState(() {
      _messages.add({
        'speaker': 'Agent',
        'message': '📝 Here is your $provider invoice:',
        'alignment': Alignment.centerLeft,
      });
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _messages.add({
        'speaker': 'Agent',
        'message': '💵 Total amount due: RM ${billAmount.toStringAsFixed(2)}\n📅 Due date: ${dueDate.day}/${dueDate.month}/${dueDate.year}',
        'alignment': Alignment.centerLeft,
      });
    });
    _scrollToBottom();

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _messages.add({
        'speaker': 'Agent',
        'message': 'Please enter the amount you want to pay:',
        'alignment': Alignment.centerLeft,
        'showBillAmountInput': true,
        'selectedBillType': provider,
        'billCategory': category,
        'billAmount': billAmount,
        'billDueDate': dueDate.toIso8601String(),
      });
    });
    _scrollToBottom();
  }

  void _handleBillPayment(String amount, String billType, double totalBillAmount, {String? dueDate}) async {
    final paymentAmount = double.tryParse(amount.replaceAll('RM', '').replaceAll(',', '').trim()) ?? 0.0;
    final remaining = totalBillAmount - paymentAmount;
    final isPaidInFull = remaining <= 0.01;
    
    // Parse due date
    DateTime? dueDateParsed;
    if (dueDate != null) {
      dueDateParsed = DateTime.tryParse(dueDate);
    }
    dueDateParsed ??= DateTime.now().add(const Duration(days: 14)); // Default 14 days

    // Show biometric verification
    _showBiometricVerification(
      onSuccess: () async {
        setState(() {
          _messages.add({
            'speaker': 'Agent',
            'message': '✓ Verification successful! Processing payment...',
            'alignment': Alignment.centerLeft,
          });
        });
        _scrollToBottom();

        await Future.delayed(const Duration(milliseconds: 1000));

        // Generate receipt data
        final now = DateTime.now();
        final transactionId = 'BP${now.millisecondsSinceEpoch.toString().substring(7)}';

        // Show receipt (NO LOOP - just show the receipt with remaining balance info)
        setState(() {
          _messages.add({
            'speaker': 'Agent',
            'message': isPaidInFull ? '✓ Payment completed!' : '✓ Partial payment received!',
            'alignment': Alignment.centerLeft,
            'showBillReceipt': true,
            'billData': {
              'billType': billType,
              'paidAmount': paymentAmount,
              'totalAmount': totalBillAmount,
              'remaining': remaining,
              'transactionId': transactionId,
              'dueDate': '${dueDateParsed!.day}/${dueDateParsed.month}/${dueDateParsed.year}',
              'isPaidInFull': isPaidInFull,
            },
          });
        });
        _scrollToBottom();
      },
      onCancel: () {
        setState(() {
          _messages.add({
            'speaker': 'Agent',
            'message': '❌ Verification cancelled. Payment not processed.',
            'alignment': Alignment.centerLeft,
          });
        });
        _scrollToBottom();
      },
    );
  }

  void _handleBillPaymentLegacy(String amount, String billType, double totalBillAmount) async {
    // Legacy method kept for backwards compatibility
    _handleBillPayment(amount, billType, totalBillAmount);
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
            vertical: AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme),
              const SizedBox(height: AppSpacing.md),
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
                      } else if (msg['showWithdrawalBankSelection'] == true) {
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
                            _WithdrawalBankGrid(onBankSelected: _handleWithdrawalBankSelection),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        );
                      } else if (msg['showWithdrawalAccountSelection'] == true) {
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
                            _WithdrawalAccountGrid(onAccountSelected: _handleWithdrawalAccountSelection),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        );
                      } else if (msg['showWithdrawalAmountSelection'] == true) {
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
                            _WithdrawalAmountSelector(
                              account: msg['selectedAccount'],
                              onAmountSelected: (amount) => _handleWithdrawalAmountSelection(amount, msg['selectedAccount']),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        );
                      } else if (msg['showBranchSelection'] == true) {
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
                            _BranchSelector(
                              onBranchSelected: (branch) => _handleBranchSelection(
                                branch, 
                                msg['selectedAmount'], 
                                msg['selectedAccount'],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        );
                      } else if (msg['showCustomBankForm'] == true) {
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
                            _CustomBankForm(onSubmit: _handleCustomBankSubmit),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        );
                      } else if (msg['showWithdrawalAmountInput'] == true) {
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
                            _WithdrawalAmountInput(
                              bank: msg['selectedBank'],
                              onSubmit: (amount) => _handleWithdrawalAmount(amount, msg['selectedBank']),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        );
                      } else if (msg['showWithdrawalQR'] == true) {
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
                            _WithdrawalQRCard(
                              withdrawalData: msg['withdrawalData'],
                              onCollected: () => _handleWithdrawalCollected(msg['withdrawalData']),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        );
                      } else if (msg['showWithdrawalReceipt'] == true) {
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
                            _WithdrawalReceipt(
                              withdrawalData: msg['withdrawalData'],
                              action: msg['receiptAction'],
                              onAction: (action) => _handleWithdrawalReceiptAction(action, msg['withdrawalData']),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        );
                      } else if (msg['showInvoice'] == true) {
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
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              decoration: BoxDecoration(
                                color: AppColors.glassWhiteLight,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                child: Image.asset(
                                  'assets/images/invoice.webp',
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 150,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: AppColors.cardBackground,
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                      ),
                                      child: const Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.receipt_long, size: 48, color: AppColors.textSecondary),
                                          SizedBox(height: 8),
                                          Text('Invoice Image', style: TextStyle(color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        );
                      } else if (msg['showBillTypeSelection'] == true) {
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
                            _BillCategoryGrid(onCategorySelected: _handleBillTypeSelection),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        );
                      } else if (msg['showBillProviderSelection'] == true) {
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
                            _BillProviderGrid(
                              category: msg['billCategory'],
                              onProviderSelected: (provider) => _handleBillProviderSelection(provider, msg['billCategory']),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        );
                      } else if (msg['showBillAmountInput'] == true) {
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
                            _BillAmountInput(
                              billType: msg['selectedBillType'],
                              totalAmount: msg['billAmount'],
                              dueDate: msg['billDueDate'],
                              onSubmit: (amount) => _handleBillPayment(
                                amount, 
                                msg['selectedBillType'], 
                                msg['billAmount'],
                                dueDate: msg['billDueDate'],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        );
                      } else if (msg['showBillReceipt'] == true) {
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
                            _BillPaymentReceipt(
                              billData: msg['billData'],
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
              // Quick action buttons
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _handleQuickTransfer,
                            icon: const Icon(Icons.send, size: 18),
                            label: const Text('Transfer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _handleQuickCashWithdrawal,
                            icon: const Icon(Icons.atm, size: 18),
                            label: const Text('Cash Withdrawal'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _handleQuickBillPayment,
                        icon: const Icon(Icons.receipt_long, size: 18),
                        label: const Text('Bill Payment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.positive,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                        ),
                      ),
                    ),
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
        if (widget.onBackToHome != null)
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: widget.onBackToHome,
          )
        else
          const SizedBox(width: 48),
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
  final _accountNumberController = TextEditingController();
  final _reasonController = TextEditingController();
  final _searchController = TextEditingController();
  
  String _selectedTransferType = 'DuitNow';
  String? _selectedPresetAmount;
  Map<String, String>? _selectedRecipient;
  bool _showNewRecipientForm = false;
  String? _selectedBank;
  String _searchQuery = '';
  
  static const List<String> _quickAmounts = ['50', '100', '200', '500', '1000', '2000'];
  
  // Recent transfer accounts (mock data - in real app, this would come from backend)
  static const List<Map<String, String>> _recentRecipients = [
    {
      'name': 'Ahmad bin Abdullah',
      'bank': 'Maybank',
      'accountNumber': '1234-5678-9012',
      'avatar': 'A',
    },
    {
      'name': 'Sarah Lee',
      'bank': 'CIMB Bank',
      'accountNumber': '9876-5432-1098',
      'avatar': 'S',
    },
    {
      'name': 'Muhammad Rizal',
      'bank': 'Public Bank',
      'accountNumber': '5555-4444-3333',
      'avatar': 'M',
    },
    {
      'name': 'Priya Krishnan',
      'bank': 'Hong Leong Bank',
      'accountNumber': '1111-2222-3333',
      'avatar': 'P',
    },
    {
      'name': 'Tan Wei Ming',
      'bank': 'RHB Bank',
      'accountNumber': '7777-8888-9999',
      'avatar': 'T',
    },
    {
      'name': 'Fatimah Zahra',
      'bank': 'Bank Islam',
      'accountNumber': '4444-5555-6666',
      'avatar': 'F',
    },
  ];

  // All Malaysian banks list
  static const List<String> _allBanks = [
    'Maybank', 'CIMB Bank', 'Public Bank', 'RHB Bank', 'Hong Leong Bank', 'AmBank',
    'Bank Islam', 'Bank Muamalat', 'Bank Rakyat', 'BSN', 'Affin Bank', 'Alliance Bank',
    'MBSB Bank', 'Agrobank', 'HSBC', 'Standard Chartered', 'OCBC Bank', 'UOB', 'Citibank',
    'Maybank Islamic', 'CIMB Islamic', 'Public Islamic Bank', 'RHB Islamic',
    'Hong Leong Islamic', 'AmBank Islamic', 'GXBank', 'Boost Bank', 'AEON Bank', 'GoBank',
  ];

  List<Map<String, String>> get _filteredRecipients {
    if (_searchQuery.isEmpty) return _recentRecipients;
    final query = _searchQuery.toLowerCase();
    return _recentRecipients.where((r) =>
        r['name']!.toLowerCase().contains(query) ||
        r['bank']!.toLowerCase().contains(query) ||
        r['accountNumber']!.contains(query)
    ).toList();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _recipientController.dispose();
    _accountNumberController.dispose();
    _reasonController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _selectRecipient(Map<String, String> recipient) {
    setState(() {
      _selectedRecipient = recipient;
      _showNewRecipientForm = false;
      _recipientController.text = recipient['name']!;
      _accountNumberController.text = recipient['accountNumber']!;
      _selectedBank = recipient['bank'];
    });
  }

  void _showOtherRecipientForm() {
    setState(() {
      _selectedRecipient = null;
      _showNewRecipientForm = true;
      _recipientController.clear();
      _accountNumberController.clear();
      _selectedBank = null;
    });
  }

  void _submit() {
    String amount = _selectedPresetAmount ?? _amountController.text;
    if (amount.isEmpty) return;
    
    if (_selectedRecipient != null) {
      widget.onSubmit({
        'amount': amount,
        'recipient': _selectedRecipient!['name']!,
        'accountNumber': _selectedRecipient!['accountNumber']!,
        'bank': _selectedRecipient!['bank']!,
        'transferType': _selectedTransferType,
        'reason': _reasonController.text.isEmpty ? 'Payment' : _reasonController.text,
      });
    } else if (_showNewRecipientForm) {
      if (_recipientController.text.isEmpty ||
          _accountNumberController.text.isEmpty ||
          _selectedBank == null) {
        return;
      }
      widget.onSubmit({
        'amount': amount,
        'recipient': _recipientController.text,
        'accountNumber': _accountNumberController.text,
        'bank': _selectedBank!,
        'transferType': _selectedTransferType,
        'reason': _reasonController.text.isEmpty ? 'Payment' : _reasonController.text,
      });
    }
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
          // Step 1: Select Recipient
          if (_selectedRecipient == null && !_showNewRecipientForm) ...[
            _buildRecipientSelection(),
          ] else ...[
            // Show selected recipient or new recipient form
            _buildSelectedRecipientOrForm(),
            const SizedBox(height: AppSpacing.lg),
            
            // Step 2: Transfer Type
            _buildTransferTypeSection(),
            const SizedBox(height: AppSpacing.lg),
            
            // Step 3: Amount Selection
            _buildAmountSection(),
            const SizedBox(height: AppSpacing.md),
            
            // Step 4: Description
            _buildTextField('Description (Optional)', _reasonController, TextInputType.text),
            const SizedBox(height: AppSpacing.lg),
            
            // Submit Button
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
        ],
      ),
    );
  }

  Widget _buildRecipientSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transfer Accounts',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        
        // Search field
        TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: 'Search by name, bank, or account...',
            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  )
                : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        
        // Recent recipients list
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280),
          child: _filteredRecipients.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 40, color: AppColors.textSecondary.withOpacity(0.5)),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'No matching accounts found',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredRecipients.length,
                  itemBuilder: (context, index) {
                    final recipient = _filteredRecipients[index];
                    return _buildRecipientTile(recipient);
                  },
                ),
        ),
        
        const SizedBox(height: AppSpacing.md),
        const Divider(),
        const SizedBox(height: AppSpacing.sm),
        
        // Other / New Recipient button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _showOtherRecipientForm,
            icon: const Icon(Icons.person_add, size: 20),
            label: const Text('Transfer to New Recipient', style: TextStyle(fontWeight: FontWeight.w600)),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              side: BorderSide(color: AppColors.accent.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecipientTile(Map<String, String> recipient) {
    return InkWell(
      onTap: () => _selectRecipient(recipient),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accent, AppColors.accentBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Text(
                  recipient['avatar']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipient['name']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${recipient['bank']} • ${recipient['accountNumber']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedRecipientOrForm() {
    if (_selectedRecipient != null) {
      // Show selected recipient
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.accent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.accent, AppColors.accentBlue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Center(
                child: Text(
                  _selectedRecipient!['avatar']!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedRecipient!['name']!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${_selectedRecipient!['bank']} • ${_selectedRecipient!['accountNumber']}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _selectedRecipient = null),
              icon: const Icon(Icons.edit, size: 20),
              color: AppColors.accent,
            ),
          ],
        ),
      );
    } else {
      // Show new recipient form
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'New Recipient',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => setState(() => _showNewRecipientForm = false),
                child: const Text('Cancel'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Bank Selection Dropdown
          const Text(
            'Select Bank',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedBank,
                hint: const Text('Choose bank'),
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: _allBanks.map((bank) => DropdownMenuItem(
                  value: bank,
                  child: Text(bank),
                )).toList(),
                onChanged: (value) => setState(() => _selectedBank = value),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildTextField('Recipient Name', _recipientController, TextInputType.name),
          const SizedBox(height: AppSpacing.md),
          _buildTextField('Account Number', _accountNumberController, TextInputType.number),
        ],
      );
    }
  }

  Widget _buildTransferTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Transfer Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            Expanded(
              child: _buildTransferTypeButton('DuitNow', Icons.flash_on),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildTransferTypeButton('IBG', Icons.account_balance),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Amount',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: _quickAmounts.map((amount) => GestureDetector(
            onTap: () {
              setState(() {
                _selectedPresetAmount = amount;
                _amountController.clear();
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: _selectedPresetAmount == amount 
                    ? AppColors.accent 
                    : Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: _selectedPresetAmount == amount 
                      ? AppColors.accent 
                      : Colors.grey.shade300,
                ),
              ),
              child: Text(
                'RM $amount',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _selectedPresetAmount == amount 
                      ? Colors.white 
                      : AppColors.textPrimary,
                ),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: AppSpacing.md),
        _buildAmountField(),
      ],
    );
  }
  
  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Or enter custom amount',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          onChanged: (_) {
            if (_amountController.text.isNotEmpty) {
              setState(() => _selectedPresetAmount = null);
            }
          },
          decoration: InputDecoration(
            prefixText: 'RM ',
            hintText: 'Enter amount',
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

  Widget _buildTransferTypeButton(String type, IconData icon) {
    final isSelected = _selectedTransferType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedTransferType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.accent : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              type,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.accent : AppColors.textSecondary,
              ),
            ),
          ],
        ),
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
          _buildRow('Transfer Type', formData['transferType'] ?? 'DuitNow'),
          _buildRow('Amount', 'RM ${formData['amount']}'),
          _buildRow('Recipient', formData['recipient'] ?? ''),
          _buildRow('Account Number', formData['accountNumber'] ?? ''),
          _buildRow('Description', formData['reason'] ?? ''),
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
                if (formData['transferType'] != null && formData['transferType']!.isNotEmpty)
                  _buildRow('Transfer Type', formData['transferType']!),
                _buildRow('Recipient', formData['recipient'] ?? ''),
                if (formData['accountNumber'] != null && formData['accountNumber']!.isNotEmpty)
                  _buildRow('Account No.', formData['accountNumber']!),
                _buildRow('Phone', formData['phone'] ?? ''),
                if (formData['description'] != null && formData['description']!.isNotEmpty)
                  _buildRow('Description', formData['description']!),
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
    this.useMarkdown = true,
  });

  final String speaker;
  final String message;
  final Alignment alignment;
  final Color bubbleColor;
  final Color textColor;
  final bool useMarkdown;

  @override
  Widget build(BuildContext context) {
    // Determine if message is from Agent (left aligned) for markdown rendering
    final isAgentMessage = alignment == Alignment.centerLeft;
    
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
                // Use Markdown for agent messages, plain text for user messages
                if (useMarkdown && isAgentMessage)
                  MarkdownBody(
                    data: message,
                    selectable: true,
                    shrinkWrap: true,
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        fontSize: 15,
                        color: textColor,
                        height: 1.4,
                      ),
                      strong: TextStyle(
                        fontSize: 15,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                      em: TextStyle(
                        fontSize: 15,
                        color: textColor,
                        fontStyle: FontStyle.italic,
                      ),
                      code: TextStyle(
                        fontSize: 13,
                        color: AppColors.accent,
                        backgroundColor: AppColors.accent.withOpacity(0.1),
                        fontFamily: 'monospace',
                      ),
                      codeblockDecoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      blockquote: TextStyle(
                        fontSize: 15,
                        color: textColor.withOpacity(0.8),
                        fontStyle: FontStyle.italic,
                      ),
                      blockquoteDecoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: AppColors.accent,
                            width: 3,
                          ),
                        ),
                      ),
                      blockquotePadding: const EdgeInsets.only(left: 12),
                      listBullet: TextStyle(
                        fontSize: 15,
                        color: textColor,
                      ),
                      h1: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      h2: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      h3: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      tableHead: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      tableBody: TextStyle(
                        fontSize: 14,
                        color: textColor,
                      ),
                      tableBorder: TableBorder.all(
                        color: textColor.withOpacity(0.3),
                        width: 1,
                      ),
                      tableCellsPadding: const EdgeInsets.all(8),
                      horizontalRuleDecoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: textColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  )
                else
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

// Withdrawal Bank Selection Grid with Search
class _WithdrawalBankGrid extends StatefulWidget {
  const _WithdrawalBankGrid({required this.onBankSelected});

  final Function(String) onBankSelected;

  @override
  State<_WithdrawalBankGrid> createState() => _WithdrawalBankGridState();
}

class _WithdrawalBankGridState extends State<_WithdrawalBankGrid> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  // Complete list of banks in Malaysia
  static const List<Map<String, String>> _allBanks = [
    // Local Commercial Banks
    {'name': 'Maybank', 'fullName': 'Malayan Banking Berhad', 'type': 'local'},
    {'name': 'CIMB Bank', 'fullName': 'CIMB Bank Berhad', 'type': 'local'},
    {'name': 'Public Bank', 'fullName': 'Public Bank Berhad', 'type': 'local'},
    {'name': 'RHB Bank', 'fullName': 'RHB Bank Berhad', 'type': 'local'},
    {'name': 'Hong Leong Bank', 'fullName': 'Hong Leong Bank Berhad', 'type': 'local'},
    {'name': 'AmBank', 'fullName': 'AmBank (M) Berhad', 'type': 'local'},
    {'name': 'Bank Islam', 'fullName': 'Bank Islam Malaysia Berhad', 'type': 'islamic'},
    {'name': 'Bank Muamalat', 'fullName': 'Bank Muamalat Malaysia Berhad', 'type': 'islamic'},
    {'name': 'Bank Rakyat', 'fullName': 'Bank Kerjasama Rakyat Malaysia Berhad', 'type': 'local'},
    {'name': 'BSN', 'fullName': 'Bank Simpanan Nasional', 'type': 'local'},
    {'name': 'Affin Bank', 'fullName': 'Affin Bank Berhad', 'type': 'local'},
    {'name': 'Alliance Bank', 'fullName': 'Alliance Bank Malaysia Berhad', 'type': 'local'},
    {'name': 'MBSB Bank', 'fullName': 'Malaysia Building Society Berhad', 'type': 'islamic'},
    {'name': 'Agrobank', 'fullName': 'Agrobank (Bank Pertanian Malaysia)', 'type': 'local'},
    {'name': 'Bank Pertanian', 'fullName': 'Bank Pertanian Malaysia Berhad', 'type': 'local'},
    
    // Foreign Banks
    {'name': 'HSBC', 'fullName': 'HSBC Bank Malaysia Berhad', 'type': 'foreign'},
    {'name': 'Standard Chartered', 'fullName': 'Standard Chartered Bank Malaysia', 'type': 'foreign'},
    {'name': 'OCBC Bank', 'fullName': 'OCBC Bank (Malaysia) Berhad', 'type': 'foreign'},
    {'name': 'UOB', 'fullName': 'United Overseas Bank (Malaysia)', 'type': 'foreign'},
    {'name': 'Citibank', 'fullName': 'Citibank Berhad', 'type': 'foreign'},
    {'name': 'Deutsche Bank', 'fullName': 'Deutsche Bank (Malaysia) Berhad', 'type': 'foreign'},
    {'name': 'Bank of China', 'fullName': 'Bank of China (Malaysia) Berhad', 'type': 'foreign'},
    {'name': 'ICBC', 'fullName': 'Industrial and Commercial Bank of China', 'type': 'foreign'},
    {'name': 'Bank of America', 'fullName': 'Bank of America Malaysia Berhad', 'type': 'foreign'},
    {'name': 'JP Morgan', 'fullName': 'J.P. Morgan Chase Bank Berhad', 'type': 'foreign'},
    {'name': 'BNP Paribas', 'fullName': 'BNP Paribas Malaysia Berhad', 'type': 'foreign'},
    {'name': 'Mizuho Bank', 'fullName': 'Mizuho Bank (Malaysia) Berhad', 'type': 'foreign'},
    {'name': 'Sumitomo Mitsui', 'fullName': 'Sumitomo Mitsui Banking Corporation', 'type': 'foreign'},
    {'name': 'India International Bank', 'fullName': 'India International Bank (Malaysia)', 'type': 'foreign'},
    {'name': 'Bangkok Bank', 'fullName': 'Bangkok Bank Berhad', 'type': 'foreign'},
    
    // Islamic Banks
    {'name': 'Maybank Islamic', 'fullName': 'Maybank Islamic Berhad', 'type': 'islamic'},
    {'name': 'CIMB Islamic', 'fullName': 'CIMB Islamic Bank Berhad', 'type': 'islamic'},
    {'name': 'Public Islamic Bank', 'fullName': 'Public Islamic Bank Berhad', 'type': 'islamic'},
    {'name': 'RHB Islamic', 'fullName': 'RHB Islamic Bank Berhad', 'type': 'islamic'},
    {'name': 'Hong Leong Islamic', 'fullName': 'Hong Leong Islamic Bank Berhad', 'type': 'islamic'},
    {'name': 'AmBank Islamic', 'fullName': 'AmBank Islamic Berhad', 'type': 'islamic'},
    {'name': 'Affin Islamic', 'fullName': 'Affin Islamic Bank Berhad', 'type': 'islamic'},
    {'name': 'Alliance Islamic', 'fullName': 'Alliance Islamic Bank Berhad', 'type': 'islamic'},
    {'name': 'HSBC Amanah', 'fullName': 'HSBC Amanah Malaysia Berhad', 'type': 'islamic'},
    {'name': 'OCBC Al-Amin', 'fullName': 'OCBC Al-Amin Bank Berhad', 'type': 'islamic'},
    {'name': 'Standard Chartered Saadiq', 'fullName': 'Standard Chartered Saadiq Berhad', 'type': 'islamic'},
    {'name': 'Kuwait Finance House', 'fullName': 'Kuwait Finance House (Malaysia)', 'type': 'islamic'},
    {'name': 'Al Rajhi Bank', 'fullName': 'Al Rajhi Banking & Investment Corporation', 'type': 'islamic'},
    
    // Digital Banks
    {'name': 'GXBank', 'fullName': 'GX Bank Berhad', 'type': 'digital'},
    {'name': 'Boost Bank', 'fullName': 'Boost Bank Berhad', 'type': 'digital'},
    {'name': 'AEON Bank', 'fullName': 'AEON Bank (M) Berhad', 'type': 'digital'},
    {'name': 'GoBank', 'fullName': 'GoBank Berhad', 'type': 'digital'},
    {'name': 'KAF Digital Bank', 'fullName': 'KAF Digital Bank Berhad', 'type': 'digital'},
  ];
  
  // Popular banks to show at top
  static const List<String> _popularBanks = [
    'Maybank', 'CIMB Bank', 'Public Bank', 'RHB Bank', 'Hong Leong Bank', 'AmBank'
  ];

  List<Map<String, String>> get _filteredBanks {
    if (_searchQuery.isEmpty) return _allBanks;
    final query = _searchQuery.toLowerCase();
    return _allBanks.where((bank) =>
        bank['name']!.toLowerCase().contains(query) ||
        bank['fullName']!.toLowerCase().contains(query)
    ).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.glassWhiteLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search field
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search bank name...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Popular banks (only show when not searching)
          if (_searchQuery.isEmpty) ...[
            const Text(
              'Popular Banks',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _popularBanks.map((bankName) => 
                _buildQuickBankChip(bankName)
              ).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'All Banks',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
          
          // Bank list
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: _filteredBanks.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Text(
                        'No banks found',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredBanks.length,
                    itemBuilder: (context, index) {
                      final bank = _filteredBanks[index];
                      return _buildBankListItem(bank);
                    },
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickBankChip(String bankName) {
    return GestureDetector(
      onTap: () => widget.onBankSelected(bankName),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accent.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.account_balance, size: 14, color: AppColors.accent),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              bankName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankListItem(Map<String, String> bank) {
    IconData typeIcon;
    Color typeColor;
    
    switch (bank['type']) {
      case 'islamic':
        typeIcon = Icons.mosque;
        typeColor = AppColors.positive;
        break;
      case 'foreign':
        typeIcon = Icons.public;
        typeColor = AppColors.accentBlue;
        break;
      case 'digital':
        typeIcon = Icons.phone_android;
        typeColor = AppColors.accent;
        break;
      default:
        typeIcon = Icons.account_balance;
        typeColor = AppColors.textSecondary;
    }
    
    return InkWell(
      onTap: () => widget.onBankSelected(bank['name']!),
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(typeIcon, color: typeColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    bank['name']!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    bank['fullName']!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary.withOpacity(0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// Withdrawal Account Selection Grid
class _WithdrawalAccountGrid extends StatelessWidget {
  const _WithdrawalAccountGrid({required this.onAccountSelected});

  final Function(Map<String, String>) onAccountSelected;

  static const List<Map<String, String>> _accounts = [
    {
      'name': 'Savings Account',
      'number': '****-****-1234',
      'balance': '15,680.50',
      'type': 'savings',
    },
    {
      'name': 'Current Account',
      'number': '****-****-5678',
      'balance': '8,420.00',
      'type': 'current',
    },
    {
      'name': 'Fixed Deposit',
      'number': '****-****-9012',
      'balance': '50,000.00',
      'type': 'fixed',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.glassWhiteLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: _accounts.map((account) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _buildAccountCard(account),
        )).toList(),
      ),
    );
  }

  Widget _buildAccountCard(Map<String, String> account) {
    IconData icon;
    Color color;
    switch (account['type']) {
      case 'savings':
        icon = Icons.savings;
        color = AppColors.positive;
        break;
      case 'current':
        icon = Icons.account_balance_wallet;
        color = AppColors.accentBlue;
        break;
      case 'fixed':
        icon = Icons.lock;
        color = AppColors.accent;
        break;
      default:
        icon = Icons.account_balance;
        color = AppColors.textSecondary;
    }

    return ElevatedButton(
      onPressed: () => onAccountSelected(account),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.all(AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account['name']!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  account['number']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'RM ${account['balance']}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const Text(
                'Available',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Withdrawal Amount Selector with preset amounts
class _WithdrawalAmountSelector extends StatefulWidget {
  const _WithdrawalAmountSelector({
    required this.account,
    required this.onAmountSelected,
  });

  final Map<String, String> account;
  final Function(String) onAmountSelected;

  @override
  State<_WithdrawalAmountSelector> createState() => _WithdrawalAmountSelectorState();
}

class _WithdrawalAmountSelectorState extends State<_WithdrawalAmountSelector> {
  final _customAmountController = TextEditingController();
  String? _selectedPreset;

  static const List<String> _presetAmounts = ['50', '100', '200', '500', '1000'];

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  void _submit() {
    String amount;
    if (_selectedPreset != null) {
      amount = _selectedPreset!;
    } else if (_customAmountController.text.trim().isNotEmpty) {
      amount = _customAmountController.text.trim();
    } else {
      return;
    }
    widget.onAmountSelected(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.glassWhiteLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account info
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: AppColors.accent, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    '${widget.account['name']} • RM ${widget.account['balance']} available',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Quick amounts
          const Text(
            'Quick Amount',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _presetAmounts.map((amount) => GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPreset = amount;
                  _customAmountController.clear();
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: _selectedPreset == amount 
                      ? AppColors.accent 
                      : Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: _selectedPreset == amount 
                        ? AppColors.accent 
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  'RM $amount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _selectedPreset == amount 
                        ? Colors.white 
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Custom amount
          const Text(
            'Or enter custom amount',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _customAmountController,
            keyboardType: TextInputType.number,
            onChanged: (_) {
              if (_customAmountController.text.isNotEmpty) {
                setState(() => _selectedPreset = null);
              }
            },
            decoration: InputDecoration(
              prefixText: 'RM ',
              hintText: 'Enter amount',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(color: AppColors.accent, width: 2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Continue button
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
}

// Branch Selector for ATM pickup
class _BranchSelector extends StatefulWidget {
  const _BranchSelector({required this.onBranchSelected});

  final Function(Map<String, dynamic>) onBranchSelected;

  @override
  State<_BranchSelector> createState() => _BranchSelectorState();
}

class _BranchSelectorState extends State<_BranchSelector> {
  String? _selectedBranch;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLocating = true;
  int _autoSelectedIndex = 0;

  static const List<Map<String, dynamic>> _branches = [
    {
      'name': 'KLCC Branch',
      'address': 'Suria KLCC, Kuala Lumpur',
      'distance': '0.5 km',
      'distanceValue': 0.5,
      'atmCount': 4,
      'atmId': 'ATM-KLCC-001',
      'lat': 3.1578,
      'lng': 101.7123,
    },
    {
      'name': 'Pavilion Branch',
      'address': 'Pavilion KL, Bukit Bintang',
      'distance': '1.2 km',
      'distanceValue': 1.2,
      'atmCount': 3,
      'atmId': 'ATM-PAV-001',
      'lat': 3.1488,
      'lng': 101.7134,
    },
    {
      'name': 'Mid Valley Branch',
      'address': 'Mid Valley Megamall',
      'distance': '3.5 km',
      'distanceValue': 3.5,
      'atmCount': 6,
      'atmId': 'ATM-MV-001',
      'lat': 3.1177,
      'lng': 101.6773,
    },
    {
      'name': 'Bangsar Branch',
      'address': 'Bangsar Village II',
      'distance': '4.8 km',
      'distanceValue': 4.8,
      'atmCount': 2,
      'atmId': 'ATM-BGR-001',
      'lat': 3.1298,
      'lng': 101.6708,
    },
    {
      'name': 'Sunway Pyramid Branch',
      'address': 'Sunway Pyramid, Subang',
      'distance': '8.2 km',
      'distanceValue': 8.2,
      'atmCount': 5,
      'atmId': 'ATM-SPY-001',
      'lat': 3.0733,
      'lng': 101.6078,
    },
    {
      'name': 'IOI City Mall Branch',
      'address': 'IOI City Mall, Putrajaya',
      'distance': '12.5 km',
      'distanceValue': 12.5,
      'atmCount': 4,
      'atmId': 'ATM-IOI-001',
      'lat': 2.9714,
      'lng': 101.7159,
    },
  ];

  List<Map<String, dynamic>> get _filteredBranches {
    if (_searchQuery.isEmpty) return _branches;
    return _branches.where((b) =>
        b['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
        b['address'].toString().toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  void initState() {
    super.initState();
    // Simulate auto-locating nearest branch
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLocating = false;
          _selectedBranch = _branches[_autoSelectedIndex]['name'];
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getGoogleMapsUrl(Map<String, dynamic> branch) {
    return 'https://www.google.com/maps/search/?api=1&query=${branch['lat']},${branch['lng']}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.glassWhiteLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Auto-locate banner
          if (_isLocating)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.accent),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Expanded(
                    child: Text(
                      'Finding nearest branch to your location...',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.positive.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.my_location, color: AppColors.positive, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Nearest branch: ${_branches[_autoSelectedIndex]['name']} (${_branches[_autoSelectedIndex]['distance']})',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.positive,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          
          // Search field
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              hintText: 'Search branch or location...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Branch list
          ..._filteredBranches.map((branch) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _buildBranchCard(branch),
          )),
          
          if (_filteredBranches.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: const Center(
                child: Text(
                  'No branches found',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          
          const SizedBox(height: AppSpacing.sm),
          
          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedBranch != null 
                  ? () {
                      final selected = _branches.firstWhere((b) => b['name'] == _selectedBranch);
                      widget.onBranchSelected(selected);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: const Text('Confirm Branch', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchCard(Map<String, dynamic> branch) {
    final isSelected = _selectedBranch == branch['name'];
    final isNearest = branch['name'] == _branches[_autoSelectedIndex]['name'];
    
    return GestureDetector(
      onTap: () => setState(() => _selectedBranch = branch['name']),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.accent : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.accent.withOpacity(0.2) 
                        : AppColors.textSecondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: isSelected ? AppColors.accent : AppColors.textSecondary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              branch['name'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? AppColors.accent : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isNearest) ...[
                            const SizedBox(width: AppSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.positive,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'NEAREST',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        branch['address'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.positive.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        branch['distance'],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.positive,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${branch['atmCount']} ATMs',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (isSelected) ...[
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(Icons.check_circle, color: AppColors.accent, size: 22),
                ],
              ],
            ),
            // Google Maps link when selected
            if (isSelected) ...[
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: () {
                  // Open Google Maps - in real app would use url_launcher
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.accentBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.map, size: 14, color: AppColors.accentBlue),
                      const SizedBox(width: 4),
                      Text(
                        'View on Google Maps',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.accentBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.open_in_new, size: 12, color: AppColors.accentBlue),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Withdrawal Amount Input
class _WithdrawalAmountInput extends StatefulWidget {
  const _WithdrawalAmountInput({
    required this.bank,
    required this.onSubmit,
  });

  final String bank;
  final Function(String) onSubmit;

  @override
  State<_WithdrawalAmountInput> createState() => _WithdrawalAmountInputState();
}

class _WithdrawalAmountInputState extends State<_WithdrawalAmountInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.glassWhiteLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Withdrawal Amount (RM)',
              hintText: 'Enter amount',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.accent.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.accent.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(color: AppColors.accent, width: 2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  widget.onSubmit(_controller.text.trim());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: const Text('Confirm Withdrawal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// Withdrawal QR Card - displays QR code for ATM withdrawal
class _WithdrawalQRCard extends StatelessWidget {
  const _WithdrawalQRCard({
    required this.withdrawalData,
    required this.onCollected,
  });

  final Map<String, dynamic> withdrawalData;
  final VoidCallback onCollected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.1),
            AppColors.accentBlue.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.qr_code_2, color: AppColors.accent, size: 28),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ATM Withdrawal Ready',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Scan at ${withdrawalData['branch']}',
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
          
          // QR Code Display
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Simulated QR Code
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // QR pattern simulation
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 15,
                          crossAxisSpacing: 1,
                          mainAxisSpacing: 1,
                        ),
                        itemCount: 225,
                        itemBuilder: (context, index) {
                          // Create a deterministic pattern based on qrCode
                          final hash = withdrawalData['qrCode'].hashCode;
                          final isBlack = ((hash + index * 7) % 3) != 0;
                          // Corner patterns
                          final row = index ~/ 15;
                          final col = index % 15;
                          final isCorner = (row < 3 && col < 3) || 
                                          (row < 3 && col > 11) ||
                                          (row > 11 && col < 3);
                          return Container(
                            decoration: BoxDecoration(
                              color: isCorner || isBlack ? AppColors.textPrimary : Colors.white,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          );
                        },
                      ),
                      // Bank logo in center
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.account_balance, color: AppColors.accent, size: 24),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // QR Code value
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    withdrawalData['qrCode'],
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Transaction Details
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              children: [
                _buildDetailRow('Amount', 'RM ${withdrawalData['amount'].toStringAsFixed(2)}', isHighlight: true),
                const Divider(height: AppSpacing.md),
                _buildDetailRow('Account', withdrawalData['account']),
                _buildDetailRow('Branch', withdrawalData['branch']),
                _buildDetailRow('ATM ID', withdrawalData['atmId']),
                _buildDetailRow('Expires', '15 minutes'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Google Maps Link
          GestureDetector(
            onTap: () {
              // In real app, use url_launcher to open Google Maps
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.accentBlue.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, color: AppColors.accentBlue, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Open in Google Maps',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accentBlue,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Icon(Icons.open_in_new, color: AppColors.accentBlue, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          
          // Location info
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Icon(Icons.location_on, color: AppColors.textSecondary, size: 16),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    withdrawalData['branchAddress'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Simulate collection button (for demo)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCollected,
              icon: const Icon(Icons.check_circle, size: 20),
              label: const Text('Simulate: Cash Collected', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.positive,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isHighlight ? 15 : 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isHighlight ? 18 : 13,
              fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              color: isHighlight ? AppColors.positive : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// Withdrawal Receipt
class _WithdrawalReceipt extends StatelessWidget {
  const _WithdrawalReceipt({
    required this.withdrawalData,
    this.action,
    required this.onAction,
  });

  final Map<String, dynamic> withdrawalData;
  final String? action;
  final Function(String) onAction;

  @override
  Widget build(BuildContext context) {
    final isCollected = withdrawalData['status'] == 'collected';
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.1),
            AppColors.accentBlue.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with collection status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.positive.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: AppColors.positive, size: 32),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCollected ? 'Cash Collected' : 'Cash Withdrawal',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      isCollected ? 'Money collected successfully' : 'Transaction successful',
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
          
          // Collection Status Banner (if collected)
          if (isCollected) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.positive.withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.positive.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified, color: AppColors.positive, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'CASH COLLECTED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.positive,
                            letterSpacing: 1,
                          ),
                        ),
                        if (withdrawalData['collectionTime'] != null)
                          Text(
                            'Collected at ${withdrawalData['collectionTime']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: AppSpacing.lg),
          // Transaction details
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              children: [
                if (withdrawalData['status'] == 'collected') ...[
                  _buildDetailRow('Status', '✅ COLLECTED', isPositive: true),
                  const Divider(height: AppSpacing.lg),
                ],
                _buildDetailRow('Date', withdrawalData['date']),
                const Divider(height: AppSpacing.lg),
                _buildDetailRow('Time', withdrawalData['time']),
                const Divider(height: AppSpacing.lg),
                _buildDetailRow('Account', withdrawalData['account'] ?? withdrawalData['bank'] ?? 'N/A'),
                const Divider(height: AppSpacing.lg),
                if (withdrawalData['branch'] != null) ...[
                  _buildDetailRow('Location', withdrawalData['branch']),
                  const Divider(height: AppSpacing.lg),
                ],
                if (withdrawalData['atmId'] != null) ...[
                  _buildDetailRow('ATM ID', withdrawalData['atmId']),
                  const Divider(height: AppSpacing.lg),
                ],
                _buildDetailRow('Original Balance', 'RM ${withdrawalData['originalBalance'].toStringAsFixed(2)}'),
                const Divider(height: AppSpacing.lg),
                _buildDetailRow('Withdrawal Amount', '- RM ${withdrawalData['amount'].toStringAsFixed(2)}', isNegative: true),
                const Divider(height: AppSpacing.lg),
                _buildDetailRow('New Balance', 'RM ${withdrawalData['newBalance'].toStringAsFixed(2)}', isBold: true),
                const Divider(height: AppSpacing.lg),
                _buildDetailRow('Transaction ID', withdrawalData['transactionId']),
              ],
            ),
          ),
          
          // Google Maps Link (if location available)
          if (withdrawalData['googleMapsUrl'] != null) ...[
            const SizedBox(height: AppSpacing.md),
            GestureDetector(
              onTap: () {
                // Open Google Maps - in real app would use url_launcher
              },
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map, color: AppColors.accentBlue, size: 18),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'View Location on Google Maps',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentBlue,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(Icons.open_in_new, color: AppColors.accentBlue, size: 14),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: AppSpacing.lg),
          // Action buttons
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close, size: 18),
                        SizedBox(width: AppSpacing.xs),
                        Text('Ignore', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onAction('print'),
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
                        Icon(Icons.picture_as_pdf, size: 18),
                        SizedBox(width: AppSpacing.xs),
                        Text('Print in PDF', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
                    action == 'ignore' ? Icons.block : Icons.check_circle,
                    color: action == 'ignore' ? AppColors.textSecondary : AppColors.positive,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    action == 'ignore' ? 'Ignored' : 'Generating PDF...',
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

  Widget _buildDetailRow(String label, String value, {bool isNegative = false, bool isBold = false, bool isPositive = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: isPositive ? AppColors.positive : (isNegative ? AppColors.negative : (isBold ? AppColors.textPrimary : AppColors.textPrimary)),
            fontWeight: isBold || isPositive ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Custom Bank Card Form
class _CustomBankForm extends StatefulWidget {
  const _CustomBankForm({required this.onSubmit});

  final Function(Map<String, String>) onSubmit;

  @override
  State<_CustomBankForm> createState() => _CustomBankFormState();
}

class _CustomBankFormState extends State<_CustomBankForm> {
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _bankNameController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _bankNameController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_cardNumberController.text.trim().isEmpty ||
        _expiryDateController.text.trim().isEmpty ||
        _bankNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: AppColors.negative,
        ),
      );
      return;
    }

    widget.onSubmit({
      'cardNumber': _cardNumberController.text.trim(),
      'expiryDate': _expiryDateController.text.trim(),
      'bankName': _bankNameController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.glassWhiteLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bank card image
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: Image.asset(
                'assets/images/bankcard.webp',
                height: 180,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.accent, AppColors.accentBlue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.credit_card, size: 48, color: Colors.white),
                        SizedBox(height: 8),
                        Text('Bank Card', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Card Number
          TextField(
            controller: _cardNumberController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Card Number',
              hintText: '1234 5678 9012 3456',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.accent.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.accent.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(color: AppColors.accent, width: 2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Expiry Date
          TextField(
            controller: _expiryDateController,
            keyboardType: TextInputType.datetime,
            decoration: InputDecoration(
              labelText: 'Expiry Date',
              hintText: 'MM/YY',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.accent.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.accent.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(color: AppColors.accent, width: 2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Bank Name
          TextField(
            controller: _bankNameController,
            decoration: InputDecoration(
              labelText: 'Bank Name',
              hintText: 'Enter your bank name',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.accent.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: BorderSide(color: AppColors.accent.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                borderSide: const BorderSide(color: AppColors.accent, width: 2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: const Text('Complete', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

// Biometric verification sheet for AI chat
class _AiBiometricSheet extends StatefulWidget {
  const _AiBiometricSheet({
    required this.onSuccess,
    required this.onCancel,
  });

  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  @override
  State<_AiBiometricSheet> createState() => _AiBiometricSheetState();
}

class _AiBiometricSheetState extends State<_AiBiometricSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _currentStep = 0;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _startVerification();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startVerification() async {
    setState(() => _isVerifying = true);
    
    // Step 1: Fingerprint
    _animationController.repeat();
    await Future.delayed(const Duration(milliseconds: 1800));
    setState(() => _currentStep = 1);
    
    // Step 2: Face
    await Future.delayed(const Duration(milliseconds: 1800));
    setState(() => _currentStep = 2);
    
    // Success
    _animationController.stop();
    await Future.delayed(const Duration(milliseconds: 500));
    widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
          const SizedBox(height: AppSpacing.xl),
          
          // Animated icon
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.accent.withOpacity(0.3 + (_animationController.value * 0.2)),
                      AppColors.accent.withOpacity(0.1),
                    ],
                  ),
                ),
                child: Icon(
                  _currentStep == 0
                      ? Icons.fingerprint
                      : _currentStep == 1
                          ? Icons.face
                          : Icons.check_circle,
                  size: 60,
                  color: _currentStep == 2 ? AppColors.positive : AppColors.accent,
                ),
              );
            },
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          Text(
            _currentStep == 0
                ? 'Verifying Fingerprint...'
                : _currentStep == 1
                    ? 'Verifying Face...'
                    : 'Verification Complete!',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: AppSpacing.sm),
          
          Text(
            _currentStep == 0
                ? 'Please place your finger on the sensor'
                : _currentStep == 1
                    ? 'Looking for your face...'
                    : 'Your identity has been confirmed',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: AppSpacing.xl),
          
          // Cancel button (only show during verification)
          if (_isVerifying && _currentStep < 2)
            TextButton(
              onPressed: widget.onCancel,
              child: const Text('Cancel'),
            ),
          
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// Bill category selection grid (first step)
class _BillCategoryGrid extends StatelessWidget {
  const _BillCategoryGrid({required this.onCategorySelected});

  final void Function(String) onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Utilities', 'icon': Icons.home, 'color': Colors.orange},
      {'name': 'Telecommunications', 'icon': Icons.wifi, 'color': Colors.blue},
      {'name': 'Entertainment', 'icon': Icons.tv, 'color': Colors.purple},
      {'name': 'Insurance', 'icon': Icons.security, 'color': Colors.green},
      {'name': 'Credit Card', 'icon': Icons.credit_card, 'color': AppColors.accent},
      {'name': 'Others', 'icon': Icons.more_horiz, 'color': Colors.grey},
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
            'Select Bill Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
              childAspectRatio: 2.2,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return InkWell(
                onTap: () => onCategorySelected(category['name'] as String),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: (category['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: (category['color'] as Color).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        color: category['color'] as Color,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          category['name'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: category['color'] as Color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Bill provider selection grid (second step - based on category)
class _BillProviderGrid extends StatelessWidget {
  const _BillProviderGrid({
    required this.category,
    required this.onProviderSelected,
  });

  final String category;
  final void Function(String) onProviderSelected;

  static const Map<String, List<Map<String, dynamic>>> _providers = {
    'Utilities': [
      {'name': 'TNB (Tenaga Nasional)', 'icon': Icons.electrical_services, 'color': Colors.orange},
      {'name': 'Air Selangor', 'icon': Icons.water_drop, 'color': Colors.blue},
      {'name': 'SYABAS', 'icon': Icons.water_drop, 'color': Colors.lightBlue},
      {'name': 'SAJ (Johor)', 'icon': Icons.water_drop, 'color': Colors.cyan},
      {'name': 'IWK', 'icon': Icons.sanitizer, 'color': Colors.teal},
      {'name': 'Indah Water', 'icon': Icons.water, 'color': Colors.blueGrey},
    ],
    'Telecommunications': [
      {'name': 'TM (Unifi)', 'icon': Icons.wifi, 'color': Colors.orange},
      {'name': 'Maxis', 'icon': Icons.phone_android, 'color': Colors.green},
      {'name': 'Celcom', 'icon': Icons.phone_android, 'color': Colors.blue},
      {'name': 'Digi', 'icon': Icons.phone_android, 'color': Colors.yellow},
      {'name': 'U Mobile', 'icon': Icons.phone_android, 'color': Colors.orange},
      {'name': 'Yes 4G', 'icon': Icons.phone_android, 'color': Colors.purple},
      {'name': 'Time Internet', 'icon': Icons.wifi, 'color': Colors.red},
    ],
    'Entertainment': [
      {'name': 'Astro', 'icon': Icons.tv, 'color': Colors.red},
      {'name': 'Netflix', 'icon': Icons.play_circle, 'color': Colors.red},
      {'name': 'Disney+ Hotstar', 'icon': Icons.play_circle, 'color': Colors.blue},
      {'name': 'Spotify', 'icon': Icons.music_note, 'color': Colors.green},
      {'name': 'YouTube Premium', 'icon': Icons.play_circle, 'color': Colors.red},
    ],
    'Insurance': [
      {'name': 'Prudential', 'icon': Icons.security, 'color': Colors.red},
      {'name': 'AIA', 'icon': Icons.security, 'color': Colors.pink},
      {'name': 'Great Eastern', 'icon': Icons.security, 'color': Colors.blue},
      {'name': 'Allianz', 'icon': Icons.security, 'color': Colors.indigo},
      {'name': 'Zurich', 'icon': Icons.security, 'color': Colors.blueGrey},
      {'name': 'AXA', 'icon': Icons.security, 'color': Colors.blue},
    ],
    'Credit Card': [
      {'name': 'Maybank Credit Card', 'icon': Icons.credit_card, 'color': Colors.yellow},
      {'name': 'CIMB Credit Card', 'icon': Icons.credit_card, 'color': Colors.red},
      {'name': 'Public Bank Credit Card', 'icon': Icons.credit_card, 'color': Colors.pink},
      {'name': 'RHB Credit Card', 'icon': Icons.credit_card, 'color': Colors.blue},
      {'name': 'Hong Leong Credit Card', 'icon': Icons.credit_card, 'color': Colors.green},
      {'name': 'AmBank Credit Card', 'icon': Icons.credit_card, 'color': Colors.orange},
    ],
    'Others': [
      {'name': 'PTPTN', 'icon': Icons.school, 'color': Colors.blue},
      {'name': 'KWSP (EPF)', 'icon': Icons.account_balance, 'color': Colors.purple},
      {'name': 'LHDN (Income Tax)', 'icon': Icons.receipt_long, 'color': Colors.green},
      {'name': 'JPJ (Road Tax)', 'icon': Icons.directions_car, 'color': Colors.orange},
      {'name': 'Zakat', 'icon': Icons.volunteer_activism, 'color': Colors.teal},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final providers = _providers[category] ?? _providers['Others']!;

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
          Row(
            children: [
              const Icon(Icons.arrow_back_ios, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.xs),
              Text(
                category,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Select Provider',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: providers.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final provider = providers[index];
              return InkWell(
                onTap: () => onProviderSelected(provider['name'] as String),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: (provider['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: (provider['color'] as Color).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (provider['color'] as Color).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Icon(
                          provider['icon'] as IconData,
                          color: provider['color'] as Color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          provider['name'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: provider['color'] as Color,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Bill amount input widget
class _BillAmountInput extends StatefulWidget {
  const _BillAmountInput({
    required this.billType,
    required this.totalAmount,
    required this.onSubmit,
    this.dueDate,
  });

  final String billType;
  final double totalAmount;
  final void Function(String) onSubmit;
  final String? dueDate;

  @override
  State<_BillAmountInput> createState() => _BillAmountInputState();
}

class _BillAmountInputState extends State<_BillAmountInput> {
  final _amountController = TextEditingController();
  bool _payFull = true;

  String get _formattedDueDate {
    if (widget.dueDate == null) return 'N/A';
    final date = DateTime.tryParse(widget.dueDate!);
    if (date == null) return widget.dueDate!;
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.totalAmount.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Pay ${widget.billType}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          
          // Total due with due date
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount Due:',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'RM ${widget.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
                if (widget.dueDate != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Due Date:',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      Text(
                        _formattedDueDate,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Pay full / Partial
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _payFull = true;
                      _amountController.text = widget.totalAmount.toStringAsFixed(2);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: _payFull ? AppColors.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.accent),
                    ),
                    child: Text(
                      'Pay Full',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _payFull ? Colors.white : AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _payFull = false;
                      _amountController.clear();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: !_payFull ? AppColors.accent : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.accent),
                    ),
                    child: Text(
                      'Partial',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: !_payFull ? Colors.white : AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          // Amount input
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            enabled: !_payFull,
            decoration: InputDecoration(
              labelText: 'Amount to Pay',
              prefixText: 'RM ',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Pay button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onSubmit(_amountController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
              child: const Text(
                'Pay Now',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Bill payment receipt widget
class _BillPaymentReceipt extends StatelessWidget {
  const _BillPaymentReceipt({required this.billData});

  final Map<String, dynamic> billData;

  @override
  Widget build(BuildContext context) {
    final billType = billData['billType'] ?? 'Unknown';
    final paidAmount = (billData['paidAmount'] ?? 0.0) is int 
        ? (billData['paidAmount'] as int).toDouble() 
        : (billData['paidAmount'] ?? 0.0) as double;
    final remaining = (billData['remaining'] ?? 0.0) is int 
        ? (billData['remaining'] as int).toDouble() 
        : (billData['remaining'] ?? 0.0) as double;
    final transactionId = billData['transactionId'] ?? 'TXN${DateTime.now().millisecondsSinceEpoch}';
    final dueDate = billData['dueDate'] as String?;
    final isPaidInFull = remaining <= 0.01;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Status icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isPaidInFull
                  ? AppColors.positive.withOpacity(0.15)
                  : Colors.orange.withOpacity(0.15),
            ),
            child: Icon(
              isPaidInFull ? Icons.check_circle : Icons.info,
              size: 40,
              color: isPaidInFull ? AppColors.positive : Colors.orange,
            ),
          ),
          
          const SizedBox(height: AppSpacing.md),
          
          Text(
            isPaidInFull ? 'Payment Successful!' : 'Partial Payment Made',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isPaidInFull ? AppColors.positive : Colors.orange,
            ),
          ),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Receipt details
          _buildReceiptRow('Bill Type', billType),
          _buildReceiptRow('Amount Paid', 'RM ${paidAmount.toStringAsFixed(2)}'),
          if (!isPaidInFull) ...[
            _buildReceiptRow('Remaining', 'RM ${remaining.toStringAsFixed(2)}', isHighlight: true),
            if (dueDate != null)
              _buildReceiptRow('Payment Due By', dueDate, isHighlight: true),
          ],
          _buildReceiptRow('Transaction ID', transactionId),
          _buildReceiptRow('Date', _formatDate(DateTime.now())),
          _buildReceiptRow('Time', _formatTime(DateTime.now())),
          
          const SizedBox(height: AppSpacing.lg),
          
          // Status banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isPaidInFull
                  ? AppColors.positive.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              children: [
                Text(
                  isPaidInFull
                      ? '✓ Your bill has been fully paid'
                      : '⚠ Outstanding balance: RM ${remaining.toStringAsFixed(2)}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isPaidInFull ? AppColors.positive : Colors.orange,
                  ),
                ),
                if (!isPaidInFull && dueDate != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Due by: $dueDate',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isHighlight ? Colors.orange : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
