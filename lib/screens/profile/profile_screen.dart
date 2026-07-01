import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_app_bar.dart';
import '../../models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.userData;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Player Profile',
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(context, auth),
            icon: Icon(Icons.logout_rounded, color: colorScheme.error),
          ),
        ],
      ),
      body: auth.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildProfileCard(context, user, colorScheme, auth),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Statistics',
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildStatsGrid(user, colorScheme),
                        const SizedBox(height: 32),
                        Text(
                          'App Settings',
                          style: TextStyle(
                            fontSize: 20, 
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildMenuTile(context, Icons.info_outline_rounded, 'About QuizNest', 'Version ${AppConstants.appVersion}'),
                        _buildMenuTile(context, Icons.security_rounded, 'Privacy & Security', 'Secured via Firebase'),
                        const SizedBox(height: 32),
                        CustomButton(
                          text: 'Logout',
                          isOutline: true,
                          foregroundColor: colorScheme.error,
                          onPressed: () => _showLogoutDialog(context, auth),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileCard(BuildContext context, UserModel? user, ColorScheme colorScheme, AuthProvider auth) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.primary.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // PRO-PIC (Upload removed as per user request)
          Hero(
            tag: 'profile_pic',
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                shape: BoxShape.circle, 
                gradient: AppTheme.primaryGradient
              ),
              child: CircleAvatar(
                radius: 54,
                backgroundColor: colorScheme.surface,
                backgroundImage: user?.photoUrl != null && user!.photoUrl.isNotEmpty
                    ? NetworkImage(user.photoUrl)
                    : const AssetImage(AppConstants.profilePlaceholder) as ImageProvider,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user?.displayName ?? 'Scholar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: colorSurface(colorScheme)
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showEditNameDialog(context, auth, user?.displayName ?? ''),
                child: Icon(Icons.edit_note_rounded, color: colorScheme.primary, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'anonymous@quiznest.com',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.5), 
              fontSize: 14
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'ENLISTED: ${user != null ? DateFormat('MMM yyyy').format(user.joinedAt).toUpperCase() : 'RECENTLY'}',
              style: TextStyle(
                color: colorScheme.primary, 
                fontWeight: FontWeight.bold, 
                fontSize: 11, 
                letterSpacing: 1
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color colorSurface(ColorScheme colorScheme) => colorScheme.onSurface;

  Widget _buildStatsGrid(UserModel? user, ColorScheme colorScheme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildStatItem('Total Points', '${user?.totalPoints ?? 0}', Icons.auto_awesome_rounded, Colors.amber, colorScheme),
        _buildStatItem('Quizzes Taken', '${user?.totalQuizzes ?? 0}', Icons.quiz_rounded, AppTheme.secondary, colorScheme),
        _buildStatItem('Highest Score', '${user?.highestScore ?? 0}', Icons.emoji_events_rounded, Colors.orange, colorScheme),
        _buildStatItem('Last Played', user?.lastPlayedAt != null ? DateFormat('dd MMM').format(user!.lastPlayedAt!) : 'N/A', Icons.history_rounded, Colors.teal, colorScheme),
      ],
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color accent, ColorScheme colorScheme) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.outline.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 20),
          const Spacer(),
          Text(
            value, 
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.bold, 
              color: colorScheme.onSurface
            )
          ),
          Text(
            title.toUpperCase(), 
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.4), 
              fontSize: 9, 
              fontWeight: FontWeight.bold, 
              letterSpacing: 0.5
            )
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title, String subtitle) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.05)),
      ),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.05), 
              shape: BoxShape.circle
            ),
            child: Icon(icon, color: colorScheme.primary, size: 20),
          ),
          title: Text(
            title, 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: colorScheme.onSurface, 
              fontSize: 15
            )
          ),
          subtitle: Text(
            subtitle, 
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.4), 
              fontSize: 12
            )
          ),
          trailing: Icon(
            Icons.chevron_right_rounded, 
            color: colorScheme.onSurface.withOpacity(0.2)
          ),
          onTap: () {},
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider auth) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of QuizNest?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: Text(
              'CANCEL', 
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))
            )
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).popUntil((route) => route.isFirst);
              auth.signOut();
            },
            child: Text(
              'LOG OUT', 
              style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold)
            ),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, AuthProvider auth, String currentName) {
    final controller = TextEditingController(text: currentName);
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Display Name'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter new name',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('CANCEL', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.5))),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final newName = controller.text.trim();
                Navigator.pop(context);
                try {
                  await auth.updateName(newName);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Name updated successfully!')),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to update name: $e'), backgroundColor: colorScheme.error),
                    );
                  }
                }
              }
            },
            child: const Text('SAVE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
