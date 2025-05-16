import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:confetti/confetti.dart';
import '../viewmodels/sound_flash_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../utils/app_theme.dart';
import '../widgets/animated_troll_button.dart';
import '../models/sound_model.dart';
import '../utils/haptic_feedback_helper.dart';

class SoundFlashView extends StatelessWidget {
  final String title;
  final String soundPath;
  final String iconName;
  final String? categoryTitle;
  final List<SoundModel>? categorySounds;

  const SoundFlashView({
    Key? key,
    required this.title,
    required this.soundPath,
    required this.iconName,
    this.categoryTitle,
    this.categorySounds,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SoundFlashViewModel>(
      create: (_) => SoundFlashViewModel(),
      child: Consumer<SoundFlashViewModel>(
        builder: (context, viewModel, _) {
          return _SoundFlashViewContent(
            title: title,
            soundPath: soundPath,
            iconName: iconName,
            categoryTitle: categoryTitle,
            categorySounds: categorySounds,
          );
        },
      ),
    );
  }
}

class _SoundFlashViewContent extends StatefulWidget {
  final String title;
  final String soundPath;
  final String iconName;
  final String? categoryTitle;
  final List<SoundModel>? categorySounds;

  const _SoundFlashViewContent({
    Key? key,
    required this.title,
    required this.soundPath,
    required this.iconName,
    this.categoryTitle,
    this.categorySounds,
  }) : super(key: key);

  @override
  State<_SoundFlashViewContent> createState() => _SoundFlashViewContentState();
}

class _SoundFlashViewContentState extends State<_SoundFlashViewContent>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _pulseController;
  late ConfettiController _confettiController;
  late AnimationController _rippleController;

  // Particles for visual effects
  final List<FlashParticle> _particles = [];
  Timer? _particleTimer;
  final Random _random = Random();

