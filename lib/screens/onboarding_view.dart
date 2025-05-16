import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../screens/app_container.dart';
import '../models/sound_category.dart';
import '../services/preferences_service.dart';

/// Onboarding screen shown to first-time users
class OnboardingView extends StatefulWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  final List<OnboardingStep> _steps = [
    OnboardingStep(
      title: 'Welcome to Troll Sounds',
      description:
          'Your ultimate prank sound effects app, packed with fun sounds to surprise your friends!',
      image: 'assets/images/onboarding1.png',
      color: Colors.indigo,
      icon: Icons.emoji_emotions,
    ),
    OnboardingStep(
      title: 'Sound Categories',
      description:
          'Explore sounds organized in categories: Phone, Game, Horror, Meme and more!',
      image: 'assets/images/onboarding2.png',
      color: Colors.green,
      icon: Icons.category,
    ),
    OnboardingStep(
      title: 'Save Favorites',
      description:
          'Long press any sound to add it to your favorites for quick access.',
      image: 'assets/images/onboarding3.png',
      color: Colors.pink,
      icon: Icons.favorite,
    ),
    OnboardingStep(
      title: 'Ready to Troll?',
      description:
          'Time to have fun and surprise everyone with amazing sound effects!',
      image: 'assets/images/onboarding4.png',
      color: Colors.deepOrange,
      icon: Icons.celebration,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() {
    // Mark onboarding as completed in preferences
    final preferencesService = Provider.of<PreferencesService>(
      context,
      listen: false,
    );
    preferencesService.setOnboardingCompleted();

    // Navigate to app
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AppContainer()));
  }

  void _goToNext() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _steps[_currentPage].color,
                  _steps[_currentPage].color.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextButton(
                      onPressed: _skipOnboarding,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Skip'),
                    ),
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      final step = _steps[index];
                      return _buildPage(step);
                    },
                  ),
                ),

                // Page indicators and button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page indicators
                      Row(
                        children: List.generate(
                          _totalPages,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: index == _currentPage ? 24 : 8,
                            decoration: BoxDecoration(
                              color:
                                  index == _currentPage
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),

                      // Next button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        child: FloatingActionButton(
                          onPressed: _goToNext,
                          backgroundColor: Colors.white,
                          foregroundColor: _steps[_currentPage].color,
                          child: Icon(
                            _currentPage < _totalPages - 1
                                ? Icons.arrow_forward
                                : Icons.check,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingStep step) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with animation
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(step.icon, size: 60, color: step.color),
          ).animate().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
          ),

          const SizedBox(height: 48),

          // Title
          Text(
                step.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 500),
              )
              .moveY(
                begin: 20,
                end: 0,
                delay: const Duration(milliseconds: 300),
                duration: const Duration(milliseconds: 500),
              ),

          const SizedBox(height: 24),

          // Description
          Text(
                step.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              )
              .animate()
              .fadeIn(
                delay: const Duration(milliseconds: 500),
                duration: const Duration(milliseconds: 500),
              )
              .moveY(
                begin: 20,
                end: 0,
                delay: const Duration(milliseconds: 500),
                duration: const Duration(milliseconds: 500),
              ),
        ],
      ),
    );
  }
}

/// Model class for onboarding steps
class OnboardingStep {
  final String title;
  final String description;
  final String image;
  final Color color;
  final IconData icon;

  OnboardingStep({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
    required this.icon,
  });
}
