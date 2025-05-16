import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A widget for displaying a category header with an icon and title
class CategoryHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final int itemCount;

  const CategoryHeader({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
    this.itemCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color.withOpacity(0.9), color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Icon with animated glow effect
                    Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(icon, color: Colors.white, size: 28),
                        )
                        .animate(
                          onPlay:
                              (controller) => controller.repeat(reverse: true),
                        )
                        .scaleXY(
                          begin: 1.0,
                          end: 1.05,
                          duration: const Duration(seconds: 2),
                          curve: Curves.easeInOut,
                        ),

                    const SizedBox(width: 14),

                    // Title and count
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          if (itemCount > 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              '$itemCount sounds',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Arrow icon with bounce animation
                    Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            onTap != null
                                ? Icons.arrow_forward_ios
                                : Icons.arrow_downward,
                            color: Colors.white.withOpacity(0.9),
                            size: 18,
                          ),
                        )
                        .animate(
                          onPlay:
                              (controller) => controller.repeat(reverse: true),
                        )
                        .moveX(
                          begin: 0,
                          end: 5,
                          duration: const Duration(seconds: 1),
                          curve: Curves.easeInOut,
                        ),
                  ],
                ),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .moveY(begin: 20, end: 0, duration: 500.ms, curve: Curves.easeOutQuint);
  }
}
