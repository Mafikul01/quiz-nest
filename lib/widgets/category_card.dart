import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../core/constants/app_constants.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryImage = AppConstants.getCategoryImage(category.name);
    final categoryColor = AppConstants.getCategoryColor(category.name);

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.08), // Using image-based dynamic color
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: categoryColor.withOpacity(0.12)),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -15,
                  top: -15,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0), 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Upgraded Image Container
                      Hero(
                        tag: 'category_image_${category.id}',
                        child: Container(
                          width: 56, 
                          height: 56, 
                          decoration: BoxDecoration(
                            color: categoryColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: categoryColor.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: categoryImage.isNotEmpty
                                ? Image.asset(
                                    categoryImage,
                                    fit: BoxFit.cover, 
                                    errorBuilder: (context, error, stackTrace) => Icon(
                                      Icons.auto_awesome_rounded,
                                      color: categoryColor,
                                      size: 28,
                                    ),
                                  )
                                : Icon(
                                    Icons.auto_awesome_rounded,
                                    color: categoryColor,
                                    size: 28,
                                  ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Name
                      Text(
                        category.name,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Progress/Meta
                      Row(
                        children: [
                          Icon(Icons.timer_outlined, size: 14, color: colorScheme.onSurface.withOpacity(0.4)),
                          const SizedBox(width: 4),
                          Text(
                            '10 Qs',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.4),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_forward_rounded, size: 16, color: categoryColor),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
