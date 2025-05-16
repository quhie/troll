import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../widgets/menu_grid_card.dart';
import '../widgets/glitch_text.dart';
import '../widgets/neon_border.dart';
import '../utils/constants.dart';
import '../utils/app_theme.dart';
import '../screens/sound_flash_view.dart';
import '../screens/unclickable_button_view.dart';
import '../screens/custom_sound_lab_view.dart';
import '../screens/voice_activated_view.dart';
import '../screens/troll_alarm_view.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../models/sound_model.dart';
import '../utils/haptic_feedback_helper.dart';
import '../models/feature.dart';
import '../widgets/feature_button.dart';
import '../widgets/feature_group_card.dart';
import 'feature_groups/sound_features_group.dart';
import 'feature_groups/visual_effects_group.dart';
import 'feature_groups/tools_group.dart';
import 'package:confetti/confetti.dart';
import '../widgets/animated_troll_button.dart';
import '../widgets/modern_navigation.dart';
import '../services/sound_service.dart';
import '../utils/page_transitions.dart';
import '../models/sound_category.dart';
import '../screens/settings_screen.dart';

/// The main menu screen of the app
class MainMenuView extends StatefulWidget {
  /// Creates the main menu view
  const MainMenuView({Key? key}) : super(key: key);

  @override
  State<MainMenuView> createState() => _MainMenuViewState();
}

