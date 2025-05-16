import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/physics.dart';
import 'package:provider/provider.dart';
import 'package:troll/utils/haptic_feedback_helper.dart';
import 'package:troll/viewmodels/unclickable_button_viewmodel.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:troll/utils/constants.dart';
import 'package:troll/models/sound_model.dart';
import 'package:troll/utils/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';

class UnclickableButton extends StatefulWidget {
  final VoidCallback? onButtonCaught;
  final String text;
  final bool useRandomSounds;

  const UnclickableButton({
    Key? key,
    this.onButtonCaught,
    required this.text,
    this.useRandomSounds = true,
  }) : super(key: key);

  @override
  State<UnclickableButton> createState() => _UnclickableButtonState();
}

class _UnclickableButtonState extends State<UnclickableButton>
    with TickerProviderStateMixin {
  // Animation controllers
  late final AnimationController _animController;
  late final Animation<double> _scaleAnimation;

  // Spring animation controller
  late AnimationController _springController;
  late SpringSimulation _springSimulation;
  double _springValue = 0;

  // Interaction states
  bool _isHovering = false;
  bool _isPressed = false;

  // Button catching logic
  int _attemptCount = 0;
  final int _maxAttempts = 8;
  bool _isCatchable = false;

  // For rotation and movement effects
  final _random = Random();
  double _rotation = 0;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  DateTime _lastSoundTime = DateTime.now();
  List<String> _soundEffects = [];
  int _currentSoundIndex = 0;

  // Visual effects
  final List<ButtonParticle> _particles = [];
  bool _showParticles = false;

  @override
  void initState() {
    super.initState();

    // Animation controller for scale
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.9,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_animController);

    // Spring physics controller
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _springController.addListener(_updateSpringAnimation);

    // Initialize sound effects
    _loadSoundEffects();

    // Update screen size once widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateScreenSize();
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _springController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _updateSpringAnimation() {
    if (mounted) {
      setState(() {
        _springValue = _springController.value;

        // Update particles if needed
        if (_showParticles) {
          _updateParticles();
        }
      });
    }
  }

  // Trigger spring animation with physics
  void _triggerSpringAnimation(double velocity) {
    final SpringDescription spring = SpringDescription(
      mass: 1.0,
      stiffness: 120.0,
      damping: 14.0,
    );

    _springSimulation = SpringSimulation(
      spring,
      _springController.value,
      1.0,
      velocity,
    );

    _springController.animateWith(_springSimulation);
  }

  // Load sound effects
  void _loadSoundEffects() {
    if (widget.useRandomSounds) {
      // Get random selection of sounds
      List<SoundModel> allSounds = Constants.getSoundsList();
      for (var i = 0; i < min(5, allSounds.length); i++) {
        int index = _random.nextInt(allSounds.length);
        _soundEffects.add(allSounds[index].soundPath);
      }
    } else {
      // Use default sound
      _soundEffects.add('sounds/fart/fart.mp3');
    }
  }

  // Play sound with debounce
  Future<void> _playSound() async {
    // Prevent sound spam with debounce
    final now = DateTime.now();
    if (now.difference(_lastSoundTime).inMilliseconds < 100) {
      return;
    }
    _lastSoundTime = now;

    try {
      // Select next sound
      String soundPath = _soundEffects[_currentSoundIndex];
      _currentSoundIndex = (_currentSoundIndex + 1) % _soundEffects.length;

      // Play sound
      Source source = AssetSource(soundPath);
      await _audioPlayer.play(source);
    } catch (e) {
      // Xử lý lỗi khi phát âm thanh
    }
  }

  // Create particles for visual effects
  void _createParticles() {
    final viewModel = context.read<UnclickableButtonViewModel>();

    // Create particles that fly away from the button
    for (int i = 0; i < 8; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 1.0 + _random.nextDouble() * 3.0;
      final size = 5.0 + _random.nextDouble() * 8.0;
      final lifespan = 50 + _random.nextInt(30);

      _particles.add(
        ButtonParticle(
          position: Offset(
            viewModel.position.dx + 75,
            viewModel.position.dy + 30,
          ),
          velocity: Offset(cos(angle) * speed, sin(angle) * speed),
          color: _getRandomColor(),
          size: size,
          lifespan: lifespan,
          shape: _random.nextInt(3),
        ),
      );
    }

    setState(() {
      _showParticles = true;
    });
  }

  // Get random color for particles
  Color _getRandomColor() {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      Colors.yellow,
      Colors.purple,
    ];
    return colors[_random.nextInt(colors.length)];
  }

  // Update particles
  void _updateParticles() {
    if (_particles.isEmpty) {
      setState(() {
        _showParticles = false;
      });
      return;
    }

    // Update existing particles
    for (var particle in _particles) {
      particle.update();
    }

    // Remove dead particles
    _particles.removeWhere((particle) => particle.lifespan <= 0);
  }

  // Update screen size
  void _updateScreenSize() {
    final screenSize = MediaQuery.of(context).size;
    context.read<UnclickableButtonViewModel>().updateScreenSize(screenSize);
  }

  // Play jump animation
  void _playJumpAnimation() {
    _animController.reset();
    _animController.forward();
    _rotation = (_random.nextDouble() - 0.5) * 0.1; // Small random rotation

    // Create particle effect
    _createParticles();

    // Trigger spring animation
    _springController.value = 0.0;
    _triggerSpringAnimation(10.0);

    // Play sound effect
    _playSound();

    // Increment attempt counter
    _attemptCount++;

    // Make button catchable after enough attempts
    if (_attemptCount >= _maxAttempts) {
      setState(() {
        _isCatchable = true;
      });
    }
  }

  // Handle button tap attempt
  void _handleTap() {
    HapticFeedbackHelper.lightImpact();

    // Check if button is catchable
    if (_isCatchable) {
      if (widget.onButtonCaught != null) {
        widget.onButtonCaught!();
        return;
      }
    }

    // Move button and play animation
    context.read<UnclickableButtonViewModel>().moveButton();
    _playJumpAnimation();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UnclickableButtonViewModel>();

    // Calculate difficulty level (0-5)
    final difficultyLevel = (viewModel.moveCount / 3).floor().clamp(0, 5);

    // Dynamic button colors based on difficulty
    final List<List<Color>> difficultyGradients = [
      [Colors.blue.shade400, Colors.blue.shade700], // Easy
      [Colors.indigo.shade400, Colors.purple.shade700], // Medium
      [Colors.purple.shade400, Colors.deepPurple.shade800], // Hard
      [Colors.deepPurple.shade400, Colors.red.shade900], // Expert
      [AppTheme.accentColor, Colors.red], // Impossible
      [Colors.purple, Colors.deepOrange.shade900], // Impossible
    ];

    // Get current gradient based on difficulty
    final currentGradient = difficultyGradients[difficultyLevel];

    // Dynamic animation duration - faster at higher difficulties
    final animDuration = Duration(
      milliseconds: max(100, 400 - (difficultyLevel * 50)),
    );

    return Stack(
      children: [
        // Particle effects layer
        if (_showParticles)
          CustomPaint(
            painter: ParticlePainter(_particles),
            size: Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
          ),

        // Button
        AnimatedPositioned(
          duration: animDuration,
          curve: Curves.easeOutBack,
          left: viewModel.position.dx,
          top: viewModel.position.dy,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovering = true),
            onExit: (_) => setState(() => _isHovering = false),
            child: GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: _handleTap,
              child: AnimatedRotation(
                turns: _rotation,
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                child: AnimatedScale(
                  scale: _isPressed ? 0.95 : (_isHovering ? 1.05 : 1.0),
                  duration: const Duration(milliseconds: 150),
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 150,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors:
                              _isCatchable
                                  ? [AppTheme.secondaryColor, Colors.purple]
                                  : (_isHovering
                                      ? [Colors.yellow, Colors.red]
                                      : currentGradient),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color:
                                _isCatchable
                                    ? Colors.purple.withOpacity(0.7)
                                    : (_isHovering
                                        ? Colors.yellow.withOpacity(0.5)
                                        : currentGradient[0].withOpacity(0.5)),
                            blurRadius: _isCatchable ? 15 : 10,
                            spreadRadius: _isCatchable ? 2 : 0,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Button highlight
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 20,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withOpacity(
                                      _isCatchable ? 0.7 : 0.5,
                                    ),
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

                          // Button text
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                widget.text,
                                style: TextStyle(
                                  color:
                                      _isCatchable
                                          ? Colors.white
                                          : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      offset: Offset(0, 2),
                                      blurRadius: 3,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ).animate(
                                onPlay:
                                    (controller) =>
                                        controller.repeat(reverse: true),
                                effects: [
                                  ShimmerEffect(
                                    duration: const Duration(
                                      milliseconds: 1500,
                                    ),
                                    color: Colors.white.withOpacity(0.8),
                                    delay: const Duration(milliseconds: 1000),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Ripple effect on press
                          if (_isPressed)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: Container(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ),

                          // Button pattern
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: CustomPaint(
                                painter: ButtonPatternPainter(
                                  difficultyLevel: difficultyLevel,
                                  isCatchable: _isCatchable,
                                ),
                              ),
                            ),
                          ),

                          // Catchable effect
                          if (_isCatchable)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: CustomPaint(
                                  painter: CatchablePainter(
                                    animation: _springValue,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Particle for visual effects
class ButtonParticle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  int lifespan;
  double rotation = 0.0;
  int shape; // 0 = circle, 1 = square, 2 = triangle

  ButtonParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.lifespan,
    this.shape = 0,
  });

  void update() {
    position += velocity;
    velocity += const Offset(0, 0.1); // Add gravity
    velocity *= 0.98; // Add drag
    lifespan--;
    size *= 0.98; // Shrink over time
    rotation += 0.05;
  }
}

// Painter for particle effects
class ParticlePainter extends CustomPainter {
  final List<ButtonParticle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint =
          Paint()
            ..color = particle.color.withOpacity(
              min(1.0, particle.lifespan / 30),
            )
            ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      canvas.rotate(particle.rotation);

      switch (particle.shape) {
        case 1: // Square
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: particle.size,
              height: particle.size,
            ),
            paint,
          );
          break;
        case 2: // Triangle
          final path = Path();
          final halfSize = particle.size / 2;
          path.moveTo(0, -halfSize);
          path.lineTo(halfSize, halfSize);
          path.lineTo(-halfSize, halfSize);
          path.close();
          canvas.drawPath(path, paint);
          break;
        default: // Circle
          canvas.drawCircle(Offset.zero, particle.size / 2, paint);
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}

// Special painter for catchable button state
class CatchablePainter extends CustomPainter {
  final double animation;

  CatchablePainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.white.withOpacity(0.7)
          ..strokeWidth = 2.0;

    // Animated circle patterns
    for (int i = 0; i < 3; i++) {
      final progress = (animation + (i * 0.3)) % 1.0;
      final radius = progress * size.width * 0.5;

      paint.color = Colors.white.withOpacity(1.0 - progress);
      canvas.drawCircle(Offset(size.width / 2, size.height / 2), radius, paint);
    }

    // Draw targeting crosshairs
    paint.color = Colors.white.withOpacity(0.7);
    paint.strokeWidth = 1.5;

    // Horizontal lines
    canvas.drawLine(
      Offset(size.width * 0.25, size.height / 2),
      Offset(size.width * 0.4, size.height / 2),
      paint,
    );
    canvas.drawLine(
      Offset(size.width * 0.6, size.height / 2),
      Offset(size.width * 0.75, size.height / 2),
      paint,
    );

    // Vertical lines
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.25),
      Offset(size.width / 2, size.height * 0.4),
      paint,
    );
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.6),
      Offset(size.width / 2, size.height * 0.75),
      paint,
    );

    // Center circle
    paint.strokeWidth = 1.0;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 8, paint);
  }

  @override
  bool shouldRepaint(covariant CatchablePainter oldDelegate) =>
      oldDelegate.animation != animation;
}

