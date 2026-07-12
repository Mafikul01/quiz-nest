import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../models/question_model.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

enum QuizState { initial, loading, loaded, error, empty }

class QuizProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final DatabaseService _dbService = DatabaseService();

  List<CategoryModel> _categories = [];
  List<QuestionModel> _questions = [];
  QuizState _state = QuizState.initial;
  String _errorMessage = '';
  String _currentCategoryName = '';

  // Quiz progress state
  int _currentQuestionIndex = 0;
  Map<int, int> _userAnswers = {}; 
  int _score = 0;
  int _earnedPoints = 0;

  List<CategoryModel> get categories => _categories;
  List<QuestionModel> get questions => _questions;
  QuizState get state => _state;
  String get errorMessage => _errorMessage;
  String get currentCategoryName => _currentCategoryName;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<int, int> get userAnswers => _userAnswers;
  int get score => _score;
  int get earnedPoints => _earnedPoints;

  Future<void> loadCategories({bool force = false}) async {
    if (!force && _categories.isNotEmpty && _state == QuizState.loaded) return;
    
    // Only show loading if we don't have data yet
    if (_categories.isEmpty) {
      _state = QuizState.loading;
      notifyListeners();
    }

    try {
      _categories = await _apiService.fetchCategories();
      _state = _categories.isEmpty ? QuizState.empty : QuizState.loaded;
    } catch (e) {
      if (_categories.isEmpty) {
        _state = QuizState.error;
        _errorMessage = 'Could not load categories. Please check your connection.';
      }
    }
    notifyListeners();
  }

  Future<void> loadQuestions(int categoryId) async {
    // If it's an AI quiz, we expect questions to be set externally via setAIQuestions
    if (categoryId == -1) return;

    _state = QuizState.loading;
    _questions = [];
    _currentQuestionIndex = 0;
    _userAnswers = {};
    _score = 0;
    _earnedPoints = 0;
    
    // Find category name
    final category = _categories.firstWhere(
      (c) => c.id == categoryId, 
      orElse: () => CategoryModel(
        id: categoryId, 
        name: 'Quiz', 
        description: '',
        createdAt: '',
        updatedAt: '',
      ),
    );
    _currentCategoryName = category.name;

    notifyListeners();
    
    try {
      _questions = await _apiService.fetchQuestions(categoryId);
      _state = _questions.isEmpty ? QuizState.empty : QuizState.loaded;
    } catch (e) {
      _state = QuizState.error;
      _errorMessage = 'Could not load questions. Please try again.';
    }
    notifyListeners();
  }

  void selectAnswer(int optionIndex) {
    _userAnswers[_currentQuestionIndex] = optionIndex;
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  void calculateScore() {
    _score = 0;
    _earnedPoints = 0;
    _userAnswers.forEach((index, selected) {
      if (index < _questions.length && selected == _questions[index].answerIndex) {
        _score++;
        _earnedPoints += _questions[index].mark;
      }
    });
    notifyListeners();
  }

  Future<void> submitResultToCloud(String uid) async {
    await _dbService.updateQuizProgress(
      uid: uid,
      earnedPoints: _earnedPoints,
      currentScore: _score,
    );
  }

  void resetQuiz() {
    _currentQuestionIndex = 0;
    _userAnswers = {};
    _score = 0;
    _earnedPoints = 0;
    _state = QuizState.initial;
    notifyListeners();
  }

  void setAIQuestions(List<QuestionModel> questions, String topic) {
    _state = QuizState.loading;
    _questions = questions;
    _currentQuestionIndex = 0;
    _userAnswers = {};
    _score = 0;
    _earnedPoints = 0;
    _currentCategoryName = topic;
    _state = QuizState.loaded;
    notifyListeners();
  }
}
