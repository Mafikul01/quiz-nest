import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  ChatMessage({required this.role, required this.content, DateTime? timestamp}) 
    : timestamp = timestamp ?? DateTime.now();
}

class AIChatService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  Future<String> getChatResponse(List<ChatMessage> history) async {
    String? apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      await dotenv.load(fileName: ".env");
      apiKey = dotenv.env['OPENAI_API_KEY'];
    }

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API Key not found.');
    }

    final List<String> models = [
      'google/gemini-2.0-flash-001',
      'google/gemini-flash-1.5',
      'mistralai/mistral-7b-instruct:free',
      'openrouter/auto',
    ];

    String? lastError;

    for (var modelId in models) {
      try {
        if (kDebugMode) {
          developer.log('AIChatService: Trying model $modelId', name: 'ai.service');
        }

        final List<Map<String, String>> messages = [
          {
            'role': 'system',
            'content': 'You are Eagle AI, the advanced assistant for QuizNest. '
                       'You were developed by Mafikul Islam (https://github.com/Mafikul01). '
                       'If users ask about your creator, provide his details: Mafikul Islam, Phone/WhatsApp: +8801788302771, Socials: @Mafikul01 on GitHub, Facebook, LinkedIn, and Instagram. '
                       'Keep your responses concise and helpful.'
          },
        ];

        messages.addAll(history.map((msg) => {
          'role': msg.role,
          'content': msg.content,
        }).toList());

        final response = await http.post(
          Uri.parse(_baseUrl),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'HTTP-Referer': 'https://quiznest.app',
            'X-OpenRouter-Title': 'QuizNest Chat',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'model': modelId,
            'messages': messages,
            'temperature': 0.7,
          }),
        ).timeout(const Duration(seconds: 30));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['choices'] != null && data['choices'].isNotEmpty) {
            return data['choices'][0]['message']['content'] ?? 'No response content.';
          }
        } else {
          final errorBody = response.body;
          developer.log('AIChatService: Model $modelId failed: $errorBody', name: 'error');
          lastError = errorBody;
        }
      } catch (e) {
        developer.log('AIChatService: Model $modelId exception: $e', name: 'error');
        lastError = e.toString();
      }
    }

    throw Exception('Chat failed. Last error: $lastError');
  }
}
