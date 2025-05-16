import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';
import 'glitch_text.dart';

class CyberpunkBottomSheet extends StatefulWidget {
  final Widget child;
  final String? title;
  final Color? color;
  final VoidCallback? onClose;
  final bool showGlitchEffect;
  final bool showGridBackground;
  final double borderRadius;

  const CyberpunkBottomSheet({
    Key? key,
    required this.child,
    this.title,
    this.color,
    this.onClose,
    this.showGlitchEffect = true,
    this.showGridBackground = true,
    this.borderRadius = 20.0,
  }) : super(key: key);

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    Color? color,
    bool showGlitchEffect = true,
    bool showGridBackground = true,
    double borderRadius = 20.0,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return CyberpunkBottomSheet(
          child: child,
          title: title,
          color: color ?? Theme.of(context).primaryColor,
          onClose: () => Navigator.of(context).pop(),
          showGlitchEffect: showGlitchEffect,
          showGridBackground: showGridBackground,
          borderRadius: borderRadius,
        );
      },
    );
  }

  @override
  State<CyberpunkBottomSheet> createState() => _CyberpunkBottomSheetState();
}

class _CyberpunkBottomSheetState extends State<CyberpunkBottomSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final Random _random = Random();
  bool _showGlitch = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    if (widget.showGlitchEffect) {
      _triggerRandomGlitches();
    }
  }

  void _triggerRandomGlitches() {
    Future.delayed(Duration(milliseconds: 500 + _random.nextInt(3000)), () {
      if (mounted) {
        setState(() {
          _showGlitch = true;
        });

        Future.delayed(Duration(milliseconds: 50 + _random.nextInt(150)), () {
          if (mounted) {
            setState(() {
              _showGlitch = false;
            });
            _triggerRandomGlitches(); // Schedule the next glitch
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.color ?? Theme.of(context).primaryColor;
    final screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        return Container(
          height: screenHeight * 0.8,
          decoration: _buildDecoration(baseColor),
          child: Stack(
            children: [
              // Grid background
              if (widget.showGridBackground) _buildGridBackground(baseColor),

              // Scanline effect during glitch
              if (_showGlitch) _buildScanlines(baseColor),

              // Content with clip
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: ClipPath(
                  clipper: CyberpunkClipper(cornerSize: 20),
                  child: Container(
                    height: double.infinity,
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 24.0,
                      left: 16.0,
                      right: 16.0,
                      bottom: 16.0,
                    ),
                    child: widget.child,
                  ),
                ),
              ),

              // Header with title
              _buildHeader(baseColor, context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(Color baseColor, BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black87,
          border: Border(
            bottom: BorderSide(color: baseColor.withOpacity(0.7), width: 2.0),
          ),
        ),
        child: Stack(
          children: [
            // Tech pattern on header
            Positioned.fill(
              child: CustomPaint(
                painter: CircuitPatternPainter(
                  color: baseColor,
                  animate: _animationController.value,
                ),
              ),
            ),

            // Title
            Center(
              child:
                  widget.title != null
                      ? widget.showGlitchEffect
                          ? GlitchText(
                            widget.title!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  color: baseColor.withOpacity(0.7),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          )
                          : Text(
                            widget.title!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  color: baseColor.withOpacity(0.7),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          )
                      : const SizedBox(),
            ),

            // Close button
            Positioned(
              top: 0,
              right: 0,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    if (widget.onClose != null) {
                      widget.onClose!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.close,
                      color: Colors.white.withOpacity(0.8),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridBackground(Color baseColor) {
    return Positioned.fill(
      child: CustomPaint(
        painter: GridBackgroundPainter(
          color: baseColor,
          animate: _animationController.value,
        ),
      ),
    );
  }

  Widget _buildScanlines(Color baseColor) {
    return Positioned.fill(
      child: Opacity(
        opacity: 0.15,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                baseColor.withOpacity(0.7),
                Colors.transparent,
                baseColor.withOpacity(0.7),
                Colors.transparent,
              ],
              stops: const [0.2, 0.4, 0.5, 0.6, 0.8],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(Color baseColor) {
    final glowOpacity = 0.4 + (_animationController.value * 0.3);

    return BoxDecoration(
      color: Colors.black87,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(widget.borderRadius),
        topRight: Radius.circular(widget.borderRadius),
      ),
      boxShadow: [
        BoxShadow(
          color: baseColor.withOpacity(glowOpacity),
          blurRadius: 16,
          spreadRadius: 2,
        ),
      ],
      border: Border.all(color: baseColor.withOpacity(0.7), width: 2.0),
    );
  }
}

// Custom clipper for cyber-style cutout corners
class CyberpunkClipper extends CustomClipper<Path> {
  final double cornerSize;

  CyberpunkClipper({this.cornerSize = 20.0});

  @override
  Path getClip(Size size) {
    final path = Path();

    // Top left with diagonal cutout
    path.moveTo(cornerSize, 0);
    path.lineTo(size.width - cornerSize, 0);
    path.lineTo(size.width, cornerSize);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, cornerSize);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CyberpunkClipper oldClipper) =>
      oldClipper.cornerSize != cornerSize;
}

// Circuit pattern painter for header
class CircuitPatternPainter extends CustomPainter {
  final Color color;
  final double animate;

  CircuitPatternPainter({required this.color, required this.animate});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = color.withOpacity(0.3);

    // Horizontal circuit line
    path.moveTo(0, size.height * 0.5);
    path.lineTo(size.width * 0.2, size.height * 0.5);

    // Branch up
    path.moveTo(size.width * 0.2, size.height * 0.5);
    path.lineTo(size.width * 0.2, size.height * 0.3);
    path.lineTo(size.width * 0.4, size.height * 0.3);

    // Branch continues
    path.moveTo(size.width * 0.2, size.height * 0.5);
    path.lineTo(size.width * 0.4, size.height * 0.5);
    path.lineTo(size.width * 0.4, size.height * 0.7);
    path.lineTo(size.width * 0.6, size.height * 0.7);

    // Right side circuit
    path.moveTo(size.width, size.height * 0.5);
    path.lineTo(size.width * 0.8, size.height * 0.5);
    path.lineTo(size.width * 0.8, size.height * 0.3);
    path.lineTo(size.width * 0.6, size.height * 0.3);
    path.lineTo(size.width * 0.6, size.height * 0.7);

    canvas.drawPath(path, paint);

    // Draw data packet animation
    final packetPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = color;

    // Left horizontal packet
    if (animate < 0.33) {
      final x = animate * 3 * size.width * 0.2;
      canvas.drawCircle(Offset(x, size.height * 0.5), 2.0, packetPaint);
    }

    // Right horizontal packet
    if (animate > 0.66) {
      final normalizedAnimate = (animate - 0.66) * 3;
      final x = size.width - (normalizedAnimate * size.width * 0.2);
      canvas.drawCircle(Offset(x, size.height * 0.5), 2.0, packetPaint);
    }

    // Branch packet
    if (animate > 0.33 && animate < 0.66) {
      final normalizedAnimate = (animate - 0.33) * 3;
      if (normalizedAnimate < 0.5) {
        // Going up the branch
        final y =
            size.height * 0.5 - (normalizedAnimate * 2 * size.height * 0.2);
        canvas.drawCircle(Offset(size.width * 0.2, y), 2.0, packetPaint);
      } else {
        // Moving right along top branch
        final x =
            size.width * 0.2 +
            ((normalizedAnimate - 0.5) * 2 * size.width * 0.2);
        canvas.drawCircle(Offset(x, size.height * 0.3), 2.0, packetPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CircuitPatternPainter oldDelegate) {
    return oldDelegate.animate != animate || oldDelegate.color != color;
  }
}

// Grid background painter
class GridBackgroundPainter extends CustomPainter {
  final Color color;
  final double animate;

  GridBackgroundPainter({required this.color, required this.animate});

  @override
  void paint(Canvas canvas, Size size) {
    final gridSpacing = size.width / 15;
    final gridPaint =
        Paint()
          ..color = color.withOpacity(0.15)
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke;

    // Draw horizontal grid lines
    for (double y = 0; y <= size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw vertical grid lines
    for (double x = 0; x <= size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Draw data nodes at random intersections
    final nodePaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = color.withOpacity(0.6);

    final random = Random(42); // Fixed seed for consistent pattern

    for (int i = 0; i < 5; i++) {
      final x = (random.nextInt(15) + 0.5) * gridSpacing;
      final y = (random.nextInt(20) + 0.5) * gridSpacing;

      if (y < size.height) {
        final pulseSize = 2.0 + sin(animate * 2 * pi) * 1.0;
        canvas.drawCircle(Offset(x, y), pulseSize, nodePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant GridBackgroundPainter oldDelegate) {
    return oldDelegate.animate != animate || oldDelegate.color != color;
  }
}
