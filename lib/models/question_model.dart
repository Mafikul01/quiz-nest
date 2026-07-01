class QuestionModel {
  final int id;
  final int categoryId;
  final String question;
  final List<String> options;
  final int answerIndex;
  final int mark;
  final String createdAt;
  final String updatedAt;

  QuestionModel({
    required this.id,
    required this.categoryId,
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.mark,
    required this.createdAt,
    required this.updatedAt,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    // Highly robust parsing to handle both String and Int types from API
    int parseId(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return QuestionModel(
      id: parseId(json['id']),
      categoryId: parseId(json['categoryId']),
      question: json['question']?.toString() ?? 'No Question Text',
      options: json['options'] is List 
          ? List<String>.from((json['options'] as List).map((e) => e.toString()))
          : [],
      answerIndex: parseId(json['answerIndex']),
      mark: parseId(json['mark']),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'question': question,
      'options': options,
      'answerIndex': answerIndex,
      'mark': mark,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
