import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/constants.dart';
import '../screens/enter_view.dart';
import '../screens/app_container.dart';

// Extension method for Offset to add normalize functionality
extension OffsetExtension on Offset {
  Offset normalize() {
    final double dist = distance;
    if (dist <= 0) return Offset.zero;
    return this / dist;
  }
}

// Enhanced particle model for interaction
class InteractiveParticleModel {
  Offset position;
  double speed;
  double size;
  Color color;
  Offset? targetPosition;
  final int id;

  InteractiveParticleModel({
    required this.position,
    required this.speed,
    required this.size,
    required this.color,
    required this.targetPosition,
    required this.id,
  });
}

// Model for neon circle background effect
class NeonCircleModel {
  double radius;
  Color color;
  double pulseSpeed;

  NeonCircleModel({
    required this.radius,
    required this.color,
    required this.pulseSpeed,
  });
}

// Enhanced transition painter
class EnhancedTransitionPainter extends CustomPainter {
  final double progress;
  final List<InteractiveParticleModel> particles;
  
  EnhancedTransitionPainter({required this.progress, required this.particles});
  
  @override
  void paint(Canvas canvas, Size size) {
    // Make particles fly outward during transition
    for (final particle in particles) {
      // Calculate position based on transition progress
      final direction = (particle.position - Offset(size.width/2, size.height/2)).normalize();
      final distance = size.width * progress * 2;
      final position = particle.position + direction * distance;
      
      // Grow particles during transition
      final growFactor = 1.0 + progress * 8.0;
      
      // Fade out particles as they move
      final opacity = max(0.0, 1.0 - (progress * 1.5));
      
      // Create dynamic trail effect
      if (opacity > 0.2) {
        final trailPaint = Paint()
          ..color = particle.color.withOpacity(opacity * 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = particle.size * 0.5;
          
        // Calculate trail start position
        final trailStart = particle.position + direction * (distance * 0.7);
        
        // Draw trail line with gradient
        final gradient = ui.Gradient.linear(
          trailStart,
          position,
          [
            particle.color.withOpacity(0.1),
            particle.color.withOpacity(opacity * 0.5),
          ],
        );
        
        final gradientPaint = Paint()
          ..shader = gradient
          ..style = PaintingStyle.stroke
          ..strokeWidth = particle.size * (1.0 - progress * 0.5);
        
        canvas.drawLine(trailStart, position, gradientPaint);
      }
      
      // Draw flying particle with glow
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
      canvas.drawCircle(position, particle.size * growFactor, paint);
      
      // Add highlight dot in center for sparkle effect
      if (opacity > 0.4) {
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(opacity * 0.8)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(position, particle.size * 0.4, highlightPaint);
      }
    }
    
    // Draw light rays from center
    if (progress < 0.7) {
      final centerX = size.width / 2;
      final centerY = size.height / 2;
      final rayCount = 12;
      final maxLength = size.width * 0.8;
      final rayOpacity = max(0.0, 0.7 - progress);
      
      for (int i = 0; i < rayCount; i++) {
        final angle = 2 * pi * i / rayCount;
        final rayLength = maxLength * (0.3 + 0.7 * progress);
        final endX = centerX + cos(angle) * rayLength;
        final endY = centerY + sin(angle) * rayLength;
        
        final gradient = ui.Gradient.linear(
          Offset(centerX, centerY),
          Offset(endX, endY),
          [
            Colors.white.withOpacity(rayOpacity * 0.7),
            Colors.white.withOpacity(0),
          ],
        );
        
        final rayPaint = Paint()
          ..shader = gradient
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2 + (1 - progress) * 4;
        
        canvas.drawLine(
          Offset(centerX, centerY),
          Offset(endX, endY),
          rayPaint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant EnhancedTransitionPainter oldDelegate) => 
      oldDelegate.progress != progress;
}

// Shine effect painter for music icon
class ShineEffectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Create a radial gradient for the shine
    final shineGradient = RadialGradient(
      colors: [
        Colors.white.withOpacity(0.9),
        Colors.white.withOpacity(0.6),
        Colors.white.withOpacity(0.3),
        Colors.white.withOpacity(0),
      ],
      stops: const [0.0, 0.2, 0.5, 1.0],
    );
    
    // Create a paint object with the gradient
    final shinePaint = Paint()
      ..shader = shineGradient.createShader(
        Rect.fromCircle(center: center, radius: radius)
      )
      ..blendMode = BlendMode.screen;
    
    // Draw arcs for shine effect
    for (int i = 0; i < 4; i++) {
      final startAngle = pi/4 + (i * pi/2);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 1.2),
        startAngle,
        pi/6,
        true,
        shinePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Interactive effects painter
class InteractiveEffectsPainter extends CustomPainter {
  final List<InteractiveParticleModel> particles;
  final List<NeonCircleModel> circles;
  final double animationValue;
  final Offset? touchPosition;
  
  // Cache for optimization
  int _lastHashCode = 0;

  InteractiveEffectsPainter({
    required this.particles,
    required this.circles,
    required this.animationValue,
    this.touchPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw neon circles (simplified)
    for (final circle in circles) {
      // Calculate pulsing effect
      final pulseOffset = sin(animationValue * circle.pulseSpeed * pi * 2) * 15;
      final currentRadius = circle.radius + pulseOffset;

      // Simplified neon circle with less blur
      final paint = Paint()
        ..color = circle.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawCircle(center, currentRadius, paint);
    }
    
    // Draw particles with interaction
    for (final particle in particles) {
      // Calculate final position, considering user interaction
      Offset finalPosition;
      
      if (particle.targetPosition != null) {
        // If particle has a target (from interaction), move toward it
        final direction = particle.targetPosition! - particle.position;
        finalPosition = particle.position + direction * 0.1;
        particle.position = finalPosition;
      } else {
        // Normal animated flow
        finalPosition = Offset(
          particle.position.dx,
          (particle.position.dy + size.height * particle.speed * animationValue) % size.height
        );
      }
      
      // Add subtle movement if finger is nearby
      if (touchPosition != null) {
        final distance = (finalPosition - touchPosition!).distance;
        if (distance < 120) {
          // Move particles away from touch with a wave-like effect
          final repelStrength = 1.0 - (distance / 120);
          final direction = (finalPosition - touchPosition!).normalize();
          finalPosition = finalPosition + direction * repelStrength * 10;
        }
      }

      // Draw the particle
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);

      canvas.drawCircle(finalPosition, particle.size, paint);
      
      // Draw connecting lines between nearby particles for web effect
      for (final otherParticle in particles) {
        if (particle.id != otherParticle.id) {
          final distance = (finalPosition - otherParticle.position).distance;
          if (distance < 80) {
            final opacity = 1.0 - (distance / 80);
            final linePaint = Paint()
              ..color = particle.color.withOpacity(opacity * 0.3)
              ..strokeWidth = 1.0;
            
            canvas.drawLine(finalPosition, otherParticle.position, linePaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant InteractiveEffectsPainter oldDelegate) {
    // Force repaint if touch position changed
    if (touchPosition != oldDelegate.touchPosition) return true;
    
    // Only repaint when animation value changes significantly
    final newHashCode = animationValue.toStringAsFixed(1).hashCode;
    if (_lastHashCode != newHashCode) {
      _lastHashCode = newHashCode;
      return true;
    }
    return false;
  }
}

class SplashScreen extends StatefulWidget {
  final Widget? nextScreen;

  const SplashScreen({Key? key, this.nextScreen}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<InteractiveParticleModel> _particles = [];
  final List<NeonCircleModel> _neonCircles = [];
  bool _isDisposed = false;
  bool _isTransitioning = false;
  
  // Touch interaction
  Offset? _touchPosition;
  
  // Music icon animation state
  bool _isMusicIconTapped = false;
  bool _isProcessingIconTap = false;
  
  // Coordinates for music icon container
  late Rect _musicIconBounds;
  
  // 3D effect tracking
  double _rotationX = 0;
  double _rotationY = 0;

  @override
  void initState() {
    super.initState();
    
    // Ensure keyboard is hidden when splash screen appears
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // Initialize particles and effects for better performance
    _createParticles();
    _createNeonCircles();

    // Start animation
    _controller.forward();

    // Initialize music icon bounds (will be updated in build)
    _musicIconBounds = Rect.fromLTWH(0, 0, 160, 160);
    
    // Auto-navigate to next screen after 3 seconds
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted && !_isDisposed && !_isTransitioning) {
        _transitionToNextScreen();
      }
    });
  }

  void _createParticles() {
    final random = Random();
    // Create interactive particles (reduced count for better performance)
    for (int i = 0; i < 10; i++) {
      _particles.add(
        InteractiveParticleModel(
          position: Offset(
            random.nextDouble() * 400 - 100,
            random.nextDouble() * 1200 - 400,
          ),
          speed: 0.2 + random.nextDouble() * 0.6,
          size: 5.0 + random.nextDouble() * 8,
          color: [
                Colors.purple.withOpacity(0.6),
                Colors.blue.withOpacity(0.6),
                Colors.pink.withOpacity(0.6),
                Colors.cyan.withOpacity(0.4),
              ][random.nextInt(4)],
          targetPosition: null,
          id: i,
        ),
      );
    }
  }

  void _createNeonCircles() {
    final random = Random();
    // Use fewer neon circles for better performance
    for (int i = 0; i < 2; i++) {
      _neonCircles.add(
        NeonCircleModel(
          radius: 100 + random.nextDouble() * 300,
          color: [
            Colors.purple.withOpacity(0.1),
            Colors.blue.withOpacity(0.1),
            Colors.cyan.withOpacity(0.1),
            Colors.pink.withOpacity(0.1),
              ][random.nextInt(4)],
          pulseSpeed: 1 + random.nextDouble() * 2,
        ),
      );
    }
  }
  
  // Check if a tap is on the music icon
  bool _isTapOnMusicIcon(Offset position) {
    final center = Offset(
      _musicIconBounds.left + _musicIconBounds.width / 2,
      _musicIconBounds.top + _musicIconBounds.height / 2
    );
    return (position - center).distance <= _musicIconBounds.width / 2;
  }
  
  void _handleTap(TapDownDetails details) {
    if (_isTransitioning) return;
    
    final tapPosition = details.localPosition;
    
    // Check if tap is on music icon
    if (_isTapOnMusicIcon(tapPosition)) {
      if (_isProcessingIconTap) return; // Prevent rapid taps
      
      _isProcessingIconTap = true;
      
      // Add haptic feedback
      HapticFeedback.mediumImpact();
      
      // Trigger music icon special effect
      setState(() {
        _isMusicIconTapped = true;
        
        // Create a focused ripple at music icon center
        _touchPosition = Offset(
          _musicIconBounds.left + _musicIconBounds.width / 2,
          _musicIconBounds.top + _musicIconBounds.height / 2
        );
        
        // Emit particles in circular pattern from icon
        _emitParticlesFromIcon(8);
      });
      
      // Reset state after animation
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && !_isDisposed) {
          setState(() {
            _isMusicIconTapped = false;
            _isProcessingIconTap = false;
          });
        }
      });
      
      return;
    }
    
    // For other areas, use standard particle interaction
    setState(() {
      _touchPosition = tapPosition;
      // Make nearby particles move toward tap position
      for (var particle in _particles) {
        final distance = (particle.position - tapPosition).distance;
        if (distance < 150) {
          // Set a target position for the particle
          particle.targetPosition = tapPosition;
          // Reset target after delay to let particles return to normal flow
          Future.delayed(const Duration(milliseconds: 800), () {
            if (mounted && !_isDisposed) {
              particle.targetPosition = null;
            }
          });
        }
      }
    });
    
    // Add haptic feedback for better interaction
    HapticFeedback.lightImpact();
  }
  
  // Emit particles in a circular pattern from the music icon
  void _emitParticlesFromIcon(int count) {
    final center = Offset(
      _musicIconBounds.left + _musicIconBounds.width / 2,
      _musicIconBounds.top + _musicIconBounds.height / 2
    );
    
    // Create temporary particles for the effect
    for (int i = 0; i < count; i++) {
      final angle = 2 * pi * i / count;
      final direction = Offset(cos(angle), sin(angle));
      final startPos = center + direction * 40; // Start from icon edge
      
      // Add a temporary particle
      final particle = InteractiveParticleModel(
        position: startPos,
        speed: 0.2,
        size: 6 + Random().nextDouble() * 6,
        color: Colors.white.withOpacity(0.8),
        targetPosition: center + direction * 200, // Move outward
        id: 1000 + i, // Use IDs that won't conflict with regular particles
      );
      
      _particles.add(particle);
      
      // Remove the particle after animation
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted && !_isDisposed) {
          setState(() {
            _particles.removeWhere((p) => p.id == particle.id);
          });
        }
      });
    }
  }
  
  void _handleDoubleTap() {
    if (_isTransitioning) return;
    
    // Shortcut to next screen on double tap
    _transitionToNextScreen();
  }
  
  void _handlePanUpdate(DragUpdateDetails details) {
    if (_isTransitioning) return;
    
    // Update touch position for interactive effects
    setState(() {
      _touchPosition = details.localPosition;
      
      // Update 3D rotation effect based on drag
      _rotationX = (details.localPosition.dy / MediaQuery.of(context).size.height - 0.5) * 0.1;
      _rotationY = -(details.localPosition.dx / MediaQuery.of(context).size.width - 0.5) * 0.1;
      
      // Create a wave effect with particles
      for (var i = 0; i < _particles.length; i++) {
        final distance = (_particles[i].position - details.localPosition).distance;
        if (distance < 150) {
          // Push particles away from finger in a wave pattern
          final direction = (_particles[i].position - details.localPosition).normalize();
          _particles[i].targetPosition = _particles[i].position + direction * (150 - distance) * 0.5;
          
          // Reset target after short delay
          final particle = _particles[i];
          Future.delayed(Duration(milliseconds: 300 + i * 10), () {
            if (mounted && !_isDisposed) {
              particle.targetPosition = null;
            }
          });
        }
      }
    });
  }
  
  void _handlePanEnd(DragEndDetails details) {
    if (_isTransitioning) return;
    
    // Gradually reset 3D rotation
    setState(() {
      // Slowly return to normal position
      _rotationX = _rotationX * 0.5;
      _rotationY = _rotationY * 0.5;
    });
    
    // Reset completely after delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && !_isDisposed) {
        setState(() {
          _rotationX = 0;
          _rotationY = 0;
        });
      }
    });
  }
  
  void _transitionToNextScreen() {
    if (_isTransitioning) return;
    
    setState(() {
      _isTransitioning = true;
    });
    
    // Add haptic feedback
    HapticFeedback.mediumImpact();
    
    // Create spectacular transition effects
    _createTransitionEffects();
    
    // Navigate with enhanced transition
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 1000),
        pageBuilder: (context, animation, secondaryAnimation) =>
            widget.nextScreen ?? const EnterView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Combine multiple animations for spectacular effect
          final fadeAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuart,
          );
          
          final scaleAnimation = Tween(begin: 0.9, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ),
          );
          
          return Stack(
            children: [
              // Fancy particle explosion effect during transition
              AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Opacity(
                    opacity: 1.0 - fadeAnimation.value,
                    child: CustomPaint(
                      painter: EnhancedTransitionPainter(
                        progress: animation.value,
                        particles: _particles,
                      ),
                      size: MediaQuery.of(context).size,
                    ),
                  );
                },
              ),
              
              // Fade and scale the next screen for a dynamic entrance
              FadeTransition(
                opacity: fadeAnimation,
                child: ScaleTransition(
                  scale: scaleAnimation,
                  child: child,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Add method to create spectacular transition effects
  void _createTransitionEffects() {
    final size = MediaQuery.of(context).size;
    
    // Emit particles in waves - reduced particle count for better performance
    _emitTransitionParticles(100);
    
    // Add delayed waves for more dramatic effect
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted && !_isDisposed) {
        _emitTransitionParticles(50);
      }
    });
  }

  // Method to emit transition particles
  void _emitTransitionParticles(int count) {
    final size = MediaQuery.of(context).size;
    final random = Random();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final colors = [
      Colors.blue.withOpacity(0.8),
      Colors.purple.withOpacity(0.8),
      Colors.cyan.withOpacity(0.8),
      Colors.indigo.withOpacity(0.8),
      Colors.white.withOpacity(0.9),
    ];
    
    // Clear existing regular particles
    _particles.removeWhere((p) => p.id < 1000);
    
    // Create new burst particles
    for (int i = 0; i < count; i++) {
      // Create particles radiating from center
      final angle = random.nextDouble() * 2 * pi;
      final distance = random.nextDouble() * size.width * 0.5;
      
      final posX = size.width / 2 + cos(angle) * distance * random.nextDouble();
      final posY = size.height / 2 + sin(angle) * distance * random.nextDouble();
      final position = Offset(posX, posY);
      
      // Create direction for particle to fly out
      final direction = (position - Offset(size.width / 2, size.height / 2)).normalize();
      final targetPosition = position + direction * size.width * 2;
      
      // Randomize particle appearance
      final particleSize = 3 + random.nextDouble() * 10;
      final particleColor = colors[random.nextInt(colors.length)];
      
      _particles.add(
        InteractiveParticleModel(
          position: position,
          speed: 0.1 + random.nextDouble() * 0.4,
          size: particleSize,
          color: particleColor,
          targetPosition: targetPosition,
          id: 2000 + i,
        ),
      );
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Calculate position for music icon (centered)
    final iconCenterX = size.width / 2;
    final iconCenterY = size.height / 2 - 40; // Adjust based on your layout
    _musicIconBounds = Rect.fromCenter(
      center: Offset(iconCenterX, iconCenterY),
      width: 160,
      height: 160
    );

    return Scaffold(
      body: GestureDetector(
        onTapDown: _handleTap,
        onDoubleTap: _handleDoubleTap,
        onPanUpdate: _handlePanUpdate,
        onPanEnd: _handlePanEnd,
        child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateX(_rotationX)
            ..rotateY(_rotationY),
          alignment: Alignment.center,
          child: Stack(
        children: [
              // Gradient background (static, not animated)
          Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(-0.2, -0.3),
                radius: 1.5,
                colors:
                    isDark
                        ? [
                          const Color(0xFF1A1A2E),
                          const Color(0xFF16213E),
                          const Color(0xFF0F3460),
                          Colors.black,
                        ]
                        : [
                          const Color(0xFFE8F0FE),
                          const Color(0xFFD4E4FA),
                          const Color(0xFFBFD7F6),
                          const Color(0xFFAACAF2),
                        ],
              ),
            ),
          ),

              // Only use CustomPaint for animation when visible
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
                  // Only repaint on specific intervals for better performance
                  final animationValue = (_controller.value * 10).floor() / 10;
                  
              return CustomPaint(
                size: Size(size.width, size.height),
                    painter: InteractiveEffectsPainter(
                  particles: _particles,
                      circles: _neonCircles,
                      animationValue: animationValue,
                      touchPosition: _touchPosition,
                ),
              );
            },
          ),

              // Centered content with 3D parallax effect
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                    // Animated logo with 3D effect and enhanced tap feedback
                    Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.002) // stronger perspective for logo
                        ..rotateX(_rotationX * 2)
                        ..rotateY(_rotationY * 2),
                      alignment: Alignment.center,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutCubic,
                        width: _isMusicIconTapped ? 180 : 160,
                        height: _isMusicIconTapped ? 180 : 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              _isMusicIconTapped 
                                ? Colors.blue.shade300 
                                : (isDark ? Colors.blue : Colors.blue.shade600),
                              isDark ? Colors.blue.shade800 : Colors.blue.shade400,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _isMusicIconTapped 
                                    ? Colors.blue.withOpacity(0.8)
                                : Colors.blue.withOpacity(0.5),
                              blurRadius: _isMusicIconTapped ? 25 : 15,
                              spreadRadius: _isMusicIconTapped ? 8 : 5,
                            ),
                          ],
                        ),
                      child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                        child: Icon(
                              Icons.music_note,
                              size: _isMusicIconTapped ? 100 : 80,
                              color: Colors.white,
                            ).animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .rotate(
                              duration: 3000.ms,
                              begin: -0.05,
                              end: 0.05,
                              curve: Curves.easeInOut,
                            )
                            .then()
                            .rotate(
                              duration: 3000.ms,
                              begin: 0.05,
                              end: -0.05,
                              curve: Curves.easeInOut,
                            ),
                      ),
                        ),
                      ),
                    ).animate()
                    .shimmer(
                      duration: 2800.ms,
                      color: Colors.white.withOpacity(0.8),
                      size: _isMusicIconTapped ? 1.0 : 0.9,
                    ),

                const SizedBox(height: 40),

                    // App name with 3D effect
                    Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(_rotationX * 1.5)
                        ..rotateY(_rotationY * 1.5),
                      alignment: Alignment.center,
                      child: Animate(
                  effects: [
                    FadeEffect(
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                    ),
                    ScaleEffect(
                      begin: const Offset(0.7, 0.7),
                      end: const Offset(1.0, 1.0),
                      duration: const Duration(milliseconds: 800),
                      delay: const Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic,
                    ),
                  ],
                        child: Text(
                          AppConstants.appName.tr(),
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Outfit',
                      letterSpacing: 0.5,
                      color: isDark ? Colors.white : Colors.blue.shade800,
                            shadows: [
                              Shadow(
                                color: Colors.blue.withOpacity(0.5),
                                blurRadius: 5,
                                offset: const Offset(0, 1),
                              ),
                              Shadow(
                                color: Colors.purple.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                  ),
                ),

                const SizedBox(height: 16),

                // Animated tagline
                    Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(_rotationX)
                        ..rotateY(_rotationY),
                      alignment: Alignment.center,
                      child: Animate(
                  effects: [
                    FadeEffect(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 1200),
                      curve: Curves.easeOut,
                    ),
                  ],
                  child: Text(
                    AppConstants.tagline.tr(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black87,
                      letterSpacing: 0.2,
                    ),
                  ).animate().shimmer(
                    duration: 1800.ms,
                    color:
                        isDark
                                  ? Colors.purple.withOpacity(0.8)
                                  : Colors.blue.withOpacity(0.8),
                        ),
                  ),
                ),

                const SizedBox(height: 30),

                    // Simple loading indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? Colors.purple.withOpacity(0.9) : Colors.blue,
                        ),
            ),
          ),
        ],
      ),
              ),
              
              // Touch ripple effect indicator
              if (_touchPosition != null)
                Positioned(
                  left: _touchPosition!.dx - 50,
                  top: _touchPosition!.dy - 50,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isMusicIconTapped 
                        ? Colors.blue.withOpacity(0.2)
                        : Colors.white.withOpacity(0.1),
                    ),
                  ).animate(onComplete: (controller) {
                    // Reset touch position after animation
                    Future.delayed(const Duration(milliseconds: 300), () {
                      if (mounted && !_isDisposed) {
      setState(() {
                          _touchPosition = null;
                        });
                      }
                    });
                  }).scale(
                    duration: 300.ms,
                    begin: const Offset(0.2, 0.2),
                    end: const Offset(2.0, 2.0),
                  ).fadeOut(
                    duration: 300.ms,
                  ),
                ),
                
              // Show shine effect on icon when tapped
              if (_isMusicIconTapped)
                Positioned(
                  left: _musicIconBounds.left,
                  top: _musicIconBounds.top,
                  child: Container(
                    width: _musicIconBounds.width,
                    height: _musicIconBounds.height,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: CustomPaint(
                      painter: ShineEffectPainter(),
                      size: Size(_musicIconBounds.width, _musicIconBounds.height),
                    ),
                  ).animate()
                  .rotate(
                    duration: 700.ms,
                    begin: 0,
                    end: 0.15,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

