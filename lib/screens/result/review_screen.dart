import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/custom_app_bar.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Review Answers',
        showBackButton: true,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: quiz.questions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 20),
        itemBuilder: (context, index) {
          final question = quiz.questions[index];
          final userAnswerIndex = quiz.userAnswers[index];
          final isCorrect = userAnswerIndex == question.answerIndex;

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isCorrect 
                    ? Colors.green.withValues(alpha: 0.3) 
                    : Colors.red.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isCorrect ? Colors.green : Colors.red,
                      child: Icon(
                        isCorrect ? Icons.check : Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Question ${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  question.question,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ...List.generate(question.options.length, (optIndex) {
                  final isUserSelected = userAnswerIndex == optIndex;
                  final isCorrectOption = question.answerIndex == optIndex;

                  Color? tileColor;
                  Color? textColor;
                  IconData? icon;

                  if (isCorrectOption) {
                    tileColor = Colors.green.withValues(alpha: 0.1);
                    textColor = Colors.green[700];
                    icon = Icons.check_circle_rounded;
                  } else if (isUserSelected && !isCorrect) {
                    tileColor = Colors.red.withValues(alpha: 0.1);
                    textColor = Colors.red[700];
                    icon = Icons.cancel_rounded;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: tileColor ?? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: tileColor?.withValues(alpha: 0.5) ?? Colors.transparent,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            question.options[optIndex],
                            style: TextStyle(
                              color: textColor ?? colorScheme.onSurface,
                              fontWeight: (isUserSelected || isCorrectOption)
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (icon != null)
                          Icon(icon, size: 20, color: textColor),
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
