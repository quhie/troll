import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/sound_category.dart';
import '../utils/app_theme.dart';

/// A card widget representing a sound category
class CategoryCard extends StatelessWidget {
  final CategoryType category;
  final VoidCallback onTap;
  final bool isSelected;

  const CategoryCard({
    Key? key,
    required this.category,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            width: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors:
                    isSelected
                        ? [category.color, category.color.withOpacity(0.7)]
                        : [Colors.white, Colors.grey.shade50],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      isSelected
                          ? category.color.withOpacity(0.4)
                          : Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
              border: Border.all(
                color:
                    isSelected
                        ? category.color.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Background pattern
                if (isSelected)
                  Positioned(
                    right: -10,
                    bottom: -10,
                    child: Icon(
                      category.icon,
                      size: 70,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),

                // Main content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Category icon
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Colors.white.withOpacity(0.3)
                                : category.color.withOpacity(0.1),
                        shape: BoxShape.circle,
                        boxShadow:
                            isSelected
                                ? [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                                : [],
                      ),
                      child: Icon(
                        category.icon,
                        size: 28,
                        color:
                            isSelected
                                ? Colors.white
                                : category.color.withOpacity(0.8),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Category name
                    Text(
                      category.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),

                    // Item count or description (optional)
                    if (category.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          isSelected ? 'Tap to view' : '',
                          style: TextStyle(
                            fontSize: 10,
                            color:
                                isSelected
                                    ? Colors.white70
                                    : Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                ),

                // Selected indicator
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        )
        .animate(target: isSelected ? 1 : 0)
        .fadeIn(duration: 300.ms, delay: 100.ms)
        .moveX(
          begin: 20,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOutQuad,
          delay: 100.ms,
        )
        .scale(
          begin: Offset(isSelected ? 1.0 : 0.95, isSelected ? 1.0 : 0.95),
          end: Offset(isSelected ? 1.05 : 1.0, isSelected ? 1.05 : 1.0),
          duration: 200.ms,
        );
  }
}

/// A horizontal list of category cards
class CategoryList extends StatelessWidget {
  final List<CategoryType> categories;
  final CategoryType selectedCategory;
  final Function(CategoryType) onCategorySelected;

  const CategoryList({
    Key? key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          // Add staggered animation with delay based on index
          return CategoryCard(
            category: category,
            isSelected: category == selectedCategory,
            onTap: () => onCategorySelected(category),
          ).animate().fadeIn(
            delay: Duration(milliseconds: 50 * index),
            duration: 300.ms,
          );
        },
      ),
    );
  }
}