// Pattern painter for button background
class ButtonPatternPainter extends CustomPainter {
  final int difficultyLevel;
  final bool isCatchable;

  ButtonPatternPainter({
    required this.difficultyLevel,
    this.isCatchable = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final patternOpacity =
        isCatchable ? 0.25 : (0.1 + (difficultyLevel * 0.03));

    final patternCount = isCatchable ? 5 : (2 + difficultyLevel);

    final paint =
        Paint()
          ..color =
              isCatchable
                  ? Colors.white.withOpacity(patternOpacity)
                  : Colors.white.withOpacity(patternOpacity)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isCatchable ? 1.5 : 1.0;

    // Draw zigzag pattern based on difficulty
    final path = Path();
    final zigzagWidth = isCatchable ? 14.0 : 10.0;
    final zigzagHeight = isCatchable ? 5.0 : (3.0 + (difficultyLevel * 0.5));

    for (double y = 0; y < size.height; y += 10.0) {
      path.moveTo(0, y);

      for (double x = 0; x < size.width; x += zigzagWidth) {
        path.relativeLineTo(zigzagWidth / 2, zigzagHeight);
        path.relativeLineTo(zigzagWidth / 2, -zigzagHeight);
      }
    }

    canvas.drawPath(path, paint);

    // Add small dots
    final dotPaint =
        Paint()
          ..color =
              isCatchable
                  ? Colors.white.withOpacity(patternOpacity * 1.5)
                  : Colors.white.withOpacity(patternOpacity)
          ..style = PaintingStyle.fill;

    for (int i = 0; i < patternCount * 10; i++) {
      final dotX = (i * 8) % size.width;
      final dotY = ((i * 11) % size.height);

      canvas.drawCircle(Offset(dotX, dotY), isCatchable ? 1.5 : 1.0, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ButtonPatternPainter oldDelegate) =>
      oldDelegate.difficultyLevel != difficultyLevel ||
      oldDelegate.isCatchable != isCatchable;
}
