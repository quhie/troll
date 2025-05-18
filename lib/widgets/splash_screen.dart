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

// Simplified particle model for better performance
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

// Model for neon circle background effect (simplified)
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

// Optimized transition painter
class EnhancedTransitionPainter extends CustomPainter {
  final double progress;
  final List<InteractiveParticleModel> particles;
  
  EnhancedTransitionPainter({required this.progress, required this.particles});
  
  @override
  void paint(Canvas canvas, Size size) {
    // Simplified transition effect with fewer operations
    for (final particle in particles) {
      // Calculate position based on transition progress
      final direction = (particle.position - Offset(size.width/2, size.height/2)).normalize();
      final distance = size.width * progress * 2;
      final position = particle.position + direction * distance;
      
      // Simple fade out
      final opacity = max(0.0, 1.0 - progress);
      
      // Simple particle
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(position, particle.size, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant EnhancedTransitionPainter oldDelegate) => 
      oldDelegate.progress != progress;
}

// Simplified shine effect painter
class ShineEffectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Create a simple radial gradient for the shine
    final shineGradient = RadialGradient(
      colors: [
        Colors.white.withOpacity(0.9),
        Colors.white.withOpacity(0),
      ],
      stops: const [0.0, 1.0],
    );
    
    // Create a paint object with the gradient
    final shinePaint = Paint()
      ..shader = shineGradient.createShader(
        Rect.fromCircle(center: center, radius: radius)
      );
    
    // Draw simple shine effect
    canvas.drawCircle(center, radius, shinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Optimized effects painter
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
    
    // Draw neon circles (highly simplified)
    for (final circle in circles) {
      // Use simple stroke without glow effects
      final paint = Paint()
        ..color = circle.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawCircle(center, circle.radius, paint);
    }
    
    // Draw particles with minimal effects
    for (final particle in particles) {
      // Calculate final position
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

      // Draw the particle (no blur)
      final paint = Paint()
        ..color = particle.color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(finalPosition, particle.size, paint);
      
      // Only draw connections for nearby particles if they're close
      // This is a heavy operation so we limit it significantly
      if (Random().nextInt(5) == 0) {  // Only check 20% of particles for connections
        for (int i = 0; i < particles.length; i += 3) {  // Check every 3rd particle
          final otherParticle = particles[i];
          if (particle.id != otherParticle.id) {
            final distance = (finalPosition - otherParticle.position).distance;
            if (distance < 60) {  // Reduced connection distance
              final opacity = 1.0 - (distance / 60);
              final linePaint = Paint()
                ..color = particle.color.withOpacity(opacity * 0.2)
                ..strokeWidth = 0.5;  // Thinner lines
              
              canvas.drawLine(finalPosition, otherParticle.position, linePaint);
            }
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant InteractiveEffectsPainter oldDelegate) {
    // Only repaint when animation value changes significantly
    final newHashCode = animationValue.toStringAsFixed(2).hashCode;
    if (_lastHashCode != newHashCode || touchPosition != oldDelegate.touchPosition) {
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
  
  // 3D effect tracking (reduced effect)
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

    // Create particles with delayed initialization to avoid jank
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize particles and effects with much fewer elements
      _createParticles();
      _createNeonCircles();
    
      // Start animation after UI is rendered
      _controller.forward();
    });

    // Initialize music icon bounds (will be updated in build)
    _musicIconBounds = Rect.fromLTWH(0, 0, 160, 160);
    
    // Auto-navigate to next screen after 3 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && !_isDisposed && !_isTransitioning) {
        _transitionToNextScreen();
      }
    });
  }

  void _createParticles() {
    final random = Random();
    // Create interactive particles (significantly reduced for performance)
    for (int i = 0; i < 6; i++) {  // Reduced from 10 to 6
      _particles.add(
        InteractiveParticleModel(
          position: Offset(
            random.nextDouble() * 400 - 100,
            random.nextDouble() * 1200 - 400,
          ),
          speed: 0.2 + random.nextDouble() * 0.4,  // Reduced speed range
          size: 5.0 + random.nextDouble() * 5,      // Reduced size range
          color: [
                Colors.purple.withOpacity(0.5),
                Colors.blue.withOpacity(0.5),
              ][random.nextInt(2)],  // Fewer color options
          targetPosition: null,
          id: i,
        ),
      );
    }
  }

  void _createNeonCircles() {
    // Use just one neon circle for better performance
    _neonCircles.add(
      NeonCircleModel(
        radius: 180,
        color: Colors.blue.withOpacity(0.1),
        pulseSpeed: 1.5,
      ),
    );
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
      
      // Simplified music icon effect
      setState(() {
        _isMusicIconTapped = true;
        _touchPosition = Offset(
          _musicIconBounds.left + _musicIconBounds.width / 2,
          _musicIconBounds.top + _musicIconBounds.height / 2
        );
      });
      
      // Reset state after animation
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !_isDisposed) {
          setState(() {
            _isMusicIconTapped = false;
            _isProcessingIconTap = false;
          });
        }
      });
      
      return;
    }
    
    // Simplified tap interaction
    setState(() {
      _touchPosition = tapPosition;
    });
    
    // Reset touch position after delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && !_isDisposed) {
        setState(() {
          _touchPosition = null;
        });
      }
    });
  }
  
  void _handleDoubleTap() {
    if (_isTransitioning) return;
    _transitionToNextScreen();
  }
  
  void _handlePanUpdate(DragUpdateDetails details) {
    if (_isTransitioning) return;
    
    // Update touch position with reduced frequency
    if (Random().nextInt(3) == 0) {  // Only update on every ~3rd event
      setState(() {
        _touchPosition = details.localPosition;
        // Reduced 3D rotation effect
        _rotationX = (details.localPosition.dy / MediaQuery.of(context).size.height - 0.5) * 0.05;
        _rotationY = -(details.localPosition.dx / MediaQuery.of(context).size.width - 0.5) * 0.05;
      });
    }
  }
  
  void _handlePanEnd(DragEndDetails details) {
    if (_isTransitioning) return;
    
    // Reset touch position
    setState(() {
      _touchPosition = null;
      _rotationX = 0;
      _rotationY = 0;
    });
  }
  
  void _transitionToNextScreen() {
    if (_isTransitioning) return;
    
    setState(() {
      _isTransitioning = true;
    });
    
    // Add haptic feedback
    HapticFeedback.mediumImpact();
    
    // Simplified navigation with basic transition
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),  // Reduced from 1000ms
        pageBuilder: (context, animation, secondaryAnimation) =>
            widget.nextScreen ?? const EnterView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Simplified transition
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
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
    final iconCenterY = size.height / 2 - 40;
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
            ..setEntry(3, 2, 0.001)
            ..rotateX(_rotationX)
            ..rotateY(_rotationY),
          alignment: Alignment.center,
          child: Stack(
            children: [
              // Simplified gradient background (static, not animated)
              Container(
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF16213E) : const Color(0xFFD4E4FA),
                ),
              ),

              // Only use CustomPaint for animation when particles exist
              if (_particles.isNotEmpty)
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return RepaintBoundary(
                      child: CustomPaint(
                        size: Size(size.width, size.height),
                        painter: InteractiveEffectsPainter(
                          particles: _particles,
                          circles: _neonCircles,
                          animationValue: _controller.value,
                          touchPosition: _touchPosition,
                        ),
                      ),
                    );
                  },
                ),

              // Centered content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Simplified logo animation
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? Colors.blue.shade800 : Colors.blue.shade600,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 10,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.music_note,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // App name
                    Text(
                      AppConstants.appName.tr(),
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Outfit',
                        letterSpacing: 0.5,
                        color: isDark ? Colors.white : Colors.blue.shade800,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tagline
                    Text(
                      AppConstants.tagline.tr(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : Colors.black87,
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
                          isDark ? Colors.purple : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Simple touch ripple effect indicator
              if (_touchPosition != null)
                Positioned(
                  left: _touchPosition!.dx - 25,
                  top: _touchPosition!.dy - 25,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ).animate().fadeOut(
                    duration: 300.ms,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

