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

class _MenuGridCardState extends State<MenuGridCard> with TickerProviderStateMixin {
  bool _isPressed = false;
  bool _isHovered = false;
  late AnimationController _controller;
  bool _showSparkle = false;
  late AnimationController _springController;
  late SpringSimulation _springSimulation;
  late SpringDescription _springDescription;
  final double _springEndValue = 0;
  double _springValue = 0;

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
      0.0,     // starting point
      _springEndValue, // end point
      0.0,     // starting velocity
    );
    
    // Show sparkle effect randomly
    Future.delayed(Duration(milliseconds: 500 + Random().nextInt(2000)), () {
      if (mounted) {
        setState(() {
          _showSparkle = true;
        });
        
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _showSparkle = false;
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
      _springValue,  // starting value
      _springEndValue, // end value
      velocity,      // velocity
    );
    _springController.animateWith(_springSimulation);
  }

  @override
  void dispose() {
    _controller.dispose();
    _springController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isHighlighted 
        ? AppTheme.highlightColor 
        : widget.color;
    
    return RepaintBoundary(
      child: GestureDetector(
        onTapDown: (_) {
          HapticFeedback.lightImpact();
          setState(() => _isPressed = true);
          _triggerSpringAnimation(-20.0); // Compress spring on tap down
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
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              boxShadow: _isPressed
                  ? []
                  : [
                      BoxShadow(
                        color: baseColor.withOpacity(0.5),
                        blurRadius: _isHovered ? 15 : 10,
                        offset: _isHovered ? const Offset(0, 7) : const Offset(0, 5),
                        spreadRadius: _isHovered ? 2 : 0,
                      ),
                    ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseColor,
                  Color.lerp(baseColor, Colors.black, 0.4) ?? baseColor,
                ],
              ),
            ),
            transform: Matrix4.translationValues(0, _springValue, 0)..scale(
              _isPressed ? 0.95 : (_isHovered ? 1.05 : 1.0) + (_springValue * 0.01),
              _isPressed ? 0.95 : (_isHovered ? 1.05 : 1.0) - (_springValue * 0.01),
            ),
            child: Stack(
              children: [
                // Background subtle pattern - optimized to only paint once
                if (!_isPressed) // Only show pattern when not pressed to reduce repaints
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(40),
                        child: CustomPaint(
                          painter: TrollPatternPainter(baseColor),
                          isComplex: true, // Hint to the framework this is a complex painting
                        ),
                      ),
                    ),
                  ),
                
                // Highlight at top
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.5),
                          Colors.white.withOpacity(0.0),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
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
                      // Sparkle effect (shows occasionally)
                      if (_showSparkle)
                        RepaintBoundary(
                          child:
                          Positioned(
                            top: 0,
                            right: 10,
                            child: SpinKitPumpingHeart(
                              color: Colors.white.withOpacity(0.8),
                              size: 25,
                              duration: const Duration(milliseconds: 1200),
                            ),
                          ),
                        ),
                      
                      // Icon with animation - simplified animations
                      RepaintBoundary(
                        child:
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // Icon shadow/glow
                            Icon(
                              widget.icon,
                              size: 52,
                              color: Colors.black.withOpacity(0.3),
                            ),
                            
                            // Main icon - reduce animation complexity
                            Icon(
                              widget.icon,
                              size: 50,
                              color: Colors.white,
                            ).animate(controller: _controller)
                              .scale(
                                duration: const Duration(milliseconds: 800),
                                begin: const Offset(1, 1),
                                end: const Offset(1.05, 1.05),
                                curve: Curves.easeInOut,
                              ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // Title with animated background
                      RepaintBoundary(
                        child:
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate()
            .fadeIn(
              duration: const Duration(milliseconds: 300),
            ),
        ),
      ),
    );
  }
}

class TrollPatternPainter extends CustomPainter {
  final Color baseColor;
  
  TrollPatternPainter(this.baseColor);
  
  @override
  void paint(Canvas canvas, Size size) {
    // Simplified bubbles - draw fewer elements
    final bubblePaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    
    final random = Random(42); // Fixed seed for consistent pattern
    for (int i = 0; i < 10; i++) { // Reduced from 20 to 10
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 1.0 + random.nextDouble() * 3;
      canvas.drawCircle(Offset(x, y), radius, bubblePaint);
    }
    
    // Draw fewer pattern lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // Draw fewer diagonal lines with larger spacing
    for (double i = -size.height; i < size.width; i += 40) { // Increased spacing from 20 to 40
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 