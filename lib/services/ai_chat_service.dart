import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:http/http.dart' as http;

/// Service class for communicating with the AI Agent backend API.
class AiChatService {
  /// Base URLs for different environments
  static const String _androidEmulatorUrl = 'http://10.0.2.2:8084';
  static const String _iosSimulatorUrl = 'http://localhost:8084';
  static const String _webUrl = 'http://localhost:8084';

  /// Get the appropriate base URL for the current platform
  static String get _defaultBaseUrl {
    if (kIsWeb) {
      return _webUrl;
    }
    try {
      if (Platform.isAndroid) {
        return _androidEmulatorUrl;
      } else if (Platform.isIOS) {
        return _iosSimulatorUrl;
      }
    } catch (e) {
      // Platform not available
    }
    return _iosSimulatorUrl;
  }

  /// Current session ID for conversation continuity
  String? _sessionId;

  /// User ID for the current user
  final String userId;

  /// HTTP client for making requests
  final http.Client _client;

  /// Current base URL (can be changed based on environment)
  String _currentBaseUrl;

  AiChatService({
    this.userId = 'user-001',
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _currentBaseUrl = baseUrl ?? _defaultBaseUrl {
    debugPrint('AiChatService initialized with URL: $_currentBaseUrl');
  }

  /// Set the base URL for API calls
  void setBaseUrl(String url) {
    _currentBaseUrl = url;
  }

  /// Get the current session ID
  String? get sessionId => _sessionId;

  /// Clear the current session
  void clearSession() {
    _sessionId = null;
  }

  /// Clear conversation history on the backend
  Future<void> clearHistory() async {
    if (_sessionId == null) return;
    
    try {
      await _client.delete(
        Uri.parse('$_currentBaseUrl/api/v1/chat/history'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'session_id': _sessionId,
          'user_id': userId,
        }),
      ).timeout(const Duration(seconds: 10));
      
      // Clear local session
      _sessionId = null;
      debugPrint('Chat history cleared');
    } catch (e) {
      debugPrint('Failed to clear history: $e');
      // Still clear local session even if backend fails
      _sessionId = null;
    }
  }

  /// Send a chat message to the AI agent and get a response.
  ///
  /// Returns a [ChatResponse] containing the assistant's message.
  /// Throws [AiChatException] if the request fails.
  Future<ChatResponse> sendMessage(String message) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_currentBaseUrl/api/v1/chat'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'message': message,
              'user_id': userId,
              if (_sessionId != null) 'session_id': _sessionId,
            }),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _sessionId = data['session_id'];

        // Parse chart_images if present
        List<String>? chartImages;
        if (data['chart_images'] != null) {
          chartImages = List<String>.from(data['chart_images']);
        }

        return ChatResponse(
          message: data['message'] ?? '',
          tldr: data['tldr'],
          sessionId: data['session_id'],
          timestamp:
              DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
          chartImages: chartImages,
        );
      } else {
        final errorBody = jsonDecode(response.body);
        throw AiChatException(
          'Failed to get response: ${errorBody['detail'] ?? response.reasonPhrase}',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw AiChatException('Request timed out. Please try again.');
    } catch (e) {
      if (e is AiChatException) rethrow;
      throw AiChatException('Connection error: $e');
    }
  }

  /// Send a message and receive a streaming response.
  ///
  /// Returns a [Stream] of text chunks as they arrive from the server.
  Stream<String> sendMessageStream(String message) async* {
    try {
      final request = http.Request(
        'POST',
        Uri.parse('$_currentBaseUrl/api/v1/chat/stream'),
      );

      request.headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
      });

      request.body = jsonEncode({
        'message': message,
        'user_id': userId,
        if (_sessionId != null) 'session_id': _sessionId,
      });

      final streamedResponse = await _client.send(request);

      // Update session ID from response headers
      final newSessionId = streamedResponse.headers['x-session-id'];
      if (newSessionId != null) {
        _sessionId = newSessionId;
      }

      await for (final chunk
          in streamedResponse.stream.transform(utf8.decoder)) {
        // Parse SSE format: "data: <content>\n\n"
        for (final line in chunk.split('\n')) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();
            if (data == '[DONE]') {
              return;
            } else if (data.startsWith('[ERROR]')) {
              throw AiChatException(data.substring(7).trim());
            } else {
              yield data;
            }
          }
        }
      }
    } catch (e) {
      if (e is AiChatException) rethrow;
      throw AiChatException('Stream error: $e');
    }
  }

  /// Check if the AI agent service is healthy/available.
  Future<bool> checkHealth() async {
    debugPrint('Checking AI backend health at: $_currentBaseUrl/health');
    try {
      final response = await _client
          .get(
            Uri.parse('$_currentBaseUrl/health'),
          )
          .timeout(const Duration(seconds: 5));

      debugPrint('Health check response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Health check failed: $e');
      return false;
    }
  }

  /// Get the current account balance.
  Future<Map<String, dynamic>> getBalance({
    String? accountId,
    bool showAll = false,
  }) async {
    try {
      final queryParams = <String, String>{
        'user_id': userId,
        'show_all': showAll.toString(),
      };
      if (accountId != null) {
        queryParams['account_id'] = accountId;
      }

      final uri = Uri.parse('$_currentBaseUrl/api/v1/accounts/balance')
          .replace(queryParameters: queryParams);

      final response =
          await _client.get(uri).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw AiChatException(
            'Failed to get balance: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is AiChatException) rethrow;
      throw AiChatException('Error getting balance: $e');
    }
  }

  /// Get transaction history.
  Future<Map<String, dynamic>> getTransactions({
    String? accountId,
    int limit = 10,
    String? transactionType,
  }) async {
    try {
      final queryParams = <String, String>{
        'user_id': userId,
        'limit': limit.toString(),
      };
      if (accountId != null) {
        queryParams['account_id'] = accountId;
      }
      if (transactionType != null) {
        queryParams['transaction_type'] = transactionType;
      }

      final uri = Uri.parse('$_currentBaseUrl/api/v1/accounts/transactions')
          .replace(queryParameters: queryParams);

      final response =
          await _client.get(uri).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw AiChatException(
            'Failed to get transactions: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is AiChatException) rethrow;
      throw AiChatException('Error getting transactions: $e');
    }
  }

  /// Get exchange rates.
  Future<Map<String, dynamic>> getExchangeRates({
    String? currency,
    bool showAll = true,
  }) async {
    try {
      final queryParams = <String, String>{
        'show_all': showAll.toString(),
      };
      if (currency != null) {
        queryParams['currency'] = currency;
      }

      final uri = Uri.parse('$_currentBaseUrl/api/v1/exchange-rates')
          .replace(queryParameters: queryParams);

      final response =
          await _client.get(uri).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw AiChatException(
            'Failed to get exchange rates: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is AiChatException) rethrow;
      throw AiChatException('Error getting exchange rates: $e');
    }
  }

  /// Calculate loan repayment.
  Future<Map<String, dynamic>> calculateLoan({
    required double principal,
    required double annualRate,
    required int tenureMonths,
  }) async {
    try {
      final queryParams = <String, String>{
        'principal': principal.toString(),
        'annual_rate': annualRate.toString(),
        'tenure_months': tenureMonths.toString(),
      };

      final uri = Uri.parse('$_currentBaseUrl/api/v1/loan/calculate')
          .replace(queryParameters: queryParams);

      final response =
          await _client.post(uri).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw AiChatException(
            'Failed to calculate loan: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is AiChatException) rethrow;
      throw AiChatException('Error calculating loan: $e');
    }
  }

  /// Get bill categories and providers.
  Future<Map<String, dynamic>> getBillCategories() async {
    try {
      final response = await _client
          .get(
            Uri.parse('$_currentBaseUrl/api/v1/bills/categories'),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw AiChatException(
            'Failed to get bill categories: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is AiChatException) rethrow;
      throw AiChatException('Error getting bill categories: $e');
    }
  }

  /// Get nearby ATMs.
  Future<Map<String, dynamic>> getNearbyAtms({
    double? latitude,
    double? longitude,
    int limit = 5,
  }) async {
    try {
      final queryParams = <String, String>{
        'limit': limit.toString(),
      };
      if (latitude != null) {
        queryParams['latitude'] = latitude.toString();
      }
      if (longitude != null) {
        queryParams['longitude'] = longitude.toString();
      }

      final uri = Uri.parse('$_currentBaseUrl/api/v1/atms/nearby')
          .replace(queryParameters: queryParams);

      final response =
          await _client.get(uri).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw AiChatException(
            'Failed to get nearby ATMs: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is AiChatException) rethrow;
      throw AiChatException('Error getting nearby ATMs: $e');
    }
  }

  /// Get spending chart data.
  Future<Map<String, dynamic>> getSpendingChart({
    String? accountId,
    int days = 30,
    String chartType = 'pie',
  }) async {
    try {
      final queryParams = <String, String>{
        'user_id': userId,
        'days': days.toString(),
        'chart_type': chartType,
        'format': 'json',
      };
      if (accountId != null) {
        queryParams['account_id'] = accountId;
      }

      final uri = Uri.parse('$_currentBaseUrl/api/v1/charts/spending')
          .replace(queryParameters: queryParams);

      final response =
          await _client.get(uri).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw AiChatException(
            'Failed to get spending chart: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is AiChatException) rethrow;
      throw AiChatException('Error getting spending chart: $e');
    }
  }

  /// Get balance trend chart data.
  Future<Map<String, dynamic>> getBalanceTrendChart({
    String? accountId,
    int days = 30,
  }) async {
    try {
      final queryParams = <String, String>{
        'user_id': userId,
        'days': days.toString(),
        'format': 'json',
      };
      if (accountId != null) {
        queryParams['account_id'] = accountId;
      }

      final uri = Uri.parse('$_currentBaseUrl/api/v1/charts/balance-trend')
          .replace(queryParameters: queryParams);

      final response =
          await _client.get(uri).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw AiChatException(
            'Failed to get balance trend chart: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is AiChatException) rethrow;
      throw AiChatException('Error getting balance trend chart: $e');
    }
  }

  /// Get income vs expense chart data.
  Future<Map<String, dynamic>> getIncomeExpenseChart({
    String? accountId,
    int days = 30,
    String chartType = 'bar',
  }) async {
    try {
      final queryParams = <String, String>{
        'user_id': userId,
        'days': days.toString(),
        'chart_type': chartType,
        'format': 'json',
      };
      if (accountId != null) {
        queryParams['account_id'] = accountId;
      }

      final uri = Uri.parse('$_currentBaseUrl/api/v1/charts/income-expense')
          .replace(queryParameters: queryParams);

      final response =
          await _client.get(uri).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw AiChatException(
            'Failed to get income/expense chart: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is AiChatException) rethrow;
      throw AiChatException('Error getting income/expense chart: $e');
    }
  }

  /// Get monthly summary chart data.
  Future<Map<String, dynamic>> getMonthlySummaryChart({
    String? accountId,
    int months = 6,
  }) async {
    try {
      final queryParams = <String, String>{
        'user_id': userId,
        'months': months.toString(),
        'format': 'json',
      };
      if (accountId != null) {
        queryParams['account_id'] = accountId;
      }

      final uri = Uri.parse('$_currentBaseUrl/api/v1/charts/monthly-summary')
          .replace(queryParameters: queryParams);

      final response =
          await _client.get(uri).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw AiChatException(
            'Failed to get monthly summary chart: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is AiChatException) rethrow;
      throw AiChatException('Error getting monthly summary chart: $e');
    }
  }

  /// Get analytics summary without charts.
  Future<Map<String, dynamic>> getAnalyticsSummary({
    String? accountId,
    int days = 30,
  }) async {
    try {
      final queryParams = <String, String>{
        'user_id': userId,
        'days': days.toString(),
      };
      if (accountId != null) {
        queryParams['account_id'] = accountId;
      }

      final uri = Uri.parse('$_currentBaseUrl/api/v1/analytics/summary')
          .replace(queryParameters: queryParams);

      final response =
          await _client.get(uri).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw AiChatException(
            'Failed to get analytics summary: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is AiChatException) rethrow;
      throw AiChatException('Error getting analytics summary: $e');
    }
  }

  /// Dispose of resources.
  void dispose() {
    _client.close();
  }
}

/// Response model for chat messages.
class ChatResponse {
  final String message;
  final String? tldr;  // TLDR summary for text-to-speech
  final String? sessionId;
  final DateTime timestamp;
  final List<String>? chartImages;

  ChatResponse({
    required this.message,
    this.tldr,
    this.sessionId,
    required this.timestamp,
    this.chartImages,
  });

  @override
  String toString() =>
      'ChatResponse(message: $message, tldr: $tldr, sessionId: $sessionId, chartImages: ${chartImages?.length ?? 0})';
}

/// Exception class for AI chat service errors.
class AiChatException implements Exception {
  final String message;
  final int? statusCode;

  AiChatException(this.message, {this.statusCode});

  @override
  String toString() =>
      'AiChatException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}
