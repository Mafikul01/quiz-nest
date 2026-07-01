import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  
  User? _firebaseUser;
  UserModel? _userData;
  bool _isLoading = false;
  bool _isInitialAuthChecked = false;
  StreamSubscription<UserModel?>? _userDataSubscription;

  User? get user => _firebaseUser;
  UserModel? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get isInitialAuthChecked => _isInitialAuthChecked;
  bool get isAuthenticated => _firebaseUser != null;

  AuthProvider() {
    _authService.userStream.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    _userDataSubscription?.cancel();

    if (user != null) {
      if (kDebugMode) debugPrint('AuthProvider: User logged in: ${user.uid}');
      
      _userDataSubscription = _dbService.getUserStream(user.uid).listen((data) {
        _userData = data;
        _isInitialAuthChecked = true;
        notifyListeners();
      });

      // Get high quality photo URL from Google
      String photoUrl = user.photoURL ?? '';
      if (photoUrl.contains('googleusercontent.com')) {
        photoUrl = photoUrl.replaceAll('=s96-c', '=s400-c');
      }

      final basicUser = UserModel(
        uid: user.uid,
        name: user.displayName ?? 'Scholar',
        displayName: user.displayName ?? 'Scholar',
        email: user.email ?? '',
        photoUrl: photoUrl,
        totalPoints: 0,
        totalQuizzes: 0,
        highestScore: 0,
        joinedAt: DateTime.now(),
      );
      
      _dbService.ensureUserExists(basicUser);
    } else {
      _userData = null;
      _isInitialAuthChecked = true;
      notifyListeners();
    }
  }

  Future<void> updateName(String newName) async {
    if (_firebaseUser == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      await _dbService.updateDisplayName(_firebaseUser!.uid, newName);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signInWithGoogle();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      _userDataSubscription?.cancel();
      await _authService.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshUserData() async {
    if (_firebaseUser != null) {
      final doc = await _dbService.getUserStream(_firebaseUser!.uid).first;
      if (doc != null) {
        _userData = doc;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _userDataSubscription?.cancel();
    super.dispose();
  }
}