class _MainMenuViewState extends State<MainMenuView>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  List<SoundModel> _soundsList = [];

  // For custom radial menu
  late AnimationController _animationController;
  bool _isRadialMenuOpen = false;

  // For home page dynamic effects
  double _scrollOffset = 0.0;
  final ScrollController _scrollController = ScrollController();

  late AnimationController _backgroundController;
  late AnimationController _floatingController;
  final ConfettiController _confettiController = ConfettiController(
    duration: const Duration(seconds: 1),
  );

  bool _isDragging = false;
  int _selectedIndex = 0;
  final List<Color> _colors = [
    AppTheme.primaryColor,
    AppTheme.secondaryColor,
    AppTheme.accentColor,
    AppTheme.accentColor.withOpacity(0.7),
  ];

  // List of main menu features
  final List<MenuFeature> _features = [
    MenuFeature(
      title: "Sound Flash",
      description: "Hold to activate fun sound effects with visual feedback",
      icon: Icons.flash_on,
      color: AppTheme.primaryColor,
      soundPath: 'sounds/electric_sound/electric-shock-97989.mp3',
      iconCode: '0xe32b', // flash_on
    ),
    MenuFeature(
      title: "Unclickable Button",
      description: "Try to click a button that keeps running away from you",
      icon: Icons.touch_app,
      color: AppTheme.secondaryColor,
      soundPath: 'sounds/mosquito/wind-and-mosquito-7714.mp3',
      iconCode: '0xef48', // touch_app
    ),
    MenuFeature(
      title: "Troll Alarm",
      description: "Set an alarm that will surprise your friends",
      icon: Icons.alarm,
      color: AppTheme.accentColor,
      soundPath: 'sounds/fart/fart-34458.mp3',
      iconCode: '0xe005', // alarm
    ),
    MenuFeature(
      title: "Voice Activator",
      description: "Activate fun sounds with your voice",
      icon: Icons.mic,
      color: Colors.purple,
      soundPath: 'sounds/air_horn/airhorn-271079.mp3',
      iconCode: '0xe375', // mic
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Preload sound list to avoid repeated fetching
    _soundsList = Constants.getSoundsList();

    // Initialize animation controller for radial menu
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Listen to scroll events for parallax effects
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Setup animation controllers
    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Pre-load key sound effects
    _preloadSounds();
  }

  void _preloadSounds() async {
    final soundService = Provider.of<SoundService>(context, listen: false);

    // Convert feature paths to SoundModel objects
    final sounds =
        _features
            .map(
              (feature) => SoundModel(
                id: feature.title,
                name: feature.title,
                soundPath: 'assets/' + feature.soundPath,
                iconName: feature.iconCode,
                category: CategoryType.meme, // Add default category
              ),
            )
            .toList();

    // No need to preload explicitly - just make sounds available
    for (final sound in sounds) {
      // Play and immediately stop to load into memory
      await soundService.playSound(sound);
      await soundService.stopSound();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    _backgroundController.dispose();
    _floatingController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  // Toggle the radial menu visibility
  void _toggleRadialMenu() {
    setState(() {
      _isRadialMenuOpen = !_isRadialMenuOpen;
      if (_isRadialMenuOpen) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  // Change bottom navigation bar index and page
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    final isDark = themeViewModel.isDarkMode;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Troll Sounds",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              themeViewModel.toggleTheme();
              HapticFeedbackHelper.lightImpact();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _backgroundController,
            builder: (context, child) {
              return CustomPaint(
                painter: BackgroundPatternPainter(
                  animation: _backgroundController.value,
                  isDarkMode: isDark,
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
              maxBlastForce: 7,
              minBlastForce: 3,
              emissionFrequency: 0.07,
              numberOfParticles: 20,
              gravity: 0.1,
              colors: _colors,
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),

                // App tagline with animation
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                        "Fun Interactive Sound Effects",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.8),
                          fontStyle: FontStyle.italic,
                        ),
                      )
                      .animate()
                      .fade(duration: 800.ms)
                      .slideY(
                        begin: 0.3,
                        end: 0,
                        duration: 800.ms,
                        curve: Curves.easeOutBack,
                      ),
                ),

                const SizedBox(height: 16),

                // Category circles
                AnimatedBuilder(
                  animation: _floatingController,
                  builder: (context, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        // Calculate floating offset based on index
                        final offset =
                            sin(
                              (_floatingController.value * pi * 2) +
                                  (index * 0.5),
                            ) *
                            8;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Transform.translate(
                            offset: Offset(0, offset),
                            child: CategoryCircle(
                              color: _colors[index],
                              icon: _features[index].icon,
                              isSelected: _selectedIndex == index,
                              onTap: () {
                                setState(() => _selectedIndex = index);
                                HapticFeedbackHelper.selectionClick();
                              },
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Featured item card
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.5, 0),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeOutQuart,
                            ),
                          ),
                          child: child,
                        ),
                      );
                    },
                    child: FeatureCard(
                      key: ValueKey<int>(_selectedIndex),
                      feature: _features[_selectedIndex],
                      onTap: () => _navigateToFeature(context, _selectedIndex),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Launch button
                AnimatedTrollButton(
                  text: "Launch ${_features[_selectedIndex].title}",
                  icon: _features[_selectedIndex].icon,
                  onTap: () => _navigateToFeature(context, _selectedIndex),
                  width: 250,
                  height: 60,
                  color: _colors[_selectedIndex],
                  elevated: true,
                  useGradient: true,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToFeature(BuildContext context, int index) {
    HapticFeedbackHelper.mediumImpact();

    final feature = _features[index];
    _playFeatureSound(feature.soundPath);

    // Show confetti for selected feature
    _confettiController.play();

    // Navigate to the selected feature
    switch (index) {
      case 0: // Sound Flash
        Navigator.of(context).push(
          PageTransitions.createRandomTransition(
            page: SoundFlashView(
              title: feature.title,
              soundPath: feature.soundPath,
              iconName: feature.iconCode,
            ),
          ),
        );
        break;
      case 1: // Unclickable Button
        Navigator.of(context).push(
          PageTransitions.createRandomTransition(
            page: const UnclickableButtonView(),
          ),
        );
        break;
      case 2: // Troll Alarm
        Navigator.of(context).push(
          PageTransitions.createRandomTransition(page: const TrollAlarmView()),
        );
        break;
      case 3: // Voice Activated
        Navigator.of(context).push(
          PageTransitions.createRandomTransition(
            page: const VoiceActivatedView(),
          ),
        );
        break;
    }
  }

  void _playFeatureSound(String soundPath) {
    final soundService = Provider.of<SoundService>(context, listen: false);
    soundService.playSound(soundPath);
  }
}

// Custom painter for bubble pattern in header
class BubblePatternPainter extends CustomPainter {
  final Color color;
  final double offset;

  BubblePatternPainter({required this.color, this.offset = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    // Create bubbles of different sizes
    final random = Random(42); // Fixed seed for consistent randomness

    for (int i = 0; i < 15; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 5 + random.nextDouble() * 15;

      // Add subtle parallax effect based on offset
      final adjustedX = (x + offset * (i % 3 + 1)) % size.width;

      canvas.drawCircle(Offset(adjustedX, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Feature item data class
class MenuFeature {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String soundPath;
  final String iconCode;

  MenuFeature({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.soundPath,
    required this.iconCode,
  });
}

// Category selection circle
class CategoryCircle extends StatelessWidget {
  final Color color;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryCircle({
    Key? key,
    required this.color,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isSelected ? 70 : 60,
        height: isSelected ? 70 : 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? color : color.withOpacity(0.3),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.6),
            width: isSelected ? 3 : 2,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: color.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ]
                  : [],
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          size: isSelected ? 35 : 30,
        ),
      ),
    );
  }
}

// Feature card widget
class FeatureCard extends StatelessWidget {
  final MenuFeature feature;
  final VoidCallback onTap;

  const FeatureCard({Key? key, required this.feature, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                feature.color.withOpacity(0.8),
                feature.color.withOpacity(0.4),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: feature.color.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Background patterns
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.07,
                    child: CustomPaint(
                      painter: FeatureCardPatternPainter(color: feature.color),
                    ),
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with icon
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              feature.icon,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              feature.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Description
                      Text(
                        feature.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                        ),
                      ),

                      const Spacer(),

                      // Interactive hint
                      Row(
                        children: [
                          Icon(
                            Icons.touch_app,
                            color: Colors.white.withOpacity(0.7),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Tap to launch this feature",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ).animate(
                        autoPlay: true,
                        onPlay:
                            (controller) => controller.repeat(reverse: true),
                        effects: [
                          FadeEffect(begin: 0.7, end: 1.0, duration: 1000.ms),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Feature card pattern painter
class FeatureCardPatternPainter extends CustomPainter {
  final Color color;

  FeatureCardPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    // Draw grid pattern
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw decorative circles
    for (int i = 0; i < 5; i++) {
      final radius = size.width * (0.1 + 0.1 * i);
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant FeatureCardPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

// Custom painter for background pattern
class BackgroundPatternPainter extends CustomPainter {
  final double animation;
  final bool isDarkMode;

  BackgroundPatternPainter({required this.animation, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = isDarkMode ? Colors.black : Colors.white
          ..style = PaintingStyle.fill;

    final random = Random(42); // Fixed seed for consistent randomness

    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 5 + random.nextDouble() * 10;

      // Add subtle parallax effect based on animation
      final adjustedX = (x + animation * (i % 3 + 1)) % size.width;

      canvas.drawCircle(Offset(adjustedX, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
