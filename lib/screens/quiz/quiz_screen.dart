import 'dart:async';
import '../../models/question_model.dart';
import '../../models/quiz_history_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_app_bar.dart';
import '../result/result_screen.dart';

class QuizScreen extends StatefulWidget {
  final int categoryId;
  final List<QuestionModel>? aiQuestions;
  final String? topic;
  const QuizScreen({super.key, required this.categoryId, this.aiQuestions, this.topic});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Timer? _timer;
  int _secondsRemaining = 30;
  bool _isSaving = false;
  late DateTime _startTime;

  @override
  void initState() {
    super.initState();
    _startTime = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.aiQuestions != null) {
        context.read<QuizProvider>().setAIQuestions(widget.aiQuestions!, widget.topic ?? 'AI Quiz');
      } else {
        context.read<QuizProvider>().loadQuestions(widget.categoryId);
      }
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsRemaining = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final quiz = context.read<QuizProvider>();
      if (quiz.state == QuizState.loaded && !_isSaving) {
        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _nextQuestion();
          }
        });
      }
    });
  }

  void _nextQuestion() {
    final quiz = context.read<QuizProvider>();
    if (quiz.currentQuestionIndex < quiz.questions.length - 1) {
      quiz.nextQuestion();
      _startTimer();
    } else {
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    _timer?.cancel();
    final quiz = context.read<QuizProvider>();
    final auth = context.read<AuthProvider>();

    quiz.calculateScore();

    setState(() {
      _isSaving = true;
    });

    try {
      if (auth.user != null) {
        // Atomic update in Firestore
        await quiz.submitResultToCloud(auth.user!.uid);

        // Save to Quiz History
        final duration = DateTime.now().difference(_startTime);
        final minutes = duration.inMinutes;
        final seconds = duration.inSeconds % 60;
        final durationString = '${minutes}m ${seconds}s';

        final history = QuizHistoryModel(
          id: '', // Will be set by Firestore
          quizType: widget.aiQuestions != null ? 'AI' : 'API',
          title: quiz.currentCategoryName,
          category: quiz.currentCategoryName,
          score: quiz.score,
          totalQuestions: quiz.questions.length,
          correctAnswers: quiz.score,
          wrongAnswers: quiz.questions.length - quiz.score,
          percentage: (quiz.score / quiz.questions.length) * 100,
          date: DateTime.now(),
          duration: durationString,
        );

        await auth.dbService.saveQuizHistory(auth.user!.uid, history);

        // Refresh local user data stream
        await auth.refreshUserData();
      }
    } catch (e) {
      debugPrint('Error saving quiz result: $e');
    }

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ResultScreen()),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Quiz Session',
        actions: [
          IconButton(
            onPressed: () => _showExitDialog(),
            icon: Icon(Icons.close_rounded, color: colorScheme.error),
          ),
        ],
      ),
      body: Stack(
        children: [
          Consumer<QuizProvider>(
            builder: (context, quiz, _) {
              if (quiz.state == QuizState.loading || quiz.state == QuizState.initial) {
                return const LoadingWidget(message: 'Loading questions...');
              }
              
              if (quiz.state == QuizState.error) {
                return CustomErrorWidget(
                  message: quiz.errorMessage, 
                  onRetry: () {
                    if (widget.aiQuestions != null) {
                      context.read<QuizProvider>().setAIQuestions(widget.aiQuestions!, widget.topic ?? 'AI Quiz');
                    } else {
                      context.read<QuizProvider>().loadQuestions(widget.categoryId);
                    }
                  },
                );
              }
              
              if (quiz.questions.isEmpty || quiz.state == QuizState.empty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sentiment_dissatisfied, size: 64, color: colorScheme.onSurface.withValues(alpha: 0.3)),
                      const SizedBox(height: 16),
                      const Text('No questions found.'),
                      const SizedBox(height: 24),
                      CustomButton(text: 'Back', width: 150, onPressed: () => Navigator.pop(context)),
                    ],
                  ),
                );
              }

              final question = quiz.questions[quiz.currentQuestionIndex];
              final progress = (quiz.currentQuestionIndex + 1) / quiz.questions.length;

              return Column(
                children: [
                  _buildProgressHeader(progress, quiz.currentQuestionIndex + 1, quiz.questions.length, colorScheme),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          _buildQuestionCard(question.question, colorScheme),
                          const SizedBox(height: 40),
                          ...List.generate(question.options.length, (index) {
                            final isSelected = quiz.userAnswers[quiz.currentQuestionIndex] == index;
                            return _OptionCard(
                              text: question.options[index],
                              isSelected: isSelected,
                              onTap: () => quiz.selectAnswer(index),
                            );
                          }),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  _buildFooter(quiz, colorScheme),
                ],
              );
            },
          ),
          if (_isSaving)
            Container(
              color: Colors.black54,
              child: const Center(
                child: LoadingWidget(message: 'Saving result...'),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader(double progress, int current, int total, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question $current/$total',
                style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _secondsRemaining < 10 ? colorScheme.error : colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (_secondsRemaining < 10 ? colorScheme.error : colorScheme.primary).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined, 
                      size: 16, 
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_secondsRemaining}s',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(String text, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 22, 
          fontWeight: FontWeight.bold, 
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildFooter(QuizProvider quiz, ColorScheme colorScheme) {
    final hasAnswered = quiz.userAnswers.containsKey(quiz.currentQuestionIndex);
    final isLast = quiz.currentQuestionIndex == quiz.questions.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          if (quiz.currentQuestionIndex > 0)
            Expanded(
              child: CustomButton(
                text: 'Previous',
                isOutline: true,
                onPressed: () {
                  quiz.previousQuestion();
                  _startTimer();
                },
              ),
            ),
          if (quiz.currentQuestionIndex > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: CustomButton(
              text: isLast ? 'Finish Quiz' : 'Next Question',
              onPressed: hasAnswered ? _nextQuestion : () {},
              backgroundColor: hasAnswered ? null : colorScheme.onSurface.withValues(alpha: 0.1),
              foregroundColor: hasAnswered ? null : colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text('Your current progress will be lost. Are you sure you want to exit?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Stay')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Exit', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: colorScheme.primary.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))]
                : [],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? colorScheme.onPrimary : colorScheme.outline.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  color: isSelected ? colorScheme.onPrimary : Colors.transparent,
                ),
                child: isSelected 
                    ? Icon(Icons.check, size: 16, color: colorScheme.primary)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