  // UI states
  bool _isPressAnimating = false;
  double _visualizerValue = 0.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 2000),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Start visualizer animation
    _startVisualizer();
  }

  void _startVisualizer() {
    _particleTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      final viewModel = Provider.of<SoundFlashViewModel>(
        context,
        listen: false,
      );

      if (viewModel.isActive) {
        setState(() {
          _visualizerValue = _random.nextDouble();
          _updateParticles();
        });
      } else if (_visualizerValue > 0.05) {
        setState(() {
          _visualizerValue *= 0.95;
        });
      }
    });
  }

  void _createParticles() {
    if (_particles.length > 30) return;

    // Create some random particles
    for (int i = 0; i < 5; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 0.5 + _random.nextDouble() * 2.0;
      final size = 5.0 + _random.nextDouble() * 8.0;

      _particles.add(
        FlashParticle(
          position: Offset(
            MediaQuery.of(context).size.width / 2,
            MediaQuery.of(context).size.height / 2,
          ),
          velocity: Offset(cos(angle) * speed, sin(angle) * speed),
          color: _getRandomColor(),
          size: size,
          lifespan: 60 + _random.nextInt(40),
        ),
      );
    }
  }

  void _updateParticles() {
    if (!mounted) return;

    // Update existing particles
    for (var particle in _particles) {
      particle.update();
    }

    // Remove dead particles
    _particles.removeWhere((particle) => particle.lifespan <= 0);

    // Create new particles if active
    final viewModel = Provider.of<SoundFlashViewModel>(context, listen: false);
    if (viewModel.isActive && _random.nextDouble() < 0.3) {
      _createParticles();
    }
  }

  Color _getRandomColor() {
    final viewModel = Provider.of<SoundFlashViewModel>(context, listen: false);
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      Colors.yellow,
      Colors.purple,
      Colors.white,
    ];

    if (viewModel.isActive) {
      // More bias towards energetic colors when active
      return colors[_random.nextInt(3) + 3]; // Use last 3 colors
    } else {
      return colors[_random.nextInt(colors.length)];
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _confettiController.dispose();
    _rippleController.dispose();
    _particleTimer?.cancel();
    super.dispose();
  }

  void _handlePressStart() {
    HapticFeedbackHelper.heavyImpact();
    final viewModel = Provider.of<SoundFlashViewModel>(context, listen: false);
    viewModel.startEffects(widget.soundPath);
    _rippleController.reset();
    _rippleController.forward();
    setState(() => _isPressAnimating = true);
  }

  void _handlePressEnd() {
    final viewModel = Provider.of<SoundFlashViewModel>(context, listen: false);
    viewModel.stopEffects();
    setState(() => _isPressAnimating = false);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SoundFlashViewModel>(context);
    final themeViewModel = Provider.of<ThemeViewModel>(context, listen: false);
    final isDark = themeViewModel.isDarkMode;

    // Choose vibrant colors
    final Color primaryColor =
        isDark ? AppTheme.primaryColor.withOpacity(0.8) : AppTheme.primaryColor;
    final Color accentColor =
        isDark ? AppTheme.accentColor.withOpacity(0.8) : AppTheme.accentColor;
    final Color energyColor = Colors.purple;

    // Play confetti when activated
    if (viewModel.isActive) {
      _confettiController.play();
    }

    // Use const IconData instead of dynamic creation
    const IconData playIconData = Icons.play_arrow;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors:
                    viewModel.isActive
                        ? [
                          energyColor.withOpacity(0.7),
                          isDark ? Colors.black : Colors.deepPurple.shade900,
                        ]
                        : [
                          primaryColor,
                          isDark
                              ? Colors.black
                              : Color.lerp(primaryColor, Colors.black, 0.8)!,
                        ],
              ),
            ),
          ),

          // Dynamic background pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: DynamicPatternPainter(
                      isActive: viewModel.isActive,
                      color: viewModel.isActive ? energyColor : primaryColor,
                      animationValue: _pulseController.value,
                    ),
                  );
                },
              ),
            ),
          ),

          // Particle effect layer
          if (_particles.isNotEmpty)
            Positioned.fill(
              child: CustomPaint(painter: ParticlesPainter(_particles)),
            ),

          // Confetti effect
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2, // Straight up
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: [
                primaryColor,
                accentColor,
                energyColor,
                Colors.purple,
                Colors.green,
                Colors.white,
              ],
            ),
          ),

          // Main content
          SafeArea(
            child: GestureDetector(
              onLongPressStart: (_) => _handlePressStart(),
              onLongPressEnd: (_) => _handlePressEnd(),
              onTap: () => HapticFeedbackHelper.mediumImpact(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon with animations
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background glow
                        if (viewModel.isActive)
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 180 + (_pulseController.value * 30),
                                height: 180 + (_pulseController.value * 30),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.transparent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: energyColor.withOpacity(
                                        0.3 + (_pulseController.value * 0.3),
                                      ),
                                      blurRadius:
                                          50 + (_pulseController.value * 20),
                                      spreadRadius:
                                          10 + (_pulseController.value * 10),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                        // Pulse animation
                        if (viewModel.isActive)
                          SpinKitPulse(
                            color: energyColor.withOpacity(0.3),
                            size: 220,
                            duration: const Duration(milliseconds: 1500),
                          ),

                        // Ripple animation on press
                        ScaleTransition(
                          scale: _rippleController.drive(
                            Tween<double>(
                              begin: 0.1,
                              end: 3.0,
                            ).chain(CurveTween(curve: Curves.easeOut)),
                          ),
                          child: Opacity(
                            opacity: viewModel.isActive ? 0.4 : 0.0,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: energyColor.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),

                        // Main icon
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: viewModel.isActive ? 180 : 140,
                          height: viewModel.isActive ? 180 : 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                viewModel.isActive
                                    ? energyColor.withOpacity(0.3)
                                    : primaryColor.withOpacity(0.3),
                            border: Border.all(
                              color:
                                  viewModel.isActive
                                      ? energyColor
                                      : primaryColor,
                              width: viewModel.isActive ? 3 : 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (viewModel.isActive
                                        ? energyColor
                                        : primaryColor)
                                    .withOpacity(0.4),
                                blurRadius: viewModel.isActive ? 15 : 10,
                                spreadRadius: viewModel.isActive ? 4 : 2,
                              ),
                            ],
                          ),
                          child: Icon(
                            viewModel.isActive ? Icons.music_note : playIconData,
                            size: viewModel.isActive ? 100 : 80,
                            color:
                                viewModel.isActive
                                    ? Colors.white
                                    : primaryColor,
                          ).animate(
                            autoPlay: true,
                            onPlay:
                                (controller) =>
                                    controller.repeat(reverse: true),
                            effects: [
                              // More energetic animation when active
                              ScaleEffect(
                                begin: Offset(1.0, 1.0),
                                end: Offset(
                                  viewModel.isActive ? 1.2 : 1.1,
                                  viewModel.isActive ? 1.2 : 1.1,
                                ),
                                duration: Duration(
                                  milliseconds: viewModel.isActive ? 400 : 800,
                                ),
                                curve: Curves.easeInOut,
                              ),
                              // Add glow effect when active
                              ShimmerEffect(
                                duration: Duration(
                                  milliseconds:
                                      viewModel.isActive ? 1200 : 2000,
                                ),
                                color:
                                    viewModel.isActive
                                        ? Colors.white
                                        : primaryColor.withOpacity(0.8),
                                delay: Duration(milliseconds: 500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Status text
                    Text(
                      viewModel.isActive
                          ? widget.title.toUpperCase() + ' ACTIVATED!'
                          : 'Press and Hold to Activate',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color:
                            viewModel.isActive
                                ? Colors.white
                                : Colors.white.withOpacity(0.9),
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ).animate(
                      target: viewModel.isActive ? 1.0 : 0.0,
                      effects: [
                        ShakeEffect(
                          duration: const Duration(milliseconds: 1000),
                          hz: 3,
                          offset: const Offset(5, 0),
                          curve: Curves.easeInOut,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Audio visualizer
                    Container(
                      width: 300,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color:
                              viewModel.isActive ? energyColor : primaryColor,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: CustomPaint(
                          painter: AudioVisualizerPainter(
                            value: _visualizerValue,
                            isActive: viewModel.isActive,
                            color:
                                viewModel.isActive ? energyColor : primaryColor,
                          ),
                          child: Center(
                            child: Text(
                              viewModel.isActive ? "ACTIVE" : "READY",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Touch control button
                    GestureDetector(
                      onTapDown: (_) => _handlePressStart(),
                      onTapUp: (_) => _handlePressEnd(),
                      onTapCancel: () => _handlePressEnd(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              viewModel.isActive
                                  ? energyColor.withOpacity(0.2)
                                  : primaryColor.withOpacity(0.2),
                          border: Border.all(
                            color:
                                viewModel.isActive ? energyColor : primaryColor,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (viewModel.isActive
                                      ? energyColor
                                      : primaryColor)
                                  .withOpacity(0.5),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          viewModel.isActive
                              ? Icons.power_settings_new
                              : Icons.touch_app,
                          size: 50,
                          color:
                              viewModel.isActive ? energyColor : Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Return button, only shown when not active
                    AnimatedOpacity(
                      opacity: viewModel.isActive ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 300),
                      child: AnimatedTrollButton(
                        text: "Return to Menu",
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.of(context).pop(),
                        width: 200,
                        height: 50,
                        color: primaryColor,
                        elevated: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Particle for visual effects
class FlashParticle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  int lifespan;
  double opacity = 1.0;

  FlashParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.lifespan,
  });

  void update() {
    position += velocity;
    velocity *= 0.98; // Apply drag
    lifespan--;
    opacity = (lifespan / 60).clamp(0.0, 1.0); // Fade out
    size *= 0.98; // Shrink over time
  }
}

// Painter for particles
class ParticlesPainter extends CustomPainter {
  final List<FlashParticle> particles;

  ParticlesPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint =
          Paint()
            ..color = particle.color.withOpacity(particle.opacity)
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlesPainter oldDelegate) => true;
}

// Audio visualizer painter
class AudioVisualizerPainter extends CustomPainter {
  final double value;
  final bool isActive;
  final Color color;
  final Random random = Random();

  AudioVisualizerPainter({
    required this.value,
    required this.isActive,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int barCount = 30;
    final double barWidth = size.width / barCount;
    final paint = Paint()..color = color;

    for (int i = 0; i < barCount; i++) {
      // Generate a height based on value but with some randomness
      final double heightFactor = isActive ? 0.7 : 0.4;
      final double minHeight = isActive ? 0.1 : 0.05;

      final double barHeight =
          size.height *
          (minHeight +
              heightFactor * value * (0.5 + 0.5 * sin(i / 3 + (value * 10))));

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          i * barWidth,
          (size.height - barHeight) / 2,
          barWidth * 0.7,
          barHeight,
        ),
        Radius.circular(barWidth * 0.3),
      );

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant AudioVisualizerPainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.isActive != isActive ||
        oldDelegate.color != color;
  }
}

// Dynamic pattern painter
class DynamicPatternPainter extends CustomPainter {
  final bool isActive;
  final Color color;
  final double animationValue;

  DynamicPatternPainter({
    required this.isActive,
    required this.color,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    if (isActive) {
      // Active pattern - concentric circles
      final int circleCount = 12;
      final double maxRadius = size.width * 0.8;

      for (int i = 0; i < circleCount; i++) {
        final double progress = (i / circleCount) + (animationValue * 0.1);
        final double radius = progress * maxRadius;

        paint.color = color.withOpacity(0.7 - (progress * 0.5));

        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          radius,
          paint,
        );
      }
    } else {
      // Inactive pattern - grid
      const double spacing = 50;

      // Draw horizontal lines
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      }

      // Draw vertical lines
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DynamicPatternPainter oldDelegate) {
    return oldDelegate.isActive != isActive ||
        oldDelegate.color != color ||
        oldDelegate.animationValue != animationValue;
  }
}
