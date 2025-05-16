import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import '../widgets/animated_troll_button.dart';
import '../viewmodels/unclickable_button_viewmodel.dart';
import '../utils/app_theme.dart';
import '../widgets/unclickable_button.dart';
import '../utils/haptic_feedback_helper.dart';

class UnclickableButtonView extends StatefulWidget {
  const UnclickableButtonView({Key? key}) : super(key: key);

  @override
  State<UnclickableButtonView> createState() => _UnclickableButtonViewState();
}

class _UnclickableButtonViewState extends State<UnclickableButtonView>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 2),
  );
  int _attempts = 0;
  int _successes = 0;
  bool _showScore = false;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Show the score after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showScore = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  void _incrementAttempts() {
    setState(() {
      _attempts++;
    });
  }

  void _handleButtonCaught() {
    HapticFeedbackHelper.heavyImpact();
    _confettiController.play();

    setState(() {
      _successes++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UnclickableButtonViewModel(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              const Text(
                "Unclickable Button",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              if (_showScore)
                Animate(
                  effects: const [
                    SlideEffect(
                      begin: Offset(30, 0),
                      end: Offset(0, 0),
                      duration: Duration(milliseconds: 600),
                      curve: Curves.easeOutBack,
                    ),
                    FadeEffect(
                      begin: 0,
                      end: 1,
                      duration: Duration(milliseconds: 500),
                    ),
                  ],
                  child: Container(
                    margin: const EdgeInsets.only(left: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "Caught: $_successes",
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        body: Stack(
          children: [
            // Animated background
            AnimatedBuilder(
              animation: _backgroundController,
              builder: (context, child) {
                return CustomPaint(
                  painter: UnclickableBackgroundPainter(
                    animation: _backgroundController.value,
                    attempts: _attempts,
                  ),
                  size: Size.infinite,
                );
              },
            ),

            // Confetti animation
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                maxBlastForce: 10,
                minBlastForce: 5,
                emissionFrequency: 0.05,
                numberOfParticles: 30,
                gravity: 0.2,
                colors: const [
                  AppTheme.primaryColor,
                  AppTheme.secondaryColor,
                  AppTheme.accentColor,
                  Colors.yellow,
                  Colors.purple,
                  Colors.white,
                ],
              ),
            ),

            // Game area
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Challenge text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      _attempts == 0
                          ? "Can you catch the button?"
                          : _attempts < 5
                          ? "Keep trying, you can do it!"
                          : _attempts < 10
                          ? "Getting tired yet? It's just warming up..."
                          : _attempts < 15
                          ? "The button is learning your moves..."
                          : _attempts < 20
                          ? "Getting annoyed? That's the point! 😈"
                          : "You're persistent, I'll give you that!",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ).animate(
                      effects: [
                        FadeEffect(duration: const Duration(milliseconds: 500)),
                        ShimmerEffect(
                          duration: const Duration(milliseconds: 1500),
                          color: Colors.blueAccent.withOpacity(0.7),
                          delay: const Duration(milliseconds: 1000),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Attempts counter
                  if (_showScore)
                    Animate(
                      effects: const [
                        SlideEffect(
                          begin: Offset(0, 30),
                          end: Offset(0, 0),
                          duration: Duration(milliseconds: 600),
                          curve: Curves.easeOutBack,
                          delay: Duration(milliseconds: 200),
                        ),
                        FadeEffect(
                          begin: 0,
                          end: 1,
                          duration: Duration(milliseconds: 500),
                          delay: Duration(milliseconds: 200),
                        ),
                      ],
                      child: Text(
                        "Attempts: $_attempts",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                  // Game container
                  Expanded(
                    child: Consumer<UnclickableButtonViewModel>(
                      builder: (context, viewModel, child) {
                        return GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            _incrementAttempts();
                            // Reset button position when tapping empty space
                            if (_attempts % 3 == 0) {
                              viewModel.reset();
                            }
                          },
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Game hints based on attempts
                              if (_attempts >= 3 && _attempts < 8)
                                Positioned(
                                  right: 20,
                                  top: 20,
                                  child: _buildHint(
                                    "The button moves away from your cursor!",
                                    Icons.swipe,
                                  ),
                                ),
                              if (_attempts >= 10 && _attempts < 15)
                                Positioned(
                                  left: 20,
                                  bottom: 100,
                                  child: _buildHint(
                                    "Try to be sneaky and approach from different angles!",
                                    Icons.touch_app,
                                  ),
                                ),
                              if (_attempts >= 20)
                                Positioned(
                                  right: 20,
                                  bottom: 200,
                                  child: _buildHint(
                                    "It will get tired after many attempts...",
                                    Icons.timer,
                                  ),
                                ),

                              // The actual unclickable button
                              UnclickableButton(
                                onButtonCaught: _handleButtonCaught,
                                text: "Try to click me!",
                                useRandomSounds: true,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Bottom controls
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: AnimatedTrollButton(
                      text: "Return to Menu",
                      icon: Icons.arrow_back,
                      onTap: () => Navigator.of(context).pop(),
                      width: 200,
                      height: 50,
                      elevated: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHint(String text, IconData icon) {
    return Container(
      width: 180,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.accentColor, size: 20),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(reverse: true),
      effects: [
        FadeEffect(
          begin: 0.7,
          end: 1.0,
          duration: const Duration(milliseconds: 1000),
        ),
      ],
    );
  }
}

class UnclickableBackgroundPainter extends CustomPainter {
  final double animation;
  final int attempts;

  UnclickableBackgroundPainter({
    required this.animation,
    required this.attempts,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Base background gradient
    final Rect rect = Offset.zero & size;

    // Change background colors based on number of attempts
    final List<Color> gradientColors =
        attempts < 5
            ? [const Color(0xFF6A11CB), const Color(0xFF2575FC)]
            : attempts < 15
            ? [const Color(0xFFFF416C), const Color(0xFFFF4B2B)]
            : [const Color(0xFFFF0844), const Color(0xFFFFB199)];

    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradientColors,
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Add animated pattern based on attempts
    final patternPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    // Grid pattern that moves with animation
    final spacing = 40.0 - (attempts * 0.5).clamp(0, 20);
    final offset = animation * spacing;

    // Horizontal lines
    for (double y = -offset; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), patternPaint);
    }

    // Vertical lines
    for (double x = -offset; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), patternPaint);
    }

    // Add some circles for visual interest
    if (attempts > 10) {
      final Random random = Random(42);
      final circlePaint =
          Paint()
            ..color = Colors.white.withOpacity(0.05)
            ..style = PaintingStyle.fill;

      for (int i = 0; i < 20; i++) {
        final x = random.nextDouble() * size.width;
        final y = random.nextDouble() * size.height;
        final radius = 20 + random.nextDouble() * 60;

        // Make circles move based on animation
        final adjustedX = (x + (animation * 100)) % (size.width + 200) - 100;
        final adjustedY = (y + (animation * 50)) % (size.height + 200) - 100;

        canvas.drawCircle(Offset(adjustedX, adjustedY), radius, circlePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant UnclickableBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.attempts != attempts;
  }
}
