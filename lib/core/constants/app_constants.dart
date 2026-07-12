import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'QuizNest';
  static const String appVersion = '2.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://sadiks-quiz-apihub.lovable.app/api/v1';
  static const String categoriesEndpoint = '/categories';
  static const String questionsEndpoint = '/categories/{categoryId}/questions';

  // Firestore Collection Names
  static const String usersCollection = 'users';

  // UI Constants
  static const double defaultPadding = 20.0;
  static const double defaultRadius = 24.0;
  static const int quizTimerSeconds = 30;

  // Assets - Images
  static const String appLogo = 'assets/images/applogo.png';
  static const String splashLogo = 'assets/images/applogo.png';
  static const String googleLogo = 'assets/images/Logo-google.png';
  static const String profilePlaceholder = 'assets/images/profile_placeholder.png';
  static const String emptyState = 'assets/images/empty_state.png';

  // Category Assets
  static const String mathImage = 'assets/images/math.png';
  static const String generalImage = 'assets/images/general.png';
  static const String physicsImage = 'assets/images/physics.png';
  static const String biologyImage = 'assets/images/biology.png';
  static const String chemistryImage = 'assets/images/chemistry.png';
  static const String informationImage = 'assets/images/information.png';

  static String getCategoryImage(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('math')) return mathImage;
    if (name.contains('general')) return generalImage;
    if (name.contains('physics')) return physicsImage;
    if (name.contains('biology')) return biologyImage;
    if (name.contains('chemistry')) return chemistryImage;
    if (name.contains('information') || name.contains('tech')) return informationImage;
    return ''; 
  }

  // Dynamic Color Engine: Returns a theme color based on the category
  static Color getCategoryColor(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('math')) return const Color(0xFFFF4081); // Vibrant Pink
    if (name.contains('general')) return const Color(0xFF3F51B5); // Indigo
    if (name.contains('physics')) return const Color(0xFFFF9800); // Orange
    if (name.contains('biology')) return const Color(0xFF4CAF50); // Green
    if (name.contains('chemistry')) return const Color(0xFF9C27B0); // Purple
    if (name.contains('information') || name.contains('tech')) return const Color(0xFF00BCD4); // Cyan
    return const Color(0xFF6366F1); // Default Blue-Violet
  }
  
  // Assets - Lottie
  static const String trophyLottie = 'assets/lottie/trophy.json';
  static const String loadingLottie = 'assets/lottie/Nrloading.json';
  static const String errorLottie = 'assets/lottie/error.json';
  static const String confettiLottie = 'assets/lottie/confetti.json';
  static const String loginLottie = 'assets/lottie/login.json';
  static const String crownLottie = 'assets/lottie/Crown.json';
}
