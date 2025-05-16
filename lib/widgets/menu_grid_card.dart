import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../utils/app_theme.dart';

class MenuGridCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isHighlighted;

  const MenuGridCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  State<MenuGridCard> createState() => _MenuGridCardState();
}

class _MenuGridCardState extends State<MenuGridCard>
    with TickerProviderStateMixin {
  bool _isPressed = false;
  bool _isHovered = false;
  late AnimationController _controller;
  bool _showGlitch = false;
  late AnimationController _springController;
  late SpringSimulation _springSimulation;
  late SpringDescription _springDescription;
  final double _springEndValue = 0;
  double _springValue = 0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.repeat(reverse: true);

    // Spring animation setup
    _springController = AnimationController(
      vsync: this,
      upperBound: double.infinity,
    );
    _springController.addListener(_updateSpringAnimation);

    // Configure a bouncy spring
    _springDescription = SpringDescription(
      mass: 1.0,
      stiffness: 500.0,
      damping: 20.0,
    );

    _springSimulation = SpringSimulation(
      _springDescription,
      0.0, // starting point
      _springEndValue, // end point
      0.0, // starting velocity
    );

    // Show glitch effect randomly
    Future.delayed(Duration(milliseconds: 500 + _random.nextInt(2000)), () {
      if (mounted) {
        setState(() {
          _showGlitch = true;
        });

        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) {
            setState(() {
              _showGlitch = false;
            });
          }
        });
      }
    });
  }

  void _updateSpringAnimation() {
    if (mounted) {
      setState(() {
        _springValue = _springController.value;
      });
    }
  }

  void _triggerSpringAnimation([double velocity = 8.0]) {
    _springSimulation = SpringSimulation(
      _springDescription,
      _springValue, // starting value
      _springEndValue, // end value
      velocity, // velocity
    );
    _springController.animateWith(_springSimulation);
  }

  void _triggerGlitch() {
    setState(() => _showGlitch = true);
    Future.delayed(Duration(milliseconds: 50 + _random.nextInt(150)), () {
      if (mounted) {
        setState(() => _showGlitch = false);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _springController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        widget.isHighlighted
            ? (isDark ? AppTheme.primaryColor : AppTheme.secondaryColor)
            : widget.color;

    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.lightImpact();
          setState(() => _isPressed = true);
          _triggerSpringAnimation(-20.0); // Compress spring on tap down
          _triggerGlitch(); // Add glitch effect on press
        },
        onTapUp: (_) {
          setState(() => _isPressed = false);
          _triggerSpringAnimation(20.0); // Release spring on tap up
        },
        onTapCancel: () {
          setState(() => _isPressed = false);
          _triggerSpringAnimation(8.0); // Reset spring
        },
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onTap();
        },
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            transform: Matrix4.translationValues(0, _springValue, 0)..scale(
              _isPressed
                  ? 0.95
                  : (_isHovered ? 1.05 : 1.0) + (_springValue * 0.01),
              _isPressed
                  ? 0.95
                  : (_isHovered ? 1.05 : 1.0) - (_springValue * 0.01),
            ),
            child: Container(
              // Cyberpunk-style container
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: baseColor.withOpacity(_isHovered ? 0.9 : 0.7),
                  width: _isHovered ? 2.0 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: baseColor.withOpacity(_isHovered ? 0.6 : 0.4),
                    blurRadius: _isHovered ? 12 : 8,
                    spreadRadius: _isHovered ? 2 : 1,
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black54,
                    baseColor.withOpacity(0.1),
                    Colors.black54,
                  ],
                  stops: const [0.1, 0.5, 0.9],
                ),
              ),
              child: ClipPath(
                // Use a custom clipper for cyber corner cutouts
                clipper: CyberCornerClipper(),
                child: Stack(
                  children: [
                    // Scanline effect during glitch
                    if (_showGlitch)
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.2,
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  baseColor.withOpacity(0.8),
                                  Colors.transparent,
                                  baseColor.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                                stops: const [0.2, 0.4, 0.5, 0.6, 0.8],
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon with tech-inspired container
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black45,
                              border: Border.all(
                                color: baseColor.withOpacity(0.3),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: baseColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Icon glow
                                  Icon(
                                    widget.icon,
                                    size: 42,
                                    color: baseColor.withOpacity(0.5),
                                  ),

                                  // Main icon with simple animation
                                  Icon(
                                        widget.icon,
                                        size: 40,
                                        color: Colors.white,
                                      )
                                      .animate(controller: _controller)
                                      .scale(
                                        duration: const Duration(
                                          milliseconds: 800,
                                        ),
                                        begin: const Offset(1, 1),
                                        end: const Offset(1.05, 1.05),
                                        curve: Curves.easeInOut,
                                      ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Title text
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              border: Border(
                                left: BorderSide(
                                  color: baseColor.withOpacity(0.7),
                                  width: 2.0,
                                ),
                              ),
                            ),
                            child: Text(
                              widget.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: baseColor.withOpacity(0.7),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Custom clipper for cyber-style corner cutouts
class CyberCornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    const cornerSize = 15.0;

    // Start at top with a small cutout
    path.moveTo(cornerSize, 0);

    // Top right corner cutout
    path.lineTo(size.width - cornerSize, 0);
    path.lineTo(size.width, cornerSize);

    // Right side
    path.lineTo(size.width, size.height - cornerSize);

    // Bottom right corner cutout
    path.lineTo(size.width - cornerSize, size.height);

    // Bottom side
    path.lineTo(cornerSize, size.height);

    // Bottom left corner
    path.lineTo(0, size.height - cornerSize);

    // Left side
    path.lineTo(0, cornerSize);

    // Complete the path
    path.lineTo(cornerSize, 0);

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
