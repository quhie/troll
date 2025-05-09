import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/animated_troll_button.dart';
import '../views/main_menu_view.dart';
import '../utils/constants.dart';
import '../utils/page_transitions.dart';

class EnterView extends StatefulWidget {
  const EnterView({Key? key}) : super(key: key);

  @override
  State<EnterView> createState() => _EnterViewState();
}

class _EnterViewState extends State<EnterView> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToMainMenu() {
    Navigator.of(context).pushReplacement(
      PageTransitions.createRandomTransition(
        page: const MainMenuView(),
        duration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ],
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RepaintBoundary(
                      child: Animate(
                        controller: _controller,
                        effects: [
                          SlideEffect(
                            begin: const Offset(0, -0.2),
                            end: const Offset(0, 0),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                          ),
                          FadeEffect(
                            duration: const Duration(milliseconds: 400),
                          ),
                        ],
                        child: Text(
                          Constants.appName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    RepaintBoundary(
                      child: Animate(
                        controller: _controller,
                        effects: [
                          SlideEffect(
                            begin: const Offset(0, 0.2),
                            end: const Offset(0, 0),
                            delay: const Duration(milliseconds: 300),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOut,
                          ),
                          FadeEffect(
                            delay: const Duration(milliseconds: 300),
                            duration: const Duration(milliseconds: 400),
                          ),
                        ],
                        child: AnimatedTrollButton(
                          text: 'Start Trolling',
                          onTap: _navigateToMainMenu,
                          width: 220,
                          color: Theme.of(context).colorScheme.secondary,
                          icon: Icons.celebration,
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
    );
  }
}