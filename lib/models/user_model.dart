import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String displayName;
  final String email;
  final String photoUrl;
  final int totalPoints;
  final int totalQuizzes;
  final int highestScore;
  final DateTime joinedAt;
  final DateTime? lastPlayedAt;

  UserModel({
    required this.uid,
    required this.name,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.totalPoints,
    required this.totalQuizzes,
    required this.highestScore,
    required this.joinedAt,
    this.lastPlayedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    // Robust integer parsing for Firestore flexibility
    int parseInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return UserModel(
      uid: data['uid']?.toString() ?? '',
      name: data['name']?.toString() ?? 'Scholar',
      displayName: data['displayName']?.toString() ?? data['name']?.toString() ?? 'Scholar',
      email: data['email']?.toString() ?? '',
      photoUrl: data['photoUrl']?.toString() ?? '',
      totalPoints: parseInt(data['totalPoints']),
      totalQuizzes: parseInt(data['totalQuizzes']),
      highestScore: parseInt(data['highestScore']),
      joinedAt: (data['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastPlayedAt: (data['lastPlayedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'totalPoints': totalPoints,
      'totalQuizzes': totalQuizzes,
      'highestScore': highestScore,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'lastPlayedAt': lastPlayedAt != null ? Timestamp.fromDate(lastPlayedAt!) : null,
    };
  }
}
