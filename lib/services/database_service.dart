import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/quiz_history_model.dart';
import '../core/constants/app_constants.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream for real-time user data
  Stream<UserModel?> getUserStream(String uid) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      try {
        if (snapshot.exists && snapshot.data() != null) {
          return UserModel.fromMap(snapshot.data()!);
        }
      } catch (e) {
        if (kDebugMode) debugPrint('DatabaseService: Error parsing user stream: $e');
      }
      return null;
    });
  }

  // Quiz History
  Future<void> saveQuizHistory(String uid, QuizHistoryModel history) async {
    try {
      await _db
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .collection('quiz_history')
          .add(history.toMap());
    } catch (e) {
      if (kDebugMode) debugPrint('DatabaseService: saveQuizHistory failed: $e');
    }
  }

  Stream<List<QuizHistoryModel>> getQuizHistoryStream(String uid) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .collection('quiz_history')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => QuizHistoryModel.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  // Create new user if not exists - Optimized with SetOptions
  Future<void> ensureUserExists(UserModel user) async {
    try {
      final docRef = _db.collection(AppConstants.usersCollection).doc(user.uid);
      
      // Use set with merge: true to avoid overwriting existing progress if the doc already exists
      // but still ensure basic fields are there for new users.
      await docRef.set({
        'uid': user.uid,
        'name': user.name,
        'email': user.email,
        'photoUrl': user.photoUrl,
        'phoneNumber': user.phoneNumber,
        'joinedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Initialize counters ONLY if they don't exist
      final doc = await docRef.get();
      final data = doc.data();
      if (data != null && data['totalPoints'] == null) {
        await docRef.update({
          'totalPoints': 0,
          'totalQuizzes': 0,
          'highestScore': 0,
          'displayName': user.name, // Initial display name
        });
      }
    } catch (e) {
      if (kDebugMode) debugPrint('DatabaseService: ensureUserExists failed: $e');
    }
  }

  // Update display name
  Future<void> updateDisplayName(String uid, String newName) async {
    try {
      await _db.collection(AppConstants.usersCollection).doc(uid).update({
        'displayName': newName,
        'name': newName, // Keep both in sync for compatibility
      });
    } catch (e) {
      if (kDebugMode) debugPrint('DatabaseService: updateDisplayName failed: $e');
      rethrow;
    }
  }

  // Update phone number
  Future<void> updatePhoneNumber(String uid, String phoneNumber) async {
    try {
      await _db.collection(AppConstants.usersCollection).doc(uid).update({
        'phoneNumber': phoneNumber,
      });
    } catch (e) {
      if (kDebugMode) debugPrint('DatabaseService: updatePhoneNumber failed: $e');
      rethrow;
    }
  }

  // Atomic update for progress - Simplified for better reliability
  Future<void> updateQuizProgress({
    required String uid,
    required int earnedPoints,
    required int currentScore,
  }) async {
    try {
      final docRef = _db.collection(AppConstants.usersCollection).doc(uid);
      
      // 1. Get current high score
      final doc = await docRef.get();
      if (!doc.exists) return;
      
      final data = doc.data()!;
      final int oldHighestScore = (data['highestScore'] ?? 0) as int;

      // 2. Perform atomic updates
      final Map<String, dynamic> updates = {
        'totalPoints': FieldValue.increment(earnedPoints),
        'totalQuizzes': FieldValue.increment(1),
        'lastPlayedAt': FieldValue.serverTimestamp(),
      };

      if (currentScore > oldHighestScore) {
        updates['highestScore'] = currentScore;
      }

      await docRef.update(updates);
      if (kDebugMode) debugPrint('DatabaseService: Successfully updated progress for $uid');
    } catch (e) {
      if (kDebugMode) debugPrint('DatabaseService: updateQuizProgress failed: $e');
      rethrow;
    }
  }

  // Leaderboard Stream - Simplified to avoid complex index requirements for now
  Stream<List<UserModel>> getLeaderboardStream() {
    return _db
        .collection(AppConstants.usersCollection)
        .orderBy('totalPoints', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    });
  }
}
