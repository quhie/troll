import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:troll/utils/app_theme.dart';
import 'package:troll/utils/constants.dart';
import 'package:troll/views/enter_view.dart';
import 'package:troll/utils/haptic_feedback_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<TrollParticle> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    // Create particles
    _createParticles();
    
    // Start animation
    _controller.forward();
    
    // Add haptic feedback
    _addHapticFeedback();
    
    // Navigate to enter view after splash animation completes
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (context, animation, secondaryAnimation) => const EnterView(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    });
  }

  void _createParticles() {
    // Create random particles for the splash animation
    for (int i = 0; i < 30; i++) {
      _particles.add(TrollParticle(
        position: Offset(
          _random.nextDouble() * 1.2 - 0.1, // -0.1 to 1.1 normalized position
          _random.nextDouble() * 1.2 - 0.1,
        ),
        color: _getRandomColor(),
        size: 5 + _random.nextDouble() * 15,
        speed: 0.2 + _random.nextDouble() * 0.6,
        angle: _random.nextDouble() * 2 * pi,
      ));
    }
  }

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

  // Add haptic feedback with delayed patterns
  void _addHapticFeedback() {
    Future.delayed(const Duration(milliseconds: 300), () {
      HapticFeedbackHelper.lightImpact();
      
      Future.delayed(const Duration(milliseconds: 600), () {
        HapticFeedbackHelper.mediumImpact();
        
        Future.delayed(const Duration(milliseconds: 800), () {
          HapticFeedbackHelper.heavyImpact();
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryColor,
                  AppTheme.primaryColor.withOpacity(0.7),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated particles background
                RepaintBoundary(
                  child: CustomPaint(
                    painter: ParticlePainter(_particles, _controller.value),
                    size: Size(constraints.maxWidth, constraints.maxHeight),
                  ),
                ),
                
                // Logo/title
                Center(
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Animated icon
                        RepaintBoundary(
                          child: Animate(
                            controller: _controller,
                            effects: [
                              ScaleEffect(
                                begin: const Offset(0.0, 0.0),
                                end: const Offset(1.0, 1.0),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.elasticOut,
                              ),
                              RotateEffect(
                                begin: -0.1,
                                end: 0.0,
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOutBack,
                              ),
                            ],
                            child: Icon(
                              Icons.celebration,
                              size: 100,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // App title
                        RepaintBoundary(
                          child: Animate(
                            controller: _controller,
                            effects: [
                              FadeEffect(
                                begin: 0.0,
                                end: 1.0,
                                delay: const Duration(milliseconds: 400),
                                duration: const Duration(milliseconds: 600),
                              ),
                              SlideEffect(
                                begin: const Offset(0.0, 0.2),
                                end: const Offset(0.0, 0.0),
                                delay: const Duration(milliseconds: 400),
                                duration: const Duration(milliseconds: 600),
                                curve: Curves.easeOutCubic,
                              ),
                            ],
                            child: Text(
                              Constants.appName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 45,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black45,
                                    offset: Offset(0, 3),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Loading spinner
                        RepaintBoundary(
                          child: Animate(
                            controller: _controller,
                            effects: [
                              FadeEffect(
                                begin: 0.0,
                                end: 1.0,
                                delay: const Duration(milliseconds: 800),
                                duration: const Duration(milliseconds: 400),
                              ),
                            ],
                            child: SpinKitPulse(
                              color: Colors.white.withOpacity(0.7),
                              size: 50.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Particle for the splash screen animation
class TrollParticle {
  Offset position; // Normalized position (0.0 to 1.0)
  Color color;
  double size;
  double speed;
  double angle;
  
  TrollParticle({
    required this.position,
    required this.color,
    required this.size,
    required this.speed,
    required this.angle,
  });
  
  void update(double delta) {
    // Move the particle
    position += Offset(
      cos(angle) * speed * delta,
      sin(angle) * speed * delta,
    );
    
    // Wrap around the screen
    if (position.dx < -0.1) position = Offset(1.1, position.dy);
    if (position.dx > 1.1) position = Offset(-0.1, position.dy);
    if (position.dy < -0.1) position = Offset(position.dx, 1.1);
    if (position.dy > 1.1) position = Offset(position.dx, -0.1);
  }
}

// Painter for particles
class ParticlePainter extends CustomPainter {
  final List<TrollParticle> particles;
  final double animationValue;
  
  ParticlePainter(this.particles, this.animationValue);
  
  @override
  void paint(Canvas canvas, Size size) {
    // Update and draw particles
    for (final particle in particles) {
      particle.update(0.02); // Small delta for movement
      
      final paint = Paint()
        ..color = particle.color.withOpacity(0.6 * animationValue)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
      
      // Convert normalized position to actual screen coordinates
      final position = Offset(
        particle.position.dx * size.width,
        particle.position.dy * size.height,
      );
      
      // Draw particle with size affected by animation
      canvas.drawCircle(
        position,
        particle.size * animationValue,
        paint,
      );
    }
    
    // Draw connection lines between nearby particles
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.1 * animationValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    for (int i = 0; i < particles.length; i++) {
      final p1 = particles[i];
      final pos1 = Offset(p1.position.dx * size.width, p1.position.dy * size.height);
      
      for (int j = i + 1; j < particles.length; j++) {
        final p2 = particles[j];
        final pos2 = Offset(p2.position.dx * size.width, p2.position.dy * size.height);
        
        final distance = (pos1 - pos2).distance;
        if (distance < 150) {
          canvas.drawLine(pos1, pos2, linePaint);
        }
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
} 