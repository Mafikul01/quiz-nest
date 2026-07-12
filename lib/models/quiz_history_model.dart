import 'package:cloud_firestore/cloud_firestore.dart';

class QuizHistoryModel {
  final String id;
  final String quizType; // 'AI' or 'API'
  final String title;
  final String category;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int wrongAnswers;
  final double percentage;
  final DateTime date;
  final String duration;

  QuizHistoryModel({
    required this.id,
    required this.quizType,
    required this.title,
    required this.category,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.percentage,
    required this.date,
    required this.duration,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quizType': quizType,
      'title': title,
      'category': category,
      'score': score,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'wrongAnswers': wrongAnswers,
      'percentage': percentage,
      'date': Timestamp.fromDate(date),
      'duration': duration,
    };
  }

  factory QuizHistoryModel.fromMap(Map<String, dynamic> map) {
    return QuizHistoryModel(
      id: map['id'] ?? '',
      quizType: map['quizType'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      score: map['score'] ?? 0,
      totalQuestions: map['totalQuestions'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      wrongAnswers: map['wrongAnswers'] ?? 0,
      percentage: (map['percentage'] ?? 0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      duration: map['duration'] ?? '',
    );
  }
}
