import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../models/user_model.dart';
import '../../services/database_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/loading_widget.dart';
import '../../core/constants/app_constants.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dbService = DatabaseService();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary, 
      appBar: const CustomAppBar(
        title: 'Leaderboard',
        showBackButton: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: dbService.getLeaderboardStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingWidget(message: 'Loading rankings...'));
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Error sync: ${snapshot.error}', 
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          
          final users = snapshot.data ?? [];
          if (users.isEmpty) {
            return const Center(
              child: Text(
                'No entries yet. Be the first hero!', 
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            );
          }

          final topThree = users.take(3).toList();
          final theRest = users.skip(3).toList();

          return Column(
            children: [
              const SizedBox(height: 10),
              _buildPodium(topThree, colorScheme),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15), 
                        blurRadius: 30, 
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: theRest.isEmpty && topThree.isNotEmpty
                      ? Center(
                          child: Text(
                            'Keep playing to climb the ranks!',
                            style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 120), // Increased bottom padding to 120
                          physics: const BouncingScrollPhysics(),
                          itemCount: theRest.length,
                          separatorBuilder: (_, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final user = theRest[index];
                            return _buildRankingTile(context, user, index + 4, colorScheme);
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPodium(List<UserModel> topThree, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place
          if (topThree.length >= 2) 
            Expanded(child: _buildPodiumItem(topThree[1], 2, const Color(0xFFCBD5E1), colorScheme)),
          
          // 1st Place
          if (topThree.isNotEmpty)
            Expanded(child: _buildPodiumItem(topThree[0], 1, const Color(0xFFFFD700), colorScheme)),
          
          // 3rd Place
          if (topThree.length >= 3)
            Expanded(child: _buildPodiumItem(topThree[2], 3, const Color(0xFFCD7F32), colorScheme)),
          
          // Placeholders for empty podium spots if less than 3 users
          if (topThree.length < 2) const Spacer(),
          if (topThree.length < 3) const Spacer(),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(UserModel user, int rank, Color crownColor, ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Avatar Container
            Container(
              width: rank == 1 ? 100 : 85,
              height: rank == 1 ? 100 : 85,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: crownColor, width: 3),
                boxShadow: [
                  BoxShadow(color: crownColor.withValues(alpha: 0.3), blurRadius: 15),
                ],
              ),
              child: CircleAvatar(
                backgroundColor: colorScheme.surfaceContainerHighest,
                backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
                child: user.photoUrl.isEmpty ? const Icon(Icons.person, color: Colors.white) : null,
              ),
            ),
            
            // Rank Badge
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: crownColor, shape: BoxShape.circle),
                child: Text(
                  '$rank',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black87),
                ),
              ),
            ),

            // Lottie Crown for Rank 1
            if (rank == 1)
              Positioned(
                top: -45, // Positioned above the avatar
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Lottie.asset(
                    AppConstants.crownLottie,
                    repeat: true,
                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          user.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold, 
            fontSize: 14,
          ),
        ),
        Text(
          '${user.totalPoints} XP',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8), 
            fontWeight: FontWeight.bold, 
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildRankingTile(BuildContext context, UserModel user, int rank, ColorScheme colorScheme) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#$rank',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.4), 
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: colorScheme.surfaceContainerHighest,
            backgroundImage: user.photoUrl.isNotEmpty ? NetworkImage(user.photoUrl) : null,
            child: user.photoUrl.isEmpty ? Icon(Icons.person, color: colorScheme.primary, size: 20) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: colorScheme.onSurface, 
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${user.totalQuizzes} quizzes played', 
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user.totalPoints}',
                style: TextStyle(
                  color: colorScheme.primary, 
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                ),
              ),
              const Text(
                'XP', 
                style: TextStyle(
                  fontSize: 10, 
                  fontWeight: FontWeight.bold, 
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
