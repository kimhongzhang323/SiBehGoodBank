import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service for ElevenLabs Text-to-Speech API integration.
/// Converts AI responses to natural sounding speech.
class ElevenLabsService {
  /// ElevenLabs API key - should be stored securely in production
  static const String _apiKey = 'sk_01c8e9326b9b0b46463461d9a481ffdc001a4ba3200f0680';
  
  /// Default voice ID - Rachel (calm, professional female voice)
  static const String _defaultVoiceId = '21m00Tcm4TlvDq8ikWAM';
  
  /// Alternative voice IDs
  static const Map<String, String> availableVoices = {
    'Rachel': '21m00Tcm4TlvDq8ikWAM',
    'Domi': 'AZnzlk1XvdvUeBnXmlld',
    'Bella': 'EXAVITQu4vr4xnSDxMaL',
    'Antoni': 'ErXwobaYiN019PkySvjV',
    'Elli': 'MF3mGyEYCl7XYWbV9V6O',
    'Josh': 'TxGEqnHWrfWFTfGW9XjX',
    'Arnold': 'VR6AewLTigWG4xSOukaG',
    'Adam': 'pNInz6obpgDQGcFmaJgB',
    'Sam': 'yoZ06aMxZJJ28mfd3POQ',
  };
  
  /// Base URL for ElevenLabs API
  static const String _baseUrl = 'https://api.elevenlabs.io/v1';
  
  /// HTTP client
  final http.Client _client;
  
  /// Selected voice ID
  String _currentVoiceId;
  
  /// Voice settings
  double _stability;
  double _similarityBoost;
  double _style;
  
  /// Callback for when audio is ready to play
  Function(Uint8List audioData)? onAudioReady;
  
  /// Callback for errors
  Function(String error)? onError;
  
  /// Whether service is enabled
  bool _isEnabled = false;
  
  /// Whether currently speaking
  bool _isSpeaking = false;
  
  ElevenLabsService({
    http.Client? client,
    String? voiceId,
    double stability = 0.5,
    double similarityBoost = 0.75,
    double style = 0.0,
  }) : _client = client ?? http.Client(),
       _currentVoiceId = voiceId ?? _defaultVoiceId,
       _stability = stability,
       _similarityBoost = similarityBoost,
       _style = style;
  
  /// Check if ElevenLabs API key is configured
  bool get isConfigured => _apiKey != 'YOUR_ELEVENLABS_API_KEY' && _apiKey.isNotEmpty;
  
  /// Get enabled status
  bool get isEnabled => _isEnabled && isConfigured;
  
  /// Set enabled status
  set isEnabled(bool value) => _isEnabled = value;
  
  /// Get speaking status
  bool get isSpeaking => _isSpeaking;
  
  /// Get current voice ID
  String get currentVoiceId => _currentVoiceId;
  
  /// Set voice by name or ID
  void setVoice(String voiceNameOrId) {
    if (availableVoices.containsKey(voiceNameOrId)) {
      _currentVoiceId = availableVoices[voiceNameOrId]!;
    } else {
      _currentVoiceId = voiceNameOrId;
    }
  }
  
  /// Set voice settings
  void setVoiceSettings({
    double? stability,
    double? similarityBoost,
    double? style,
  }) {
    if (stability != null) _stability = stability.clamp(0.0, 1.0);
    if (similarityBoost != null) _similarityBoost = similarityBoost.clamp(0.0, 1.0);
    if (style != null) _style = style.clamp(0.0, 1.0);
  }
  
