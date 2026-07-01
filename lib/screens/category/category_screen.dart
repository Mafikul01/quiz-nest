import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_app_bar.dart';
import '../quiz/quiz_screen.dart';
import '../../core/constants/app_constants.dart';

class CategoryScreen extends StatelessWidget {
  final CategoryModel category;

  const CategoryScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryImage = AppConstants.getCategoryImage(category.name);
    final categoryColor = AppConstants.getCategoryColor(category.name);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(title: '', showBackButton: true, backgroundColor: Colors.transparent),
      body: Column(
        children: [
          // Upgraded Hero Banner
          Container(
            height: MediaQuery.of(context).size.height * 0.48, 
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  categoryColor,
                  categoryColor.withOpacity(0.7),
                ],
              ),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(56)),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Decorative Patterns for "Cool" look
                Positioned(
                  left: -30,
                  top: -30,
                  child: CircleAvatar(
                    radius: 100,
                    backgroundColor: Colors.white.withOpacity(0.1),
                  ),
                ),
                Positioned(
                  right: -50,
                  bottom: 50,
                  child: CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.black.withOpacity(0.05),
                  ),
                ),
                
                // Centered Image with Hero
                Hero(
                  tag: 'category_image_${category.id}',
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(48),
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(48),
                      child: categoryImage.isNotEmpty
                          ? Image.asset(
                              categoryImage,
                              fit: BoxFit.cover, 
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.auto_awesome_rounded,
                                size: 80,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            )
                          : Icon(
                              Icons.auto_awesome_rounded,
                              size: 80,
                              color: Colors.white.withOpacity(0.9),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(32, 40, 32, 32),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08), 
                      blurRadius: 40, 
                      offset: const Offset(0, -10)
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category.name,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Subject Mastery Arena',
                                style: TextStyle(
                                  color: categoryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Premium XP',
                            style: TextStyle(color: categoryColor, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      category.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: colorScheme.onSurface.withOpacity(0.7),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Quiz Protocol',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                    ),
                    const SizedBox(height: 16),
                    _buildRuleItem(context, Icons.bolt_rounded, '30 Seconds per question', categoryColor),
                    const SizedBox(height: 12),
                    _buildRuleItem(context, Icons.auto_graph_rounded, 'Accuracy-based XP scaling', categoryColor),
                    const Spacer(),
                    CustomButton(
                      text: 'Initiate Challenge',
                      backgroundColor: categoryColor,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(categoryId: category.id),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(BuildContext context, IconData icon, String text, Color themeColor) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: themeColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.8),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
