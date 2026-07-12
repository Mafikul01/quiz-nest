import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../widgets/category_card.dart';
import '../../widgets/ai_quiz_card.dart';
import '../../widgets/ai_chat_card.dart';
import '../../widgets/loading_widget.dart';
import '../../models/user_model.dart';
import '../../widgets/error_widget.dart';
import '../category/category_screen.dart';
import '../ai_quiz/ai_quiz_setup_screen.dart';
import '../ai_chat/ai_chat_screen.dart';
import '../profile/profile_screen.dart';
import '../leaderboard/leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<QuizProvider>().loadCategories();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userData;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, user),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8), // Removed the top gap entirely
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Performance',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatsRow(user, colorScheme),
                  const SizedBox(height: 32),
                  _buildLeaderboardBanner(context),
                  const SizedBox(height: 40),
                  _buildSectionHeader(context, '✨ AI FEATURES', 'Premium experience'),
                  const SizedBox(height: 16),
                  _buildAISection(context),
                  const SizedBox(height: 40),
                  _buildSectionHeader(context, '📚 Quiz Categories', 'Explore subjects'),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          _buildCategoriesGrid(),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, UserModel? user) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverAppBar(
      expandedHeight: 90, // Reduced from 110
      floating: false,
      pinned: true,
      elevation: 0,
      centerTitle: false,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 70, // Fixed height to prevent collapse gaps
      title: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            child: Hero(
              tag: 'profile_pic',
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary, width: 2),
                ),
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  backgroundImage: user?.photoUrl != null && user!.photoUrl.isNotEmpty
                      ? NetworkImage(user.photoUrl)
                      : null,
                  child: user?.photoUrl == null || user!.photoUrl.isEmpty
                      ? Icon(Icons.person, color: colorScheme.primary)
                      : null,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Good Morning 👋',
                style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13),
              ),
              const SizedBox(height: 6), // Added space between Greeting and Name
              Text(
                user?.displayName ?? 'Scholar', // Using displayName
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_none_rounded, color: colorScheme.onSurface),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(UserModel? user, ColorScheme colorScheme) {
    return Row(
      children: [
        _buildStatCard('Total Points', '${user?.totalPoints ?? 0}', Icons.auto_awesome_rounded, Colors.amber, colorScheme),
        const SizedBox(width: 12),
        _buildStatCard('Quizzes Taken', '${user?.totalQuizzes ?? 0}', Icons.quiz_rounded, AppTheme.secondary, colorScheme),
        const SizedBox(width: 12),
        _buildStatCard('Highest Score', '${user?.highestScore ?? 0}', Icons.emoji_events_rounded, Colors.orange, colorScheme),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color accentColor, ColorScheme colorScheme) {
    return Expanded(
      child: Container(
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: accentColor, size: 22),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryStart.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.leaderboard_rounded, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Leaderboard',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'See how you rank globally!',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded, color: AppTheme.primaryStart, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, String subtitle) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            color: colorScheme.onSurface.withValues(alpha: 0.4),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAISection(BuildContext context) {
    return SizedBox(
      height: 170,
      child: Row(
        children: [
          Expanded(
            child: AIQuizCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AIQuizSetupScreen()),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AIChatCard(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AIChatScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    return Consumer<QuizProvider>(
      builder: (context, quiz, _) {
        if (quiz.state == QuizState.loading && quiz.categories.isEmpty) {
          return const SliverFillRemaining(child: LoadingWidget());
        }
        if (quiz.state == QuizState.error && quiz.categories.isEmpty) {
          return SliverFillRemaining(
            child: CustomErrorWidget(
              message: quiz.errorMessage,
              onRetry: () => quiz.loadCategories(),
            ),
          );
        }
        
        final categories = quiz.categories;
        if (categories.isEmpty && quiz.state != QuizState.loading) {
          return const SliverFillRemaining(child: Center(child: Text('No categories available')));
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.95,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final category = categories[index];
                return CategoryCard(
                  category: category,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryScreen(category: category),
                    ),
                  ),
                );
              },
              childCount: categories.length,
            ),
          ),
        );
      },
    );
  }
}
