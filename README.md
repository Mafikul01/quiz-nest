# QuizNest - Ultimate Premium Quiz Platform (2026 Production Edition)

QuizNest is a high-performance, portfolio-quality Flutter application designed for high-engagement learning. Built with a futuristic **2026 Startup Aesthetic**, it combines real-time cloud synchronization with advanced UI components to deliver a world-class user experience.

---

## 🌟 Professional Features & Upgrades

### 🎨 Intelligent Design System
- **Dynamic Color Engine**: The app automatically identifies the category and applies a unique color theme (Math → Pink, Biology → Green, etc.) to the entire UI, including cards and header gradients.
- **Glassmorphic UI**: High-end translucent elements, blurred backgrounds, and subtle elevations inspired by modern design trends.
- **Hero Motion System**: Seamless "flying" transitions for category images from the grid directly into mission briefings.

### ⚡ Performance & Reliability
- **Zero-Flicker Startup**: Integrated an Authorization Guard on the Splash Screen to ensure authenticated users enter the app instantly without ever seeing the login page.
- **Instant Category Loading**: Implemented background fetching and memory-caching logic. The Home Screen feels 100% instant after the first load.
- **Atomic Data Safety**: All user progress (XP, High Scores) uses Firestore atomic increments to prevent data corruption during network instability.

### 🏆 Engagement & Gamification
- **Royal Leaderboard**: A real-time global ranking system featuring a unique **Lottie Crown Animation** for the world's #1 player.
- **Review Answers**: A detailed post-quiz breakdown allowing users to inspect their performance, identifying correct and incorrect answers with distinct visual cues.
- **HD Profile Avatars**: Automatically upgrades low-res Google profile thumbnails to High-Definition (400x400px) versions.
- **Edit Profile**: Seamless real-time name updates that synchronize across the entire platform instantly.

---

## 📂 Visual Assets Guide

### 🖼️ Category Images (`assets/images/`)
The app uses a smart mapping system to match category names to high-quality `.png` assets:
- `math.png` | `physics.png` | `biology.png` | `chemistry.png` | `general.png` | `information.png`

### 🎬 Lottie Animations (`assets/lottie/`)
- `Crown.json`: Animates atop the Rank 1 player.
- `trophy.json`: Celebratory Congrats animation.
- `confetti.json`: High-score success burst.
- `loading.json` & `error.json`: Branded system state animations.

---

## ⚙️ Technical Architecture

- **State Management**: Optimized Provider (ChangeNotifier) with granular rebuilds.
- **Backend**: Firebase Auth (Google) & Cloud Firestore (Real-time Streams).
- **Networking**: `http` package with robust error handling and timeout protection.
- **Security**: Strict Firestore rules and persistent authentication state.

---

## 🚀 Setup & Deployment

1.  **Firebase**: Enable Google Auth and Firestore.
2.  **Config**: Place `google-services.json` in `android/app/`.
3.  **Dependencies**:
    ```bash
    flutter pub get
    ```
4.  **Icons**:
    ```bash
    flutter pub run flutter_launcher_icons
    ```
5.  **Build**:
    ```bash
    flutter build apk --split-per-abi
    ```

**QuizNest is a fully optimized, assignment-compliant, and production-ready application.**
