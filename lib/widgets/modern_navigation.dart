import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';
import '../utils/haptic_feedback_helper.dart';

/// A modern fluid navigation bar that uses gestures, animations and visual design
class ModernNavigation extends StatefulWidget {
  /// List of navigation items
  final List<NavigationDestination> destinations;

  /// Current selected index
  final int selectedIndex;

  /// Callback when an item is selected
  final ValueChanged<int> onDestinationSelected;

  /// Optional background color
  final Color? backgroundColor;

  /// Whether to use a floating design
  final bool floating;

  /// Whether to enable gestures
  final bool enableGestures;

  /// Whether to apply a blur effect
  final bool useBlur;

  const ModernNavigation({
    Key? key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.backgroundColor,
    this.floating = true,
    this.enableGestures = true,
    this.useBlur = true,
  }) : super(key: key);

  @override
  State<ModernNavigation> createState() => _ModernNavigationState();
}

class _ModernNavigationState extends State<ModernNavigation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _dragPositionSubject = ValueNotifier<double?>(null);
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _dragPositionSubject.dispose();
    super.dispose();
  }

  void _handleItemTap(int index) {
    if (index != widget.selectedIndex) {
      HapticFeedbackHelper.selectionClick();
      widget.onDestinationSelected(index);

      // Animate based on direction
      if (index > widget.selectedIndex) {
        _animationController.forward(from: 0.0);
      } else {
        _animationController.reverse(from: 1.0);
      }
    }
  }

  void _onDragStart(DragStartDetails details) {
    if (!widget.enableGestures) return;

    setState(() {
      _isDragging = true;
    });

    final screenWidth = MediaQuery.of(context).size.width;
    _dragPositionSubject.value = details.globalPosition.dx / screenWidth;
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (!widget.enableGestures || !_isDragging) return;

    final screenWidth = MediaQuery.of(context).size.width;
    _dragPositionSubject.value = details.globalPosition.dx / screenWidth;
  }

  void _onDragEnd(DragEndDetails details) {
    if (!widget.enableGestures || !_isDragging) return;

    setState(() {
      _isDragging = false;
    });

    final dragValue = _dragPositionSubject.value;
    if (dragValue == null) return;

    final itemWidth = 1.0 / widget.destinations.length;
    final index = (dragValue / itemWidth).floor();

    // Ensure index is in valid range
    final validIndex = index.clamp(0, widget.destinations.length - 1);

    if (validIndex != widget.selectedIndex) {
      _handleItemTap(validIndex);
    }

    _dragPositionSubject.value = null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Default background colors
    final defaultBackgroundColor =
        widget.backgroundColor ??
        (isDark
            ? Colors.black.withOpacity(0.7)
            : Colors.white.withOpacity(0.8));

    final selectedColor =
        isDark ? AppTheme.primaryColor.withOpacity(0.9) : AppTheme.primaryColor;
    final unselectedColor = isDark ? Colors.white54 : Colors.black45;

    final navBar = Container(
      height: 72,
      margin: widget.floating ? const EdgeInsets.all(16.0) : null,
      decoration: BoxDecoration(
        color:
            widget.useBlur
                ? defaultBackgroundColor
                : defaultBackgroundColor.withOpacity(0.95),
        borderRadius: widget.floating ? BorderRadius.circular(36) : null,
        boxShadow:
            widget.floating
                ? [
                  BoxShadow(
                    color:
                        isDark ? Colors.black.withOpacity(0.5) : Colors.black12,
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 5),
                  ),
                ]
                : null,
      ),
      child:
          widget.useBlur
              ? ClipRRect(
                borderRadius:
                    widget.floating
                        ? BorderRadius.circular(36)
                        : BorderRadius.zero,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: _buildNavigationItems(selectedColor, unselectedColor),
                ),
              )
              : _buildNavigationItems(selectedColor, unselectedColor),
    );

    return GestureDetector(
      onHorizontalDragStart: _onDragStart,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: _onDragEnd,
      child: navBar,
    );
  }

  Widget _buildNavigationItems(Color selectedColor, Color unselectedColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(widget.destinations.length, (index) {
        final destination = widget.destinations[index];
        final isSelected = index == widget.selectedIndex;

        return ValueListenableBuilder<double?>(
          valueListenable: _dragPositionSubject,
          builder: (context, dragValue, child) {
            final itemWidth = 1.0 / widget.destinations.length;
            final isDraggedOver =
                dragValue != null &&
                dragValue >= index * itemWidth &&
                dragValue < (index + 1) * itemWidth;

            return _NavItem(
              icon: destination.icon,
              selectedIcon: destination.selectedIcon ?? destination.icon,
              label: destination.label,
              isSelected: isSelected,
              isDraggedOver: isDraggedOver,
              selectedColor: selectedColor,
              unselectedColor: unselectedColor,
              onTap: () => _handleItemTap(index),
            );
          },
        );
      }),
    );
  }
}

/// Individual navigation item
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final bool isDraggedOver;
  final Color selectedColor;
  final Color unselectedColor;
  final VoidCallback onTap;

  const _NavItem({
    Key? key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.isDraggedOver,
    required this.selectedColor,
    required this.unselectedColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = isSelected || isDraggedOver ? selectedColor : unselectedColor;
    final scale = isSelected ? 1.0 : (isDraggedOver ? 0.9 : 0.75);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with selection indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  // Selection indicator
                  if (isSelected || isDraggedOver)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 54,
                      height: 32,
                      decoration: BoxDecoration(
                        color: selectedColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),

                  // Icon
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.identity()..scale(scale),
                    transformAlignment: Alignment.center,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Icon(
                        isSelected ? selectedIcon : icon,
                        key: ValueKey(isSelected),
                        color: color,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Label with animation
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isSelected ? 12 : 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: color,
                ),
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navigation destination item
class NavigationDestination {
  /// Icon to display when not selected
  final IconData icon;

  /// Icon to display when selected (optional)
  final IconData? selectedIcon;

  /// Label text to display
  final String label;

  /// Create a navigation destination
  const NavigationDestination({
    required this.icon,
    this.selectedIcon,
    required this.label,
  });
}
