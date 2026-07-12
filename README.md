# QuizNest - Ultimate AI-Powered Quiz Ecosystem (2026 Edition)

QuizNest is a high-performance, production-grade Flutter application that redefines the learning experience through artificial intelligence. Built with a futuristic **2026 Startup Aesthetic**, it integrates cutting-edge AI generation with real-time cloud synchronization to provide a personalized educational journey.

---

## 🚀 Major AI Updates & Features

### 🧠 Eagle AI - Personal Assistant
- **Concise Intelligence**: A dedicated chat assistant developed by **Mafikul Islam** to help users with study topics and general knowledge.
- **Natural Interaction**: Features modern typing indicators and word-by-word streaming effects for a premium "human" feel.
- **Context Aware**: Remembers the conversation flow and provides specific explanations for quiz-related queries.

### ✨ AI Smart Quiz Generator (Powered by OpenRouter)
- **Topic-on-Demand**: Generate exactly 10 high-quality multiple-choice questions about *any* subject instantly.
- **Fair-Play Engine**: Questions are validated and options are shuffled programmatically in Flutter to ensure zero predictability.
- **High Resiliency**: Implements a multi-model fallback system (Gemini 2.0 → 1.5 → Mistral) to guarantee generation success even if one API endpoint is down.
- **Seamless Flow**: AI quizzes integrate directly with the existing timer, scoring, and leaderboard systems.

### 📜 Comprehensive Quiz History
- **Progress Tracking**: Persistent Firestore storage for every quiz attempt (both AI-generated and standard categories).
- **Deep Analytics**: Detailed breakdown of score, percentage, correct/wrong answers, and precise duration for each session.
- **Smart Filtering**: Advanced history screen with search, type-filtering (AI vs. API), and chronological sorting.

---

## 🎨 Design & UI/UX Excellence
- **Dual-Section Home**: Organized layout separating **✨ AI FEATURES** from **📚 Quiz Categories**.
- **Fixed Glassmorphism**: Flawless frosted-glass rendering with multi-layer depth on all AI-powered screens.
- **Premium Animations**: High-fidelity Lottie animations for loading (`Nrloading.json`), success (`trophy.json`), and rank achievements (`Crown.json`).
- **Modern Navigation**: Floating glassmorphic bottom bar with Haptic feedback and `PopScope` integration.

---

## 📂 Technical Architecture
- **AI Core**: OpenRouter API (OpenAI compatible) for LLM orchestration.
- **State Management**: Optimized Provider (ChangeNotifier) with minimal rebuild patterns.
- **Cloud Backend**: Firebase Authentication & Cloud Firestore (sub-collection hierarchy).
- **Environment Safety**: Secure `.env` configuration via `flutter_dotenv` to prevent API key leaks.

---

## ⚙️ Setup & Deployment

### 1. Environment Configuration
Create a `.env` file in the root directory based on `.env.example`:
```env
OPENAI_API_KEY=your_openrouter_api_key_here
```

### 2. Firestore Security Rules
Ensure your Firestore rules allow access to the `quiz_history` sub-collection:
```javascript
match /users/{userId}/quiz_history/{historyId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

### 3. Build Instructions
1.  **Get Packages**: `flutter pub get`
2.  **Generate Icons**: `flutter pub run flutter_launcher_icons`
3.  **Run (Full Restart)**: `flutter run`

---

## 👨‍💻 Developer Credits
Developed with ❤️ by **Mafikul Islam**
- **GitHub**: [@Mafikul01](https://github.com/Mafikul01)
- **Socials**: Facebook, LinkedIn, Instagram: @Mafikul01
- **Contact**: +8801788302771 (WhatsApp)

**QuizNest is more than an app—it's a vision of the future of digital learning.**
