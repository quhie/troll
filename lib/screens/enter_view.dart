import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../screens/main_menu_view.dart';
import '../utils/constants.dart';
import '../utils/app_theme.dart';

class EnterView extends StatefulWidget {
  const EnterView({Key? key}) : super(key: key);

  @override
  State<EnterView> createState() => _EnterViewState();
}

class _EnterViewState extends State<EnterView> with TickerProviderStateMixin {
  late AnimationController _blobController;
  late AnimationController _pulseController;
  late AnimationController _glowController;

  // Track user interaction for floating emoji buttons
  bool _interacted = false;
  final List<FloatingEmoji> _floatingEmojis = [];

  // Random moving blobs in background
  final List<DynamicBlob> _backgroundBlobs = [];

  @override
  void initState() {
    super.initState();

    // Controller for blob shape morphing
    _blobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    )..repeat();

    // Controller for button pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Controller for background glow effect
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);

    // Create background blobs
    _createBackgroundBlobs();
  }

  @override
  void dispose() {
    _blobController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _createBackgroundBlobs() {
    final random = Random();
    // Create 5 background animated blobs with random properties
    for (int i = 0; i < 5; i++) {
      _backgroundBlobs.add(
        DynamicBlob(
          position: Offset(
            random.nextDouble() * 400 - 150,
            random.nextDouble() * 600 - 200,
          ),
          size: 120 + random.nextDouble() * 200,
          color:
              [
                AppTheme.primaryColor.withOpacity(0.05),
                AppTheme.secondaryColor.withOpacity(0.05),
                AppTheme.accentColor.withOpacity(0.05),
                AppTheme.accentColor.withOpacity(0.03),
              ][random.nextInt(4)],
          speed: 0.2 + random.nextDouble() * 0.3,
        ),
      );
    }
  }

  void _navigateToMainMenu() {
    // Add some fun floating emojis to celebrate navigation
    _addFloatingEmojis();

    // Add delay to show the emojis animation before navigation
    Future.delayed(const Duration(milliseconds: 800), () {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1200),
          pageBuilder: (_, __, ___) => const MainMenuView(),
          transitionsBuilder: (_, animation, __, child) {
            // Custom transition - circular reveal
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        ),
      );
    });
  }

  void _addFloatingEmojis() {
    setState(() {
      _interacted = true;

      // Add 20 floating emojis with random parameters
      final random = Random();
      for (int i = 0; i < 20; i++) {
        _floatingEmojis.add(
          FloatingEmoji(
            emoji: ['🔥', '😂', '🎉', '✨', '👻', '💥', '🚀'][random.nextInt(7)],
            position: Offset(
              MediaQuery.of(context).size.width / 2,
              MediaQuery.of(context).size.height * 0.75,
            ),
            velocity: Offset(
              random.nextDouble() * 8 - 4,
              random.nextDouble() * -5 - 2,
            ),
            size: 24 + random.nextDouble() * 20,
            lifespan: 1.5 + random.nextDouble(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Stack(
        children: [
          // Background with dynamic blobs
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.2, -0.3),
                radius: 1.5,
                colors:
                    isDark
                        ? [
                          AppTheme.darkSurfaceColor,
                          AppTheme.darkBackgroundColor,
                          Colors.black,
                        ]
                        : [
                          Colors.white,
                          AppTheme.lightBackgroundColor,
                          AppTheme.lightBackgroundColor.withOpacity(0.7),
                        ],
              ),
            ),
            child: AnimatedBuilder(
              animation: _blobController,
              builder: (context, _) {
                return CustomPaint(
                  painter: BackgroundBlobsPainter(
                    blobs: _backgroundBlobs,
                    animationValue: _blobController.value,
                  ),
                  size: Size(size.width, size.height),
                );
              },
            ),
          ),

          // Animated particle overlay effect
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, _) {
              return ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: (bounds) {
                  return RadialGradient(
                    center: Alignment(
                      _glowController.value * 0.8,
                      _glowController.value * 0.4 - 0.2,
                    ),
                    radius: 1.2 + _glowController.value * 0.3,
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.0),
                    ],
                    stops: const [0.0, 1.0],
                  ).createShader(bounds);
                },
                child: Container(color: Colors.white.withOpacity(0.05)),
              );
            },
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Logo section
                const SizedBox(height: 40),
                _buildLogo(isDark),

                // Title and description
                const SizedBox(height: 24),
                _buildTitleSection(isDark),

                // Main interaction area
                Expanded(child: Center(child: _buildStartButton(isDark))),

                // Hidden gesture area for subtle interactions
                GestureDetector(
                  onTap: _addFloatingEmojis,
                  child: Container(height: 100, color: Colors.transparent),
                ),
              ],
            ),
          ),

          // Floating emojis animation layer
          if (_interacted)
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) {
                // Update each emoji position based on physics
                for (final emoji in _floatingEmojis) {
                  emoji.update(0.016); // Assuming 60fps
                }

                // Remove dead emojis
                _floatingEmojis.removeWhere((emoji) => emoji.isDead);

                return CustomPaint(
                  size: Size(size.width, size.height),
                  painter: EmojisRainPainter(emojis: _floatingEmojis),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLogo(bool isDark) {
    return Column(
          children: [
            AnimatedBuilder(
              animation: _blobController,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(120, 120),
                  painter: BlobPainter(
                    color:
                        isDark
                            ? AppTheme.primaryColor.withOpacity(0.8)
                            : AppTheme.primaryColor,
                    animValue: _blobController.value,
                    minRadius: 50,
                    maxRadius: 60,
                  ),
                  child: child,
                );
              },
              child: Center(
                child: Icon(Icons.celebration, color: Colors.white, size: 50),
              ),
            ),
          ],
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: const Duration(milliseconds: 3000),
          color: Colors.white.withOpacity(0.9),
          size: 0.9,
        );
  }

  Widget _buildTitleSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          // App name with gradient
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors:
                    isDark
                        ? [
                          AppTheme.primaryColor.withOpacity(0.8),
                          AppTheme.secondaryColor.withOpacity(0.8),
                        ]
                        : [AppTheme.primaryColor, AppTheme.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(bounds);
            },
            child: Text(
              Constants.appName.toUpperCase(),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
                letterSpacing: -0.5,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // App description with frosted glass effect
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withOpacity(
                    0.05,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(
                      0.1,
                    ),
                    width: 1,
                  ),
                ),
                child: Text(
                  "A fun and innovative app with sounds and surprising effects",
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Outfit',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton(bool isDark) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        // Morphing blob button with pulse animation
        return GestureDetector(
          onTap: _navigateToMainMenu,
          child: Transform.scale(
            scale: 1.0 + (_pulseController.value * 0.05),
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDark
                          ? [
                            AppTheme.primaryColor.withOpacity(0.9),
                            AppTheme.primaryColor.withOpacity(0.7),
                          ]
                          : [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withOpacity(0.8),
                          ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isDark
                            ? AppTheme.primaryColor.withOpacity(0.5)
                            : AppTheme.primaryColor)
                        .withOpacity(0.4),
                    blurRadius: 20 + (_pulseController.value * 10),
                    spreadRadius: 5 + (_pulseController.value * 5),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Inner ring
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),

                  // Button text
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "START",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Class for the floating emoji effect
class FloatingEmoji {
  String emoji;
  Offset position;
  Offset velocity;
  double size;
  double lifespan;
  double age = 0;

  FloatingEmoji({
    required this.emoji,
    required this.position,
    required this.velocity,
    required this.size,
    required this.lifespan,
  });

  void update(double deltaTime) {
    // Update position based on velocity
    position = position + velocity * deltaTime * 60;

    // Add gravity
    velocity = velocity + Offset(0, 0.1) * deltaTime * 60;

    // Update age
    age += deltaTime;
  }

  bool get isDead => age >= lifespan;

  double get opacity => 1.0 - (age / lifespan);
}

// Custom painter for the floating emojis animation
class EmojisRainPainter extends CustomPainter {
  final List<FloatingEmoji> emojis;

  EmojisRainPainter({required this.emojis});

  @override
  void paint(Canvas canvas, Size size) {
    for (final emoji in emojis) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: emoji.emoji,
          style: TextStyle(
            fontSize: emoji.size,
            color: Colors.white.withOpacity(emoji.opacity),
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        emoji.position - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Dynamic blob for background animation
class DynamicBlob {
  Offset position;
  double size;
  Color color;
  double speed;

  DynamicBlob({
    required this.position,
    required this.size,
    required this.color,
    required this.speed,
  });
}

// Custom painter for the dynamic background blobs
class BackgroundBlobsPainter extends CustomPainter {
  final List<DynamicBlob> blobs;
  final double animationValue;

  BackgroundBlobsPainter({required this.blobs, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (final blob in blobs) {
      final center = Offset(
        blob.position.dx + sin(animationValue * 2 * pi) * 20 * blob.speed,
        blob.position.dy + cos(animationValue * 2 * pi) * 20 * blob.speed,
      );

      final paint =
          Paint()
            ..color = blob.color
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      // Create a blob path
      final path = Path();
      final random = Random(blob.size.toInt());
      final points = 8;
      final angleStep = 2 * pi / points;

      List<Offset> blobPoints = [];
      for (int i = 0; i < points; i++) {
        final theta = i * angleStep;
        final radiusVariation =
            sin(theta * 3 + animationValue * 2 * pi) * blob.size * 0.2;
        final radius = blob.size / 2 + radiusVariation;

        final x = center.dx + radius * cos(theta);
        final y = center.dy + radius * sin(theta);
        blobPoints.add(Offset(x, y));
      }

      // Draw a smooth blob using cubic curves
      path.moveTo(blobPoints[0].dx, blobPoints[0].dy);

      for (int i = 0; i < blobPoints.length; i++) {
        final current = blobPoints[i];
        final next = blobPoints[(i + 1) % blobPoints.length];
        final controlPoint1 = Offset(
          current.dx + (next.dx - current.dx) / 3,
          current.dy + (next.dy - current.dy) / 3,
        );
        final controlPoint2 = Offset(
          current.dx + 2 * (next.dx - current.dx) / 3,
          current.dy + 2 * (next.dy - current.dy) / 3,
        );

        path.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          next.dx,
          next.dy,
        );
      }

      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
