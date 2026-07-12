import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/ai_quiz_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../quiz/quiz_screen.dart';

class AIQuizSetupScreen extends StatefulWidget {
  const AIQuizSetupScreen({super.key});

  @override
  State<AIQuizSetupScreen> createState() => _AIQuizSetupScreenState();
}

class _AIQuizSetupScreenState extends State<AIQuizSetupScreen> {
  final TextEditingController _topicController = TextEditingController();
  final List<String> _suggestions = [
    'Flutter', 'Machine Learning', 'Python', 'Football', 
    'History', 'Bangladesh', 'Operating System', 'Data Structure'
  ];

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  void _generateQuiz() async {
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a topic first!')),
      );
      return;
    }

    final aiProvider = context.read<AIQuizProvider>();
    final questions = await aiProvider.generateAIQuiz(topic);

    if (!mounted) return;

    if (questions != null && questions.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(
            categoryId: -1, // Special ID for AI
            aiQuestions: questions,
            topic: topic,
          ),
        ),
      );
    } else if (aiProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(aiProvider.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final aiProvider = context.watch<AIQuizProvider>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: 'AI Quiz', 
        showBackButton: true,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // 1. Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
          ),
          
          // 2. Decorative Background Shapes (Behind Blur)
          Positioned(
            top: -50,
            right: -50,
            child: CircleAvatar(
              radius: 120,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Positioned(
            top: 200,
            left: -30,
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white.withValues(alpha: 0.05),
            ),
          ),

          // 3. Main Content
          SafeArea(
            child: Column(
              children: [
                // Hero Section (Glass Card)
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded, 
                                size: 40, 
                                color: AppTheme.primaryStart
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Smart Quiz Engine',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Our AI will generate 10 personalized questions for you.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Lower White Content Section
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    ),
                    child: aiProvider.isLoading 
                        ? _buildLoadingState() 
                        : _buildInputContent(aiProvider, colorScheme),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputContent(AIQuizProvider aiProvider, ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What do you want to learn today?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _topicController,
            decoration: InputDecoration(
              hintText: 'Enter any topic (e.g. Space, Python...)',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: AppTheme.primaryStart, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 32),
          if (aiProvider.history.isNotEmpty) ...[
            _buildSectionHeader('Recent Topics'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: aiProvider.history.map((topic) => _buildChip(topic)).toList(),
            ),
            const SizedBox(height: 32),
          ],
          _buildSectionHeader('Popular Suggestions'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _suggestions.map((topic) => _buildChip(topic)).toList(),
          ),
          const SizedBox(height: 48),
          CustomButton(
            text: 'Generate AI Quiz',
            onPressed: _generateQuiz,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        fontSize: 14,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildChip(String topic) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => setState(() => _topicController.text = topic),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Text(
          topic,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie Loading Animation
          SizedBox(
            width: 250,
            height: 250,
            child: Lottie.asset(
              'assets/lottie/loading.json',
              repeat: true,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'AI is brainstorming...',
            style: TextStyle(
              fontSize: 24, 
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Designing exactly 10 high-quality questions for your session.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), 
              fontSize: 15, 
              height: 1.5
            ),
          ),
        ],
      ),
    );
  }
}