  /// Convert text to speech and return audio data
  Future<Uint8List?> textToSpeech(String text) async {
    if (!isConfigured) {
      debugPrint('ElevenLabs: API key not configured');
      onError?.call('ElevenLabs API key not configured');
      return null;
    }
    
    if (text.isEmpty) {
      return null;
    }
    
    // Clean up the text - remove markdown and special characters for cleaner speech
    final cleanedText = _cleanTextForSpeech(text);
    
    if (cleanedText.isEmpty) {
      return null;
    }
    
    try {
      _isSpeaking = true;
      
      final response = await _client.post(
        Uri.parse('$_baseUrl/text-to-speech/$_currentVoiceId'),
        headers: {
          'Accept': 'audio/mpeg',
          'Content-Type': 'application/json',
          'xi-api-key': _apiKey,
        },
        body: jsonEncode({
          'text': cleanedText,
          'model_id': 'eleven_flash_v2',
          'voice_settings': {
            'stability': _stability,
            'similarity_boost': _similarityBoost,
            'style': _style,
            'use_speaker_boost': true,
          },
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final audioData = response.bodyBytes;
        onAudioReady?.call(audioData);
        return audioData;
      } else {
        final error = 'ElevenLabs API error: ${response.statusCode} - ${response.body}';
        debugPrint(error);
        onError?.call(error);
        return null;
      }
    } catch (e) {
      final error = 'ElevenLabs error: $e';
      debugPrint(error);
      onError?.call(error);
      return null;
    } finally {
      _isSpeaking = false;
    }
  }
  
  /// Stream text to speech for longer content
  Stream<Uint8List> textToSpeechStream(String text) async* {
    if (!isConfigured) {
      debugPrint('ElevenLabs: API key not configured');
      return;
    }
    
    final cleanedText = _cleanTextForSpeech(text);
    if (cleanedText.isEmpty) return;
    
    try {
      _isSpeaking = true;
      
      final request = http.Request(
        'POST',
        Uri.parse('$_baseUrl/text-to-speech/$_currentVoiceId/stream'),
      );
      
      request.headers.addAll({
        'Accept': 'audio/mpeg',
        'Content-Type': 'application/json',
        'xi-api-key': _apiKey,
      });
      
      request.body = jsonEncode({
        'text': cleanedText,
        'model_id': 'eleven_monolingual_v1',
        'voice_settings': {
          'stability': _stability,
          'similarity_boost': _similarityBoost,
          'style': _style,
        },
      });
      
      final streamedResponse = await _client.send(request);
      
      await for (final chunk in streamedResponse.stream) {
        yield Uint8List.fromList(chunk);
      }
    } catch (e) {
      debugPrint('ElevenLabs stream error: $e');
    } finally {
      _isSpeaking = false;
    }
  }
  
  /// Get available voices from API
  Future<List<Map<String, dynamic>>> getVoices() async {
    if (!isConfigured) {
      return [];
    }
    
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/voices'),
        headers: {
          'Accept': 'application/json',
          'xi-api-key': _apiKey,
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['voices'] ?? []);
      }
    } catch (e) {
      debugPrint('Error getting voices: $e');
    }
    
    return [];
  }
  
  /// Clean text for speech synthesis
  String _cleanTextForSpeech(String text) {
    // Remove markdown formatting
    String cleaned = text
        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'\1') // Bold
        .replaceAll(RegExp(r'\*(.+?)\*'), r'\1')     // Italic
        .replaceAll(RegExp(r'`(.+?)`'), r'\1')       // Code
        .replaceAll(RegExp(r'#{1,6}\s'), '')         // Headers
        .replaceAll(RegExp(r'\[(.+?)\]\(.+?\)'), r'\1') // Links
        .replaceAll(RegExp(r'[-*+]\s'), '')          // List markers
        .replaceAll(RegExp(r'\d+\.\s'), '')          // Numbered lists
        .replaceAll(RegExp(r'>\s'), '')              // Block quotes
        .replaceAll(RegExp(r'```[\s\S]*?```'), '')   // Code blocks
        .replaceAll(RegExp(r'---+'), '')             // Horizontal rules
        .replaceAll(RegExp(r'\n{3,}'), '\n\n');      // Multiple newlines
    
    // Remove emojis (they don't read well)
    cleaned = cleaned.replaceAll(
      RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{1F1E0}-\u{1F1FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]', unicode: true),
      ''
    );
    
    // Clean up whitespace
    cleaned = cleaned.trim();
    
    // Limit length for API constraints (5000 chars max)
    if (cleaned.length > 4500) {
      cleaned = '${cleaned.substring(0, 4500)}...';
    }
    
    return cleaned;
  }
  
  /// Stop current speech
  void stop() {
    _isSpeaking = false;
  }
  
  /// Dispose resources
  void dispose() {
    _client.close();
  }
}
