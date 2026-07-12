import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_quiz_service.dart';
import '../models/question_model.dart';

class AIQuizProvider extends ChangeNotifier {
  final AIQuizService _aiService = AIQuizService();
  final String _historyKey = 'ai_topic_history';

  List<String> _history = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<QuestionModel>? _generatedQuestions;

  List<String> get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<QuestionModel>? get generatedQuestions => _generatedQuestions;

  AIQuizProvider() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    _history = prefs.getStringList(_historyKey) ?? [];
    notifyListeners();
  }

  Future<void> _saveHistory(String topic) async {
    final prefs = await SharedPreferences.getInstance();
    if (_history.contains(topic)) {
      _history.remove(topic);
    }
    _history.insert(0, topic);
    if (_history.length > 10) {
      _history = _history.sublist(0, 10);
    }
    await prefs.setStringList(_historyKey, _history);
    notifyListeners();
  }

  Future<List<QuestionModel>?> generateAIQuiz(String topic) async {
    _isLoading = true;
    _errorMessage = null;
    _generatedQuestions = null;
    notifyListeners();

    try {
      final questions = await _aiService.generateQuiz(topic);
      _generatedQuestions = questions;
      await _saveHistory(topic);
      _isLoading = false;
      notifyListeners();
      return questions;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
