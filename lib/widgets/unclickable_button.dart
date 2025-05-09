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
  
  // Spring animation properties
  late AnimationController _springController;
  late SpringSimulation _springSimulation;
  double _springValue = 0;
  
  // Interaction states
  bool _isHovering = false;
  bool _isPressed = false;
  final _buttonKey = GlobalKey();
  
  // Track number of attempts
  int _attemptCount = 0;
  final int _maxAttempts = 10;
  
  // For rotation and movement effects
  final _random = Random();
  double _rotation = 0;
  
  // Audio player with debounce
  final AudioPlayer _audioPlayer = AudioPlayer();
  DateTime _lastSoundTime = DateTime.now();
  
  // List of sound effects to cycle through
  final List<String> _soundEffects = [];
  int _currentSoundIndex = 0;
  
  // Particles for visual effects
  final List<ButtonParticle> _particles = [];
  
  // ValueNotifiers for reactive properties
  final ValueNotifier<bool> _showParticles = ValueNotifier<bool>(false);
  final ValueNotifier<double> _buttonScale = ValueNotifier<double>(1.0);
  final ValueNotifier<double> _buttonEnergy = ValueNotifier<double>(0.0);
  final ValueNotifier<List<ButtonParticle>> _particlesNotifier = ValueNotifier<List<ButtonParticle>>([]);
  final ValueNotifier<List<TrailPoint>> _trailNotifier = ValueNotifier<List<TrailPoint>>([]);
  
  // Edge sensing data
  double _edgeProximity = 0.0;
  bool _isNearEdge = false;
  
  // Long press data
  DateTime? _pressStartTime;
  bool _isLongPress = false;
  Timer? _longPressTimer;
  bool _buttonIsCatchable = false;
  
  // Scroll physics
  final _scrollPhysics = const BouncingScrollPhysics();
  
  // Trail effect
  final List<TrailPoint> _trailPoints = [];
  final int _maxTrailPoints = 10;

  @override
  void initState() {
    super.initState();
    
    // Animation controller setup
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.9)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_animController);
    
    // Spring physics controller with proper initialization
    _springController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _springController.addListener(_updateSpringAnimation);
    
    // Initialize sound effects
    _initSoundEffects();
    
    // Preload sound effects
    _preloadSounds();
    
    // Update screen size when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final screenSize = MediaQuery.of(context).size;
        context.read<UnclickableButtonViewModel>().updateScreenSize(screenSize);
      }
    });
  }
  
  // Preload sound effects for better performance
  Future<void> _preloadSounds() async {
    for (var sound in _soundEffects.take(3)) { // Preload first 3 sounds
      await _audioPlayer.setSource(AssetSource(sound.replaceFirst('assets/', '')));
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _springController.dispose();
    _audioPlayer.dispose();
    _showParticles.dispose();
    _buttonScale.dispose();
    _buttonEnergy.dispose();
    _particlesNotifier.dispose();
    _trailNotifier.dispose();
    _longPressTimer?.cancel();
    super.dispose();
  }
  
  void _updateSpringAnimation() {
    if (mounted) {
      // Avoid setState here by using the ValueNotifier pattern
      _springValue = _springController.value;
      
      // Manually trigger rebuild for animation-related visuals only
      if (_buttonIsCatchable) {
        _particlesNotifier.value = List.from(_particles);
      }
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
      _springController.value,  // starting value
      1.0,                      // ending value 
      velocity,                 // starting velocity
    );
    
    _springController.animateWith(_springSimulation);
  }
  
  // Initialize sound effects
  void _initSoundEffects() {
    if (widget.useRandomSounds) {
      // Get sounds from Constants
      List<SoundModel> allSounds = Constants.getSoundsList();
      for (var sound in allSounds) {
        _soundEffects.add(sound.soundPath);
      }
    } else {
      // Default sound if not using random sounds
      _soundEffects.add('assets/sounds/fart/fart.mp3');
    }
  }
  
  // Get next sound effect to play with debounce
  String _getNextSoundEffect() {
    if (_soundEffects.isEmpty) {
      return 'assets/sounds/fart/fart.mp3';
    }
    
    if (widget.useRandomSounds) {
      // Choose a random sound effect
      return _soundEffects[_random.nextInt(_soundEffects.length)];
    } else {
      // Cycle through available sound effects
      String sound = _soundEffects[_currentSoundIndex];
      _currentSoundIndex = (_currentSoundIndex + 1) % _soundEffects.length;
      return sound;
    }
  }
  
  // Play sound effect with debounce
  Future<void> _playSound() async {
    // Prevent sound spam with debounce
    final now = DateTime.now();
    if (now.difference(_lastSoundTime).inMilliseconds < 100) {
      return;
    }
    _lastSoundTime = now;
    
    try {
      String soundEffect = _getNextSoundEffect();
      Source source = AssetSource(soundEffect.replaceFirst('assets/', ''));
      await _audioPlayer.play(source);
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }
  
  // Create particles for visual effects
  void _createParticles() {
    final viewModel = context.read<UnclickableButtonViewModel>();
    
    // Create particles that fly away from the button
    for (int i = 0; i < 12; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 1.0 + _random.nextDouble() * 3.0;
      final size = 5.0 + _random.nextDouble() * 12.0;
      
      _particles.add(ButtonParticle(
        position: Offset(
          viewModel.position.dx + 75, // Center X
          viewModel.position.dy + 30, // Center Y
        ),
        velocity: Offset(
          cos(angle) * speed,
          sin(angle) * speed,
        ),
        color: _getRandomColor(),
        size: size,
        lifespan: 80,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.2,
        shape: _random.nextInt(3),
      ));
    }
    
    _showParticles.value = true;
    _particlesNotifier.value = List.from(_particles);
  }
  
  // Add trail point
  void _addTrailPoint(Offset position) {
    if (_trailPoints.length >= _maxTrailPoints) {
      _trailPoints.removeAt(0);
    }
    
    _trailPoints.add(TrailPoint(
      position: position,
      color: _getRandomColor().withOpacity(0.7),
      size: 8.0 + (_random.nextDouble() * 5.0),
    ));
    
    _trailNotifier.value = List.from(_trailPoints);
  }
  
  // Get random color for particles
  Color _getRandomColor() {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      AppTheme.highlightColor,
      AppTheme.energyColor,
    ];
    return colors[_random.nextInt(colors.length)];
  }
  
  // Update particles - more efficient with custom Ticker
  void _updateParticles() {
    if (_particles.isEmpty && _trailPoints.isEmpty) return;
    
    // Update existing particles
    for (var particle in _particles) {
      particle.update();
    }
    
    // Remove dead particles
    _particles.removeWhere((particle) => particle.lifespan <= 0);
    
    // Update trail points
    for (var point in _trailPoints) {
      point.update();
    }
    
    // Remove faded trail points
    _trailPoints.removeWhere((point) => point.opacity <= 0.01);
    
    if (_particles.isEmpty) {
      _showParticles.value = false;
    }
    
    // Optimize notification by only updating when there are actual changes
    if (_particles.isNotEmpty || _trailPoints.isNotEmpty) {
      _particlesNotifier.value = List.from(_particles);
      _trailNotifier.value = List.from(_trailPoints);
    }
  }
  
  // Check if button is near the edge of the screen
  void _checkEdgeProximity(Offset position) {
    final screenSize = MediaQuery.of(context).size;
    final buttonWidth = 150.0;
    final buttonHeight = 60.0;
    final edgeThreshold = 50.0;
    
    double leftDistance = position.dx;
    double rightDistance = screenSize.width - (position.dx + buttonWidth);
    double topDistance = position.dy;
    double bottomDistance = screenSize.height - (position.dy + buttonHeight);
    
    // Get minimum distance to any edge
    double minDistance = min(
      min(leftDistance, rightDistance),
      min(topDistance, bottomDistance)
    );
    
    // Scale proximity between 0 and 1, where 1 means right at the edge
    _edgeProximity = max(0.0, 1.0 - (minDistance / edgeThreshold));
    _isNearEdge = _edgeProximity > 0.5;
    
    // If very close to edge, add some reactive animation
    if (_isNearEdge && !_isLongPress) {
      _animController.reset();
      _animController.forward();
      HapticFeedbackHelper.lightImpact();
    }
  }
  
  // Handle long press detection
  void _startLongPressDetection() {
    _pressStartTime = DateTime.now();
    _longPressTimer = Timer(const Duration(milliseconds: 800), () {
      if (mounted && _isPressed) {
        setState(() {
          _isLongPress = true;
          _buttonIsCatchable = _attemptCount > _maxAttempts ~/ 2;
        });
        HapticFeedbackHelper.heavyImpact();
        
        // Create special long-press particle effect
        _createLongPressEffect();
      }
    });
  }

  void _cancelLongPressDetection() {
    _longPressTimer?.cancel();
    _longPressTimer = null;
    _pressStartTime = null;
    
    if (_isLongPress) {
      setState(() {
        _isLongPress = false;
      });
    }
  }
  
  // Create special particles for long press
  void _createLongPressEffect() {
    final viewModel = context.read<UnclickableButtonViewModel>();
    
    // Create more intense particles for long press
    for (int i = 0; i < 20; i++) {
      final angle = _random.nextDouble() * 2 * pi;
      final speed = 0.5 + _random.nextDouble() * 2.0;
      final size = 8.0 + _random.nextDouble() * 15.0;
      
      _particles.add(ButtonParticle(
        position: Offset(
          viewModel.position.dx + 75, // Center X
          viewModel.position.dy + 30, // Center Y
        ),
        velocity: Offset(
          cos(angle) * speed,
          sin(angle) * speed,
        ),
        color: _buttonIsCatchable ? AppTheme.energyColor : AppTheme.highlightColor,
        size: size,
        lifespan: 120,
        rotationSpeed: (_random.nextDouble() - 0.5) * 0.3,
        shape: _random.nextInt(3),
      ));
    }
    
    _showParticles.value = true;
    _particlesNotifier.value = List.from(_particles);
  }
  
  // Play jump animation
  void _playJumpAnimation() {
    _animController.reset();
    _animController.forward();
    _rotation = (_random.nextDouble() - 0.5) * 0.1; // Small random rotation
    
    // Create particle effect
    _createParticles();
    
    // Add to trail
    final viewModel = context.read<UnclickableButtonViewModel>();
    _addTrailPoint(Offset(
      viewModel.position.dx + 75, 
      viewModel.position.dy + 30,
    ));
    
    // Trigger spring animation
    _springController.value = 0.0;
    _triggerSpringAnimation(10.0);
    
    // Increase button energy for visual effects
    _buttonEnergy.value = min(1.0, _buttonEnergy.value + 0.2);
    
    // Play sound effect when button moves
    _playSound();
    
    // Increment attempt counter
    _attemptCount++;
    _buttonScale.value = 1.0 + (_attemptCount * 0.03).clamp(0.0, 0.3);
    
    // After max attempts, make it catchable
    if (_attemptCount >= _maxAttempts) {
      Future.delayed(Duration(seconds: 1), () {
        if (mounted && widget.onButtonCaught != null) {
          widget.onButtonCaught!();
        }
      });
    }
  }

  // Handle button tap attempt
  void _handleTap() {
    HapticFeedbackHelper.lightImpact();
    
    // Check if button is catchable after a long press
    if (_isLongPress && _buttonIsCatchable) {
      if (widget.onButtonCaught != null) {
        widget.onButtonCaught!();
      }
      return;
    }
    
    context.read<UnclickableButtonViewModel>().moveButton();
    _playJumpAnimation();
  }

  // Handle hover effect
  void _handleHoverChange(bool isHovering) {
    if (isHovering && !_isHovering) {
      HapticFeedbackHelper.selectionClick();
      context.read<UnclickableButtonViewModel>().moveButton();
      _playJumpAnimation();
    }
    
    if (mounted) {
      setState(() {
        _isHovering = isHovering;
      });
    }
  }
  
  // Handle press down
  void _handlePressDown(TapDownDetails details) {
    if (mounted) {
      setState(() {
        _isPressed = true;
      });
      HapticFeedbackHelper.mediumImpact();
      _startLongPressDetection();
    }
  }
  
  // Handle press cancel
  void _handlePressCancel() {
    if (mounted) {
      setState(() {
        _isPressed = false;
      });
      _cancelLongPressDetection();
    }
  }

  // Animation layout with RepaintBoundary for better performance
  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UnclickableButtonViewModel>();
    
    // Schedule particle updates using a more efficient ticker
    if (_particles.isNotEmpty || _trailPoints.isNotEmpty) {
      // Use the animation ticker instead of post-frame callback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _updateParticles();
        }
      });
    }
    
    // Check edge proximity
    _checkEdgeProximity(viewModel.position);
    
    // Calculate difficulty level for visual effects (0-5)
    final difficultyLevel = (viewModel.moveCount / 3).floor().clamp(0, 5);
    
    // Dynamic button colors based on difficulty
    final List<List<Color>> difficultyGradients = [
      [Colors.blue.shade400, Colors.blue.shade700], // Easy
      [Colors.blue.shade500, Colors.indigo.shade700], // Normal
      [Colors.indigo.shade400, Colors.purple.shade700], // Medium
      [Colors.purple.shade400, Colors.deepPurple.shade800], // Hard
      [Colors.deepPurple.shade400, Colors.red.shade800], // Expert
      [AppTheme.errorColor, Colors.deepOrange.shade900], // Impossible
    ];
    
    // Get current gradient based on difficulty
    final currentGradient = difficultyGradients[difficultyLevel];
    
    // Dynamic animation duration - faster at higher difficulties
    final animDuration = Duration(
      milliseconds: max(100, 400 - (difficultyLevel * 50)),
    );
    
    return RepaintBoundary(
      child: Stack(
        children: [
          // Trail effect
          ValueListenableBuilder<List<TrailPoint>>(
            valueListenable: _trailNotifier,
            builder: (context, trailPoints, _) {
              return trailPoints.isNotEmpty
                ? CustomPaint(
                    painter: TrailPainter(trailPoints),
                    size: Size(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height,
                    ),
                  )
                : const SizedBox.shrink();
            },
          ),
          
          // Particle effects layer
          ValueListenableBuilder<List<ButtonParticle>>(
            valueListenable: _particlesNotifier,
            builder: (context, particles, _) {
              return particles.isNotEmpty
                ? CustomPaint(
                    painter: ParticlePainter(particles),
                    size: Size(
                      MediaQuery.of(context).size.width,
                      MediaQuery.of(context).size.height,
                    ),
                  )
                : const SizedBox.shrink();
            },
          ),
          
          // Button
          AnimatedPositioned(
            duration: animDuration,
            curve: _isNearEdge ? Curves.easeOutBack : Curves.elasticOut,
            left: viewModel.position.dx,
            top: viewModel.position.dy,
            child: MouseRegion(
              onEnter: (_) => _handleHoverChange(true),
              onExit: (_) => _handleHoverChange(false),
              child: GestureDetector(
                onTapDown: _handlePressDown,
                onTapUp: (_) => _handlePressCancel(),
                onTapCancel: _handlePressCancel,
                onTap: _handleTap,
                child: AnimatedRotation(
                  turns: _rotation,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.elasticOut,
                  child: AnimatedScale(
                    scale: _isLongPress 
                        ? (_buttonIsCatchable ? 1.15 : 0.92)
                        : (_isPressed ? 0.95 : (_isHovering ? 1.05 : 1.0)),
                    duration: const Duration(milliseconds: 150),
                    child: ValueListenableBuilder<double>(
                      valueListenable: _buttonScale,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              key: _buttonKey,
                              width: 150,
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _isLongPress && _buttonIsCatchable
                                      ? [AppTheme.energyColor, AppTheme.secondaryColor]
                                      : (_isHovering 
                                          ? [AppTheme.highlightColor, AppTheme.errorColor]
                                          : currentGradient),
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: _isLongPress && _buttonIsCatchable
                                        ? AppTheme.energyColor.withOpacity(0.7)
                                        : (_isHovering 
                                            ? AppTheme.highlightColor.withOpacity(0.5)
                                            : currentGradient[0].withOpacity(0.5)),
                                    blurRadius: _isLongPress ? 20 : 15,
                                    spreadRadius: _isLongPress 
                                        ? (_buttonIsCatchable ? 5 : 1)
                                        : (_isHovering ? 2 : 0),
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Edge warning glow
                                  if (_isNearEdge && !_isLongPress)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(30),
                                          border: Border.all(
                                            color: AppTheme.errorColor.withOpacity(_edgeProximity),
                                            width: 3,
                                          ),
                                        ),
                                      ).animate(
                                        onPlay: (controller) => controller.repeat(reverse: true),
                                        effects: [
                                          FadeEffect(
                                            begin: 0.7,
                                            end: 1.0,
                                            duration: const Duration(milliseconds: 600),
                                            curve: Curves.easeInOut,
                                          ),
                                        ],
                                      ),
                                    ),
                                
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
                                            Colors.white.withOpacity(_isLongPress ? 0.7 : 0.5),
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
                                  
                                  // Long press indicator
                                  if (_isLongPress)
                                    Positioned.fill(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(30),
                                        child: _buttonIsCatchable
                                            ? CustomPaint(
                                                painter: CatchablePainter(
                                                  animation: _springValue,
                                                ),
                                              )
                                            : Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.white.withOpacity(0.5),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                  
                                  // Button text
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        widget.text,
                                        style: TextStyle(
                                          color: _isLongPress && _buttonIsCatchable 
                                              ? Colors.black
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
                                        onPlay: (controller) => controller.repeat(reverse: true),
                                        effects: [
                                          ShimmerEffect(
                                            duration: const Duration(milliseconds: 1500),
                                            color: _isLongPress && _buttonIsCatchable 
                                                ? Colors.black.withOpacity(0.7)
                                                : Colors.white.withOpacity(0.8),
                                            delay: const Duration(milliseconds: 1000),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  // Ripple effect on press
                                  if (_isPressed && !_isLongPress)
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
                                          isLongPress: _isLongPress,
                                          isCatchable: _buttonIsCatchable,
                                        ),
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Trail point for button movement trail
class TrailPoint {
  Offset position;
  Color color;
  double size;
  double opacity = 1.0;
  
  TrailPoint({
    required this.position,
    required this.color,
    required this.size,
  });
  
  void update() {
    opacity *= 0.92; // Fade out
    size *= 0.95; // Shrink
  }
}

// Painter for trail effects
class TrailPainter extends CustomPainter {
  final List<TrailPoint> trailPoints;
  
  TrailPainter(this.trailPoints);
  
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < trailPoints.length; i++) {
      final point = trailPoints[i];
      final paint = Paint()
        ..color = point.color.withOpacity(point.opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
      canvas.drawCircle(
        point.position,
        point.size,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant TrailPainter oldDelegate) => true;
}

// Particle for visual effects
class ButtonParticle {
  Offset position;
  Offset velocity;
  Color color;
  double size;
  int lifespan;
  double rotation = 0.0;
  double rotationSpeed;
  int shape; // 0 = circle, 1 = square, 2 = triangle
  
  ButtonParticle({
    required this.position,
    required this.velocity,
    required this.color,
    required this.size,
    required this.lifespan,
    this.rotationSpeed = 0.0,
    this.shape = 0,
  });
  
  void update() {
    position += velocity;
    velocity += const Offset(0, 0.1); // Add gravity
    velocity *= 0.98; // Add drag
    lifespan--;
    size *= 0.97; // Shrink over time
    rotation += rotationSpeed;
  }
}

// Painter for particle effects
class ParticlePainter extends CustomPainter {
  final List<ButtonParticle> particles;
  
  ParticlePainter(this.particles);
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(min(1.0, particle.lifespan / 30))
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
          canvas.drawCircle(
            Offset.zero,
            particle.size / 2,
            paint,
          );
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
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black.withOpacity(0.5)
      ..strokeWidth = 2.0;
    
    // Animated circle patterns
    for (int i = 0; i < 3; i++) {
      final progress = (animation + (i * 0.3)) % 1.0;
      final radius = progress * size.width * 0.5;
      
      paint.color = AppTheme.energyColor.withOpacity(1.0 - progress);
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        radius,
        paint,
      );
    }
    
    // Draw targeting crosshairs
    paint.color = Colors.black.withOpacity(0.7);
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
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      10,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CatchablePainter oldDelegate) => 
    oldDelegate.animation != animation;
}

// Pattern painter for button background
class ButtonPatternPainter extends CustomPainter {
  final int difficultyLevel;
  final bool isLongPress;
  final bool isCatchable;
  
  ButtonPatternPainter({
    required this.difficultyLevel, 
    this.isLongPress = false,
    this.isCatchable = false,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final patternOpacity = isLongPress 
        ? (isCatchable ? 0.3 : 0.15)
        : (0.1 + (difficultyLevel * 0.03));
    
    final patternCount = isLongPress
        ? (isCatchable ? 6 : 3)
        : (2 + difficultyLevel);
    
    final paint = Paint()
      ..color = isLongPress && isCatchable
          ? Colors.black.withOpacity(patternOpacity)
          : Colors.white.withOpacity(patternOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isLongPress && isCatchable ? 1.5 : 1.0;
    
    // Draw zigzag pattern based on difficulty
    final path = Path();
    final zigzagWidth = isLongPress && isCatchable ? 14.0 : 10.0;
    final zigzagHeight = isLongPress 
        ? (isCatchable ? 6.0 : 2.0)
        : (3.0 + (difficultyLevel * 0.5));
    
    for (double y = 0; y < size.height; y += 10.0) {
      path.moveTo(0, y);
      
      for (double x = 0; x < size.width; x += zigzagWidth) {
        path.relativeLineTo(zigzagWidth / 2, zigzagHeight);
        path.relativeLineTo(zigzagWidth / 2, -zigzagHeight);
      }
    }
    
    canvas.drawPath(path, paint);
    
    // Add small dots
    final dotPaint = Paint()
      ..color = isLongPress && isCatchable
          ? Colors.black.withOpacity(patternOpacity * 1.5)
          : Colors.white.withOpacity(patternOpacity)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < patternCount * 10; i++) {
      final dotX = (i * 8) % size.width;
      final dotY = ((i * 11) % size.height);
      
      canvas.drawCircle(
        Offset(dotX, dotY),
        isLongPress && isCatchable ? 2.0 : 1.0,
        dotPaint,
      );
    }
    
    // Add special pattern for catchable button
    if (isLongPress && isCatchable) {
      final targetPaint = Paint()
        ..color = Colors.black.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      
      // Draw concentric circles
      for (int i = 1; i <= 3; i++) {
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          i * 12.0,
          targetPaint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant ButtonPatternPainter oldDelegate) => 
    oldDelegate.difficultyLevel != difficultyLevel ||
    oldDelegate.isLongPress != isLongPress ||
    oldDelegate.isCatchable != isCatchable;
}