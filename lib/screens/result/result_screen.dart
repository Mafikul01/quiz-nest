import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/custom_button.dart';
import 'review_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    
    final totalQuestions = quiz.questions.length;
    final percentage = totalQuestions > 0 ? (quiz.score / totalQuestions) * 100 : 0.0;
    final isPassed = percentage >= 60;

    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Celebration Header
                  Center(
                    child: SizedBox(
                      height: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _SafeLottie(
                            asset: AppConstants.trophyLottie,
                            repeat: false,
                            fallback: const Icon(Icons.emoji_events_rounded, size: 120, color: Colors.amber),
                          ),
                          if (isPassed)
                            _SafeLottie(
                              asset: AppConstants.confettiLottie,
                              repeat: true,
                              fallback: const SizedBox(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isPassed ? 'Congratulations! 🎉' : 'Quiz Completed! 💪',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPassed ? 'You did a great job!' : 'Keep practicing to improve!',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  
                  const Spacer(),
                  
                  // Score Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            _buildResultRow('Correct Answers', '${quiz.score}/$totalQuestions'),
                            const SizedBox(height: 24),
                            _buildResultRow('Accuracy', '${percentage.toInt()}%'),
                            const SizedBox(height: 24),
                            _buildResultRow('XP Gained', '+${quiz.earnedPoints} XP', highlight: true),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Actions
                  CustomButton(
                    text: 'Review Answers',
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ReviewScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          text: 'Retry',
                          backgroundColor: Colors.white,
                          foregroundColor: colorScheme.primary,
                          onPressed: () {
                            quiz.resetQuiz();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          text: 'Home',
                          isOutline: true,
                          foregroundColor: Colors.white,
                          onPressed: () {
                            quiz.resetQuiz();
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {bool highlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.w500)),
        Text(
          value, 
          style: TextStyle(
            color: highlight ? AppTheme.secondary : Colors.white, 
            fontSize: 24, 
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SafeLottie extends StatelessWidget {
  final String asset;
  final Widget fallback;
  final bool repeat;

  const _SafeLottie({
    required this.asset,
    required this.fallback,
    this.repeat = true,
  });

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      asset,
      repeat: repeat,
      errorBuilder: (context, error, stackTrace) {
        return fallback;
      },
    );
  }
}
