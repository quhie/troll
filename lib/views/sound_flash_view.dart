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

class SoundFlashView extends StatelessWidget {
  final String title;
  final String soundPath;
  final String iconName;

  const SoundFlashView({
    Key? key,
    required this.title,
    required this.soundPath,
    required this.iconName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SoundFlashViewModel(),
      child: _SoundFlashViewContent(
        title: title,
        soundPath: soundPath,
        iconName: iconName,
      ),
    );
  }
}

class _SoundFlashViewContent extends StatefulWidget {
  final String title;
  final String soundPath;
  final String iconName;

  const _SoundFlashViewContent({
    Key? key,
    required this.title,
    required this.soundPath,
    required this.iconName,
  }) : super(key: key);

  @override
  State<_SoundFlashViewContent> createState() => _SoundFlashViewContentState();
}

class _SoundFlashViewContentState extends State<_SoundFlashViewContent> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late ConfettiController _confettiController;
  
  // For particle emitter
  final List<TrollParticle> _particles = [];
  Timer? _particleTimer;
  
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _confettiController = ConfettiController(
      duration: const Duration(milliseconds: 1500),
    );
  }
  
  void _startParticleEmitter() {
    // Clear existing particles
    _particles.clear();
    
    // Start emitting new particles
    _particleTimer?.cancel();
    _particleTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) {
        setState(() {
          // Add new particles
          for (int i = 0; i < 3; i++) {
            _particles.add(TrollParticle());
          }
          
          // Remove old particles
          _particles.removeWhere((particle) => particle.isExpired);
          
          // Update existing particles
          for (var particle in _particles) {
            particle.update();
          }
        });
      }
    });
  }
  
  void _stopParticleEmitter() {
    _particleTimer?.cancel();
    _particleTimer = null;
    
    if (mounted) {
      setState(() {
        _particles.clear();
      });
    }
  }
  
  @override
  void dispose() {
    _pulseController.dispose();
    _confettiController.dispose();
    _particleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SoundFlashViewModel>(context);
    final themeViewModel = Provider.of<ThemeViewModel>(context, listen: false);
    final isDark = themeViewModel.isDarkMode;
    
    // Choose a vibrant color from our theme
    final Color primaryColor = isDark ? AppTheme.darkPrimaryColor : AppTheme.primaryColor;
    final Color accentColor = isDark ? AppTheme.darkAccentColor : AppTheme.accentColor;
    final Color energyColor = AppTheme.energyColor;
    
    // Update emitter state based on viewModel.isActive
    if (viewModel.isActive && _particleTimer == null) {
      _startParticleEmitter();
      // Play confetti when we start
      _confettiController.play();
    } else if (!viewModel.isActive && _particleTimer != null) {
      _stopParticleEmitter();
    }
    
    final iconData = IconData(
      int.parse(widget.iconName),
      fontFamily: 'MaterialIcons',
    );
    
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
                colors: viewModel.isActive
                    ? [
                        accentColor,
                        isDark ? Colors.black : Color.lerp(accentColor, Colors.black, 0.8)!,
                      ]
                    : [
                        primaryColor,
                        isDark ? Colors.black : Color.lerp(primaryColor, Colors.black, 0.8)!,
                      ],
              ),
            ),
          ),
          
          // Background pattern
          Opacity(
            opacity: 0.1,
            child: CustomPaint(
              painter: TrollPatternPainter(
                isActive: viewModel.isActive,
                color: viewModel.isActive ? accentColor : primaryColor,
              ),
              child: Container(),
            ),
          ),
          
          // Particle effect layer when active
          if (_particles.isNotEmpty)
            CustomPaint(
              painter: ParticlePainter(_particles),
              child: Container(),
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
              ],
            ),
          ),
          
          // Main content
          GestureDetector(
            onLongPressStart: (_) {
              HapticFeedback.heavyImpact();
              viewModel.startEffects(widget.soundPath);
            },
            onLongPressEnd: (_) => viewModel.stopEffects(),
            onTap: () {
              HapticFeedback.mediumImpact();
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.transparent,
              width: double.infinity,
              height: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with advanced animations
                  RepaintBoundary(
                  child:
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Shadow/glow effect
                      if (viewModel.isActive)
                        SpinKitPulse(
                          color: viewModel.isActive 
                              ? energyColor.withOpacity(0.3) 
                              : primaryColor.withOpacity(0.2),
                          size: 180,
                          duration: const Duration(milliseconds: 1500),
                        ),
                      
                      // Main icon
                      Animate(
                        controller: _pulseController,
                        autoPlay: viewModel.isActive,
                        effects: [
                          ScaleEffect(
                            begin: const Offset(1.0, 1.0),
                            end: const Offset(1.4, 1.4),
                            curve: Curves.easeInOut,
                          ),
                          ShimmerEffect(
                            color: viewModel.isActive ? energyColor : primaryColor,
                            duration: const Duration(milliseconds: 1800),
                            delay: const Duration(milliseconds: 500),
                          ),
                          CustomEffect(
                            builder: (context, value, child) {
                              // Apply small shake when active
                              if (viewModel.isActive) {
                                final shake = sin(value * pi * 8) * 5.0;
                                return Transform.translate(
                                  offset: Offset(shake, 0),
                                  child: child,
                                );
                              }
                              return child!;
                            }
                          ),
                        ],
                        child: Icon(
                          iconData,
                          size: 140,
                          color: viewModel.isActive 
                              ? energyColor
                              : primaryColor,
                        ),
                      ),
                    ],
                  ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Status text with enhanced animation
                  RepaintBoundary(
                  child:
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.3),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.elasticOut,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      viewModel.isActive 
                          ? widget.title.toUpperCase() + ' ACTIVATED!'
                          : 'Press and Hold to Activate',
                      key: ValueKey<bool>(viewModel.isActive),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: viewModel.isActive
                            ? energyColor
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
                    ),
                  ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Touch circle with enhanced effects
                  RepaintBoundary(
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                          color: viewModel.isActive
                              ? energyColor.withOpacity(0.6)
                              : primaryColor.withOpacity(0.5),
                          width: 3,
                        ),
                        boxShadow: viewModel.isActive 
                          ? [
                              BoxShadow(
                                color: energyColor.withOpacity(0.5),
                                blurRadius: 25,
                                spreadRadius: 5,
                              )
                            ]
                          : [],
                      ),
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ripple effects (enhanced when active)
                            if (viewModel.isActive)
                              ...List.generate(5, (index) => 
                                Animate(
                                  effects: [
                                    ScaleEffect(
                                      begin: const Offset(0.4, 0.4),
                                      end: const Offset(2.5, 2.5),
                                      curve: Curves.easeOut,
                                      duration: Duration(milliseconds: 800 + (index * 200)),
                                    ),
                                    FadeEffect(
                                      begin: 0.7,
                                      end: 0.0,
                                      curve: Curves.easeOut,
                                      duration: Duration(milliseconds: 800 + (index * 200)),
                                    ),
                                  ],
                                  onComplete: (controller) => controller.repeat(),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: viewModel.isActive
                                          ? energyColor.withOpacity(0.3)
                                          : primaryColor.withOpacity(0.2),
                                      border: Border.all(
                                        color: viewModel.isActive
                                            ? energyColor.withOpacity(0.5)
                                            : primaryColor.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            
                            // Main action button
                            AnimatedScale(
                              scale: viewModel.isActive ? 1.1 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOutBack,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: viewModel.isActive ? 140 : 120,
                                height: viewModel.isActive ? 140 : 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: viewModel.isActive
                                        ? [energyColor, energyColor.withOpacity(0.7)]
                                        : [primaryColor.withOpacity(0.8), primaryColor.withOpacity(0.5)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: viewModel.isActive
                                          ? energyColor.withOpacity(0.5)
                                          : primaryColor.withOpacity(0.3),
                                      blurRadius: viewModel.isActive ? 20 : 15,
                                      spreadRadius: viewModel.isActive ? 3 : 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  viewModel.isActive ? Icons.power_settings_new : Icons.touch_app,
                                  size: 55,
                                  color: Colors.white,
                                ).animate(
                                  autoPlay: viewModel.isActive,
                                  onPlay: (controller) => controller.repeat(reverse: true),
                                  effects: [
                                    ScaleEffect(
                                      begin: const Offset(1.0, 1.0),
                                      end: const Offset(1.2, 1.2),
                                      duration: const Duration(milliseconds: 500),
                                    ),
                                    RotateEffect(
                                      begin: 0,
                                      end: 0.05,
                                      duration: const Duration(milliseconds: 400),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Instruction text
                  RepaintBoundary(
                    child: Text(
                      viewModel.isActive ? "Release to stop" : "Long press to activate",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ).animate(
                      autoPlay: true,
                      effects: [
                        FadeEffect(
                          begin: 0.7,
                          end: 1.0,
                          duration: const Duration(milliseconds: 2000),
                          delay: const Duration(milliseconds: 1000),
                          curve: Curves.easeInOut,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Return button
                  if (!viewModel.isActive)
                    RepaintBoundary(
                      child: AnimatedTrollButton(
                        text: "Return to Menu",
                        icon: Icons.arrow_back,
                        onTap: () => Navigator.of(context).pop(),
                        width: 200,
                        height: 50,
                        color: primaryColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom pattern painter for background
class TrollPatternPainter extends CustomPainter {
  final bool isActive;
  final Color color;
  
  TrollPatternPainter({required this.isActive, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // Draw pattern based on state
    if (isActive) {
      // Active pattern - concentric circles
      for (double i = 0; i < size.width * 1.5; i += 40) {
        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          i,
          paint,
        );
      }
    } else {
      // Inactive pattern - grid
      const double spacing = 30;
      
      // Draw horizontal lines
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          paint,
        );
      }
      
      // Draw vertical lines
      for (double x = 0; x < size.width; x += spacing) {
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          paint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant TrollPatternPainter oldDelegate) {
    return oldDelegate.isActive != isActive || oldDelegate.color != color;
  }
}

// Particle class for the particle effect
class TrollParticle {
  late Offset position;
  late Offset velocity;
  late double size;
  late Color color;
  late double opacity;
  late double life;
  late double maxLife;
  
  TrollParticle() {
    final random = Random();
    
    // Position starts from the center of the screen, with some randomness
    position = Offset(
      0.5 * random.nextDouble() * 500,
      0.5 * random.nextDouble() * 800,
    );
    
    // Random velocity
    velocity = Offset(
      (random.nextDouble() * 2 - 1) * 5,
      (random.nextDouble() * 2 - 1) * 5,
    );
    
    // Random size
    size = 3 + random.nextDouble() * 8;
    
    // Random color from a predefined set
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      AppTheme.highlightColor,
      AppTheme.energyColor,
    ];
    color = colors[random.nextInt(colors.length)];
    
    // Opacity and life
    opacity = 0.7 + random.nextDouble() * 0.3;
    maxLife = 2 + random.nextDouble() * 3; // Seconds
    life = 0;
  }
  
  void update() {
    // Update position
    position += velocity;
    
    // Add some gravity and wind effect
    velocity += const Offset(0.1, 0.1);
    
    // Slow down over time (friction)
    velocity *= 0.98;
    
    // Decrease opacity over time
    life += 0.05;
    opacity = opacity * (1 - (life / maxLife));
  }
  
  bool get isExpired => life >= maxLife || opacity <= 0.05;
}

// Custom painter for the particle effect
class ParticlePainter extends CustomPainter {
  final List<TrollParticle> particles;
  
  ParticlePainter(this.particles);
  
  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      // Ensure the particle is within the screen
      if (particle.position.dx < 0 || 
          particle.position.dx > size.width ||
          particle.position.dy < 0 || 
          particle.position.dy > size.height) {
        continue;
      }
      
      final paint = Paint()
        ..color = particle.color.withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        particle.position,
        particle.size,
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}