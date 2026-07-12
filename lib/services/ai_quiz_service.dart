import 'dart:convert';
import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/question_model.dart';

class AIQuizService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';

  Future<List<QuestionModel>> generateQuiz(String topic) async {
    String? apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      await dotenv.load(fileName: ".env");
      apiKey = dotenv.env['OPENAI_API_KEY'];
    }

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('OpenRouter API Key not found.');
    }

    final prompt = '''
Generate exactly 10 multiple-choice questions about "$topic".
Output ONLY a JSON object. NO markdown, NO code blocks, NO extra text.
Structure:
{
  "questions": [
    {
      "question": "...",
      "options": ["...", "...", "...", "..."],
      "correctAnswer": "..."
    }
  ]
}
Rules:
- Exactly 10 questions.
- Exactly 4 unique options per question.
- "correctAnswer" must match one of the items in "options" exactly.
- NO markdown tags like ```json.
''';

    final models = [
      'google/gemini-2.0-flash-lite-preview-02-05:free',
      'google/gemini-2.0-flash-001',
      'google/gemini-flash-1.5',
      'openrouter/auto'
    ];

    String? lastError;

    for (var modelId in models) {
      try {
        if (kDebugMode) {
          developer.log('AIQuizService: Requesting quiz from $modelId', name: 'ai.service');
        }

        final response = await http.post(
          Uri.parse(_baseUrl),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'HTTP-Referer': 'https://quiznest.app',
            'X-OpenRouter-Title': 'QuizNest',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'model': modelId,
            'messages': [{'role': 'user', 'content': prompt}],
            'temperature': 0.1,
          }),
        ).timeout(const Duration(seconds: 40));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          String content = data['choices'][0]['message']['content'] ?? '';
          content = _cleanJson(content);
          
          final Map<String, dynamic> decoded = jsonDecode(content);
          final List<dynamic>? questionsJson = decoded['questions'];

          if (questionsJson == null || questionsJson.length < 5) {
            throw Exception('Insufficient questions generated: ${questionsJson?.length}');
          }

          List<QuestionModel> validatedQuestions = [];
          
          for (int i = 0; i < questionsJson.length; i++) {
            final q = questionsJson[i];
            final String questionText = q['question']?.toString() ?? '';
            final List<dynamic> optionsRaw = q['options'] is List ? q['options'] : [];
            final String correctAnsText = q['correctAnswer']?.toString() ?? '';

            if (questionText.isEmpty || optionsRaw.length != 4 || correctAnsText.isEmpty) continue;

            List<String> options = optionsRaw.map((e) => e.toString()).toList();
            if (!options.contains(correctAnsText)) continue;

            // Shuffle in Flutter
            options.shuffle();
            int newAnswerIndex = options.indexOf(correctAnsText);

            validatedQuestions.add(QuestionModel(
              id: DateTime.now().millisecondsSinceEpoch + i,
              categoryId: -1,
              question: questionText,
              options: options,
              answerIndex: newAnswerIndex,
              mark: 10,
              createdAt: DateTime.now().toIso8601String(),
              updatedAt: DateTime.now().toIso8601String(),
            ));
          }

          if (validatedQuestions.length >= 8) { // Allow slight loss during validation
             return validatedQuestions.take(10).toList();
          }
          throw Exception('Validation failed for most questions.');
        } else {
          lastError = 'Status ${response.statusCode}: ${response.body}';
        }
      } catch (e) {
        developer.log('AIQuizService Error with $modelId: $e', name: 'error');
        lastError = e.toString();
      }
    }

    throw Exception('All AI models failed. Final error: $lastError');
  }

  String _cleanJson(String content) {
    content = content.trim();
    final startIndex = content.indexOf('{');
    final endIndex = content.lastIndexOf('}');
    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return content.substring(startIndex, endIndex + 1);
    }
    return content;
  }
}
