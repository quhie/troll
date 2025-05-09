import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../viewmodels/unclickable_button_viewmodel.dart';
import '../widgets/unclickable_button.dart';
import '../utils/app_theme.dart';
import '../utils/haptic_feedback_helper.dart';

class UnclickableButtonView extends StatelessWidget {
  const UnclickableButtonView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UnclickableButtonViewModel(),
      child: const _UnclickableButtonViewContent(),
    );
  }
}

class _UnclickableButtonViewContent extends StatefulWidget {
  const _UnclickableButtonViewContent({Key? key}) : super(key: key);

  @override
  State<_UnclickableButtonViewContent> createState() => _UnclickableButtonViewContentState();
}

class _UnclickableButtonViewContentState extends State<_UnclickableButtonViewContent> 
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _showConfetti = ValueNotifier<bool>(false);
  
  // Physics controller for bouncy effects
  late AnimationController _bouncyController;
  double _bouncyValue = 0.0;
  
  @override
  void initState() {
    super.initState();
    _bouncyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Use a separate ValueNotifier for the animation value to avoid setState in listener
    final ValueNotifier<double> bouncyValueNotifier = ValueNotifier<double>(0.0);
    _bouncyController.addListener(() {
      bouncyValueNotifier.value = _bouncyController.value;
      _bouncyValue = _bouncyController.value;
    });
    
    // Delayed animation
    Future.delayed(Duration(milliseconds: 300), () {
      if (mounted) _bouncyController.forward();
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _bouncyController.dispose();
    _showConfetti.dispose();
    super.dispose();
  }
  
  // Handle reset with animation
  void _handleReset(BuildContext context, UnclickableButtonViewModel viewModel) {
    HapticFeedbackHelper.mediumImpact();
    _bouncyController.reset();
    _bouncyController.forward();
    viewModel.reset();
    
    // Show a brief confetti burst
    _showConfetti.value = true;
    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted) _showConfetti.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<UnclickableButtonViewModel>(context);
    
    // Calculate difficulty level based on move count
    int difficultyLevel = (viewModel.moveCount / 3).floor().clamp(0, 5);
    
    // Difficulty color gradient from green to red
    final List<Color> difficultyColors = [
      Colors.green,
      Colors.lightGreen,
      Colors.yellow,
      Colors.orange,
      Colors.deepOrange,
      Colors.red,
    ];
    
    // Animation bounce effect
    final bounce = sin(_bouncyValue * pi * 3) * (1 - _bouncyValue) * 10;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent.withOpacity(0.1),
        elevation: 0,
        title: Text(
          'Unclickable Button',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ).animate(
          effects: [
            FadeEffect(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 200),
            ),
            SlideEffect(
              begin: const Offset(0, -0.2),
              end: const Offset(0, 0),
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            ),
          ],
        ),
        actions: [
          // Reset button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _handleReset(context, viewModel),
            tooltip: 'Reset Button',
          ).animate(
            effects: [
              FadeEffect(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 400),
              ),
              ScaleEffect(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryColor,
                  Color.lerp(AppTheme.primaryColor, Colors.black, 0.7)!,
                ],
              ),
            ),
          ),
          
          // Subtle background pattern
          Opacity(
            opacity: 0.05,
            child: CustomPaint(
              painter: BackgroundPatternPainter(
                difficulty: difficultyLevel,
              ),
              child: Container(),
            ),
          ),
          
          // Main content
          SafeArea(
            child: ScrollConfiguration(
              behavior: const BouncingScrollBehavior(),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                controller: _scrollController,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 20),
                          
                          // Title
                          RepaintBoundary(
                            child: Transform.translate(
                              offset: Offset(0, bounce),
                              child: Text(
                                'Try to click the button! 😈',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ).animate(
                                effects: [
                                  FadeEffect(
                                    duration: const Duration(milliseconds: 800),
                                    delay: const Duration(milliseconds: 300),
                                  ),
                                  ScaleEffect(
                                    begin: const Offset(0.8, 0.8),
                                    end: const Offset(1.0, 1.0),
                                    duration: const Duration(milliseconds: 800),
                                    delay: const Duration(milliseconds: 300),
                                    curve: Curves.elasticOut,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 20),
                          
                          // Subtitle
                          Text(
                            'It might be harder than you think...',
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            textAlign: TextAlign.center,
                          ).animate(
                            effects: [
                              FadeEffect(
                                duration: const Duration(milliseconds: 800),
                                delay: const Duration(milliseconds: 600),
                              ),
                              SlideEffect(
                                begin: const Offset(0, 0.5),
                                end: const Offset(0, 0),
                                duration: const Duration(milliseconds: 800),
                                delay: const Duration(milliseconds: 600),
                                curve: Curves.easeOut,
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // Difficulty indicator
                          if (viewModel.moveCount > 0)
                            RepaintBoundary(
                              child: Animate(
                                effects: [
                                  FadeEffect(
                                    duration: const Duration(milliseconds: 400),
                                  ),
                                  ScaleEffect(
                                    begin: const Offset(0.95, 0.95),
                                    end: const Offset(1.0, 1.0),
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOut,
                                  ),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: difficultyColors[difficultyLevel].withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      // Difficulty text
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Text(
                                            'Difficulty: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            ['Easy', 'Normal', 'Medium', 'Hard', 'Expert', 'Impossible'][difficultyLevel],
                                            style: TextStyle(
                                              color: difficultyColors[difficultyLevel],
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ).animate(
                                            autoPlay: true,
                                            onPlay: (controller) => controller.repeat(reverse: true),
                                            effects: [
                                              ScaleEffect(
                                                begin: const Offset(1.0, 1.0),
                                                end: const Offset(1.1, 1.1),
                                                duration: const Duration(milliseconds: 500),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 8),
                                      
                                      // Progress bar
                                      Stack(
                                        children: [
                                          // Background
                                          Container(
                                            width: 240,
                                            height: 8,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(4),
                                              color: Colors.grey.shade800,
                                            ),
                                          ),
                                          
                                          // Foreground (animated)
                                          AnimatedContainer(
                                            duration: const Duration(milliseconds: 500),
                                            curve: Curves.easeOut,
                                            width: 240 * ((difficultyLevel + 1) / 6),
                                            height: 8,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(4),
                                              gradient: LinearGradient(
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                                colors: [
                                                  difficultyColors[difficultyLevel].withOpacity(0.7),
                                                  difficultyColors[difficultyLevel],
                                                ],
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: difficultyColors[difficultyLevel].withOpacity(0.5),
                                                  blurRadius: 8,
                                                  spreadRadius: 1,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      
                                      const SizedBox(height: 8),
                                      
                                      // Attempts counter
                                      Text(
                                        'Attempts: ${viewModel.moveCount}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.8),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          
                          const SizedBox(height: 30),
                          
                          // Tips based on difficulty
                          if (difficultyLevel > 1)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 20),
                              decoration: BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white10,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.lightbulb,
                                    color: AppTheme.energyColor,
                                    size: 24,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    difficultyLevel < 3
                                        ? "The button's getting trickier! Try to anticipate its movement."
                                        : difficultyLevel < 5
                                            ? "Getting harder now! The button moves faster and farther."
                                            : "Almost impossible! The button might double-jump now!",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(0.8),
                                      fontStyle: FontStyle.italic,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ).animate(
                              effects: [
                                FadeEffect(
                                  duration: const Duration(milliseconds: 600),
                                ),
                                SlideEffect(
                                  begin: const Offset(0, 0.5),
                                  end: const Offset(0, 0),
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeOut,
                                ),
                              ],
                            ),

                          // Button area
                          Container(
                            height: constraints.maxWidth > 400 ? 480 : 400,
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Game area subtle border
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white10,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                // Unclickable button
                                const UnclickableButton(
                                  text: "Click Me!",
                                  useRandomSounds: true,
                                ),
                              ],
                            ),
                          ).animate(
                            effects: [
                              FadeEffect(
                                duration: const Duration(milliseconds: 800),
                                delay: const Duration(milliseconds: 400),
                              ),
                            ],
                          ),
                          
                          // Bottom space
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for background pattern
class BackgroundPatternPainter extends CustomPainter {
  final int difficulty;
  final Random random = Random(42); // Fixed seed for consistent pattern
  
  BackgroundPatternPainter({
    required this.difficulty,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final dotCount = 100 + (difficulty * 50);
    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    // Create a starry background with more stars at higher difficulty
    for (int i = 0; i < dotCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5;
      
      canvas.drawCircle(Offset(x, y), radius, dotPaint);
    }
    
    // Add some lines at higher difficulties
    if (difficulty > 2) {
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      
      for (int i = 0; i < 5 + difficulty; i++) {
        final startX = random.nextDouble() * size.width;
        final startY = random.nextDouble() * size.height;
        final endX = startX + (random.nextDouble() * 200) - 100;
        final endY = startY + (random.nextDouble() * 200) - 100;
        
        canvas.drawLine(
          Offset(startX, startY),
          Offset(endX, endY),
          linePaint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant BackgroundPatternPainter oldDelegate) => 
    oldDelegate.difficulty != difficulty;
}

// Custom scroll behavior
class BouncingScrollBehavior extends ScrollBehavior {
  const BouncingScrollBehavior();
  
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
  
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
} 