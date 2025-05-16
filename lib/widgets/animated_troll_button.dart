import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../utils/constants.dart';
import '../utils/app_theme.dart';
import '../utils/haptic_feedback_helper.dart';

class AnimatedTrollButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? color;
  final double? width;
  final double? height;
  final bool animate;
  final bool showConfetti;
  final bool elevated;
  final bool useGradient;

  const AnimatedTrollButton({
    Key? key,
    required this.text,
    this.icon,
    required this.onTap,
    this.color,
    this.width,
    this.height,
    this.animate = true,
    this.showConfetti = false,
    this.elevated = true,
    this.useGradient = true,
  }) : super(key: key);

  @override
  State<AnimatedTrollButton> createState() => _AnimatedTrollButtonState();
}

class _AnimatedTrollButtonState extends State<AnimatedTrollButton>
    with TickerProviderStateMixin {
  bool _isPressed = false;
  bool _isHovered = false;
  late AnimationController _pulseController;
  late ConfettiController _confettiController;
  late AnimationController _springController;
  late SpringSimulation _springSimulation;
  double _springValue = 0;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.animate) {
      _pulseController.repeat(reverse: true);
    }

    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 800),
    );

    // Set up spring animation controller
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..addListener(_updateSpringAnimation);
  }

  void _updateSpringAnimation() {
    if (mounted) {
      setState(() {
        _springValue = _springController.value;
      });
    }
  }

  void _animateSpring({required double velocity}) {
    // Create spring simulation
    final SpringDescription spring = SpringDescription(
      mass: 1.0,
      stiffness: 90.0,
      damping: 12.0,
    );

    _springSimulation = SpringSimulation(
      spring,
      _springController.value, // starting value
      1.0, // ending value
      velocity, // starting velocity
    );

    // Run the simulation
    _springController.animateWith(_springSimulation);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _confettiController.dispose();
    _springController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).primaryColor;
    final shadowColor = color.withOpacity(0.6);

    // Create gradient colors
    final gradientColors = [
      color,
      Color.lerp(color, Colors.black, 0.3) ?? color,
    ];

    final buttonWidth = widget.width ?? 220;
    final buttonHeight = widget.height ?? 65;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Confetti controller
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          particleDrag: 0.05,
          emissionFrequency: 0.06,
          numberOfParticles: 25,
          gravity: 0.1,
          colors: [
            AppTheme.primaryColor,
            AppTheme.secondaryColor,
            AppTheme.accentColor,
            Colors.yellow,
            Colors.purple,
            Colors.white,
          ],
        ),

        // Shadow - separated for better animation
        if (widget.elevated && !_isPressed)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 150),
            bottom: _isHovered ? 0 : 5,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: buttonWidth - 8,
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: _isHovered ? 20 : 15,
                    spreadRadius: _isHovered ? 2 : 0,
                  ),
                ],
              ),
            ),
          ),

        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTapDown: (_) {
              HapticFeedbackHelper.lightImpact();
              setState(() => _isPressed = true);
              _springController.value = 0.0;
              _animateSpring(velocity: 0.8);
            },
            onTapUp:
                (_) => setState(() {
                  _isPressed = false;
                  if (widget.showConfetti) {
                    _confettiController.play();
                  }
                  _animateSpring(velocity: -1.2);
                }),
            onTapCancel: () {
              setState(() => _isPressed = false);
              _animateSpring(velocity: -0.5);
            },
            onTap: () {
              HapticFeedbackHelper.mediumImpact();
              widget.onTap();
            },
            child: AnimatedBuilder(
              animation: _springController,
              builder: (context, child) {
                // Calculate spring-based transformations
                final yOffset = _isPressed ? 4.0 : (_isHovered ? -4.0 : 0.0);
                final scale =
                    _isPressed
                        ? 0.96
                        : (_isHovered ? 1.06 : 1.0) + (_springValue * 0.05);

                return Transform.scale(
                  scale: scale,
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      yOffset + (_springValue * (_isPressed ? 2 : -3)),
                    ),
                    child: Container(
                      width: buttonWidth,
                      height: buttonHeight,
                      decoration: BoxDecoration(
                        gradient:
                            widget.useGradient
                                ? LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: gradientColors,
                                )
                                : null,
                        color: widget.useGradient ? null : color,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow:
                            _isPressed || !widget.elevated
                                ? []
                                : [
                                  BoxShadow(
                                    color: shadowColor,
                                    blurRadius: _isHovered ? 12 : 8,
                                    offset:
                                        _isHovered
                                            ? const Offset(0, 6)
                                            : const Offset(0, 4),
                                    spreadRadius: _isHovered ? 1 : 0,
                                  ),
                                ],
                      ),
                      child: Stack(
                        children: [
                          // Background pattern
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: CustomPaint(
                                painter: TrollPatternPainter(),
                              ),
                            ),
                          ),

                          // Button highlight
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 25,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withOpacity(0.6),
                                    Colors.white.withOpacity(0.0),
                                  ],
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(30),
                                  topRight: Radius.circular(30),
                                ),
                              ),
                            ),
                          ),

                          // Button content
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.icon != null) ...[
                                  Icon(
                                    widget.icon,
                                    color: Colors.white,
                                    size: 28,
                                  ).animate(
                                    autoPlay: widget.animate,
                                    onPlay:
                                        (controller) =>
                                            controller.repeat(reverse: true),
                                    effects: [
                                      RotateEffect(
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),
                                        begin: -0.05,
                                        end: 0.05,
                                        curve: Curves.easeInOut,
                                      ),
                                      ScaleEffect(
                                        begin: const Offset(1.0, 1.0),
                                        end: const Offset(1.2, 1.2),
                                        duration: const Duration(
                                          milliseconds: 400,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Text(
                                  widget.text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black45,
                                        offset: Offset(0, 2),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                ).animate(
                                  autoPlay: widget.animate,
                                  effects: [
                                    ShimmerEffect(
                                      duration: const Duration(
                                        milliseconds: 1500,
                                      ),
                                      color: Colors.white.withOpacity(0.9),
                                      delay: const Duration(milliseconds: 1000),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Ripple effect on press
                          if (_isPressed)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: CustomPaint(painter: RipplePainter()),
                              ),
                            ),

                          // Edge shine effect when hovered
                          if (_isHovered)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),

                          // Random sparkles when hovered
                          if (_isHovered)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: CustomPaint(
                                  painter: SparklesPainter(random: _random),
                                  child: Container(),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class TrollPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.fill;

    // Draw zigzag pattern
    final path = Path();
    const zigzagHeight = 4.0;
    const zigzagWidth = 10.0;

    for (double x = 0; x < size.width; x += zigzagWidth * 2) {
      path.moveTo(x, 0);
      path.relativeLineTo(zigzagWidth, zigzagHeight);
      path.relativeLineTo(zigzagWidth, -zigzagHeight);
    }

    for (double y = zigzagHeight * 2; y < size.height; y += zigzagHeight * 2) {
      for (double x = 0; x < size.width; x += zigzagWidth * 2) {
        path.moveTo(x, y);
        path.relativeLineTo(zigzagWidth, zigzagHeight);
        path.relativeLineTo(zigzagWidth, -zigzagHeight);
      }
    }

    canvas.drawPath(path, paint);

    // Draw small dots
    const spacing = 20.0;
    final dotPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.2)
          ..style = PaintingStyle.fill;

    for (var x = spacing; x < size.width; x += spacing) {
      for (var y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SparklesPainter extends CustomPainter {
  final Random random;

  SparklesPainter({required this.random});

  @override
  void paint(Canvas canvas, Size size) {
    final sparklePaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    // Draw random sparkles
    final numSparkles = 8 + random.nextInt(6); // 8-14 sparkles

    for (var i = 0; i < numSparkles; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 0.8 + random.nextDouble() * 1.2;

      canvas.drawCircle(Offset(x, y), radius, sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RipplePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.4)
          ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.35,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
