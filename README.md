# QuizNest - Ultimate Premium Quiz Platform (2026 Production Edition)

QuizNest is a high-performance, portfolio-quality Flutter application designed for high-engagement learning. Built with a futuristic **2026 Startup Aesthetic**, it combines real-time cloud synchronization with advanced UI components to deliver a world-class user experience.

---

## 🌟 Professional Features & Upgrades

### 🎨 Intelligent Design System
- **Premium Bottom Navigation**: Modern floating glassmorphic bar with smooth transitions and haptic feedback.
- **Dynamic Color Engine**: The app automatically identifies the category and applies a unique color theme (Math → Pink, Biology → Green, etc.).
- **Glassmorphic UI**: High-end translucent elements, blurred backgrounds, and subtle elevations.
- **Hero Motion System**: Seamless "flying" transitions for category images.

### ⚡ Performance & Reliability
- **Zero-Flicker Startup**: Integrated Authorization Guard ensures authenticated users enter the app instantly.
- **Instant Category Loading**: Background fetching and memory-caching for a zero-wait experience.
- **Atomic Data Safety**: Firestore atomic increments prevent data corruption.

### 🏆 Engagement & Gamification
- **Royal Leaderboard**: Real-time global ranking with a **Lottie Crown Animation** for the top player.
- **Review Answers**: Post-quiz breakdown to inspect performance and correct answers.
- **HD Profile Avatars**: Automatic upgrade of Google profile thumbnails to High-Definition.
- **Edit Profile**: Real-time display name updates synchronized globally.

---

## 📂 Visual Assets Guide

### 🖼️ Category Images (`assets/images/`)
- `math.png` | `physics.png` | `biology.png` | `chemistry.png` | `general.png` | `information.png`
- `Logo-google.png`: High-quality Google sign-in asset.

### 🎬 Lottie Animations (`assets/lottie/`)
- `Crown.json`: Animates atop the Rank 1 player.
- `trophy.json` | `confetti.json` | `loading.json` | `error.json`

---

## ⚙️ Technical Architecture
- **Navigation**: Persistent state management using `IndexedStack`.
- **State Management**: Provider (ChangeNotifier).
- **Backend**: Firebase Auth & Cloud Firestore.
- **Networking**: `http` package.

---

## 🚀 Setup & Deployment
1.  **Dependencies**: `flutter pub get`
2.  **Icons**: `flutter pub run flutter_launcher_icons`
3.  **Build**: `flutter build apk --split-per-abi`

**QuizNest is a fully optimized, assignment-compliant, and production-ready application.**
