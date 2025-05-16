import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Creates a neon border effect for containers
class NeonBorder extends BoxDecoration {
  NeonBorder({
    required Color color,
    BorderRadiusGeometry? borderRadius,
    double width = 2.0,
    List<Color>? gradientColors,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) : super(
         borderRadius: borderRadius,
         border: Border.all(color: color, width: width),
         boxShadow: [
           BoxShadow(
             color: color.withOpacity(0.6),
             blurRadius: 8,
             spreadRadius: 0.5,
           ),
           BoxShadow(
             color: color.withOpacity(0.4),
             blurRadius: 5,
             spreadRadius: 0.3,
           ),
         ],
         gradient:
             gradientColors != null
                 ? LinearGradient(
                   begin: begin,
                   end: end,
                   colors: gradientColors,
                 )
                 : null,
       );
}

/// A container decoration that adds a neon border effect
class NeonBorderNew extends BoxDecoration {
  /// Creates a neon border decoration
  NeonBorderNew({
    required Color color,
    double width = 2.0,
    double blurRadius = 10.0,
    BorderRadius? borderRadius,
  }) : super(
         borderRadius: borderRadius ?? BorderRadius.circular(12),
         boxShadow: [
           BoxShadow(
             color: color.withOpacity(0.7),
             blurRadius: blurRadius,
             spreadRadius: 0,
           ),
         ],
         border: Border.all(color: color, width: width),
       );
}

/// A widget that wraps its child with an animated neon border effect
class AnimatedNeonBorder extends StatefulWidget {
  /// The child widget to wrap with the neon border
  final Widget child;

  /// The color of the neon border
  final Color color;

  /// Border radius for the container
  final BorderRadius borderRadius;

  /// Border width
  final double borderWidth;

  /// Whether to animate the glow effect
  final bool animate;

  /// Creates an animated neon border widget
  const AnimatedNeonBorder({
    Key? key,
    required this.child,
    required this.color,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.borderWidth = 2.0,
    this.animate = true,
  }) : super(key: key);

  @override
  State<AnimatedNeonBorder> createState() => _AnimatedNeonBorderState();
}

class _AnimatedNeonBorderState extends State<AnimatedNeonBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _glowAnimation = Tween<double>(
      begin: 5.0,
      end: 15.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AnimatedNeonBorder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.animate != oldWidget.animate) {
      if (widget.animate) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: widget.borderRadius,
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.4),
                blurRadius: widget.animate ? _glowAnimation.value : 10.0,
                spreadRadius: 0,
              ),
            ],
            border: Border.all(color: widget.color, width: widget.borderWidth),
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius.copyWith(
              topLeft: Radius.circular(
                math.max(0, widget.borderRadius.topLeft.x - widget.borderWidth),
              ),
              topRight: Radius.circular(
                math.max(
                  0,
                  widget.borderRadius.topRight.x - widget.borderWidth,
                ),
              ),
              bottomLeft: Radius.circular(
                math.max(
                  0,
                  widget.borderRadius.bottomLeft.x - widget.borderWidth,
                ),
              ),
              bottomRight: Radius.circular(
                math.max(
                  0,
                  widget.borderRadius.bottomRight.x - widget.borderWidth,
                ),
              ),
            ),
            child: widget.child,
          ),
        );
      },
    );
  }
}
