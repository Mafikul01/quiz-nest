# QuizNest - Production Edition 2026

QuizNest is a premium, portfolio-quality Flutter application designed for high performance and real-time user engagement. It features Google Authentication, Firestore-backed progression tracking, and a global leaderboard.

## 🌟 Major Upgrades (V2.0)
- **Real-time Sync**: User statistics (XP, Quizzes, High Score) now update instantly via Firestore Streams.
- **Accessibility Fix**: All contrast issues resolved using a centralized Material 3 ColorScheme.
- **Visual Overhaul**: Modern startup-style UI with glassmorphism and smooth animations.
- **Leaderboard**: Real-time global rankings with podium highlights for top players.

## 📂 Required Assets
To make the application fully functional, please provide the following files in the specified folders:

### 🖼 Images (`assets/images/`)
| Filename | Purpose | Recommended Size |
| :--- | :--- | :--- |
| `app_logo.png` | Main logo (Login screen) | 512x512 px |
| `splash_logo.png` | Splash screen logo | 512x512 px |
| `profile_placeholder.png` | Default user avatar | 256x256 px |
| `empty_state.png` | Empty list illustration | 1024x1024 px |

### 🎬 Lottie Animations (`assets/lottie/`)
| Filename | Purpose | Recommended Source |
| :--- | :--- | :--- |
| `login.json` | Login background animation | LottieFiles |
| `loading.json` | Data fetching loader | LottieFiles |
| `error.json` | System error animation | LottieFiles |
| `trophy.json` | Result celebration | LottieFiles |
| `confetti.json` | Success burst | LottieFiles |

## ⚙️ Setup Instructions

### 1. Firebase Configuration
1. **Firestore**: Enable Firestore in your console (Production Mode).
2. **Rules**: Set rules to allow authenticated users to read/write their own `users` document.
3. **Files**: 
   - Android: Place `google-services.json` in `android/app/`.
   - iOS: Place `GoogleService-Info.plist` in `ios/Runner/`.

### 2. Deployment
```bash
flutter pub get
flutter run
```

## 🛠 Tech Stack
- **Flutter**: Latest stable.
- **Provider**: State management.
- **Firebase**: Auth & Firestore (Real-time).
- **Design**: Material 3 + Custom Glassmorphism.
