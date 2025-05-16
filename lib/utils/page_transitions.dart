import 'dart:math';
import 'package:flutter/material.dart';

class PageTransitions {
  static final Random _random = Random();

  /// Creates a random page transition for playful navigation.
  /// Each time it's called, it randomly selects one of the available transition styles.
  static PageRouteBuilder createRandomTransition({
    required Widget page,
    Duration duration = const Duration(milliseconds: 700),
  }) {
    // Select a random transition effect
    final effectIndex = _random.nextInt(5);

    switch (effectIndex) {
      case 0:
        return _createZoomTransition(page, duration);
      case 1:
        return _createRotateAndSlideTransition(page, duration);
      case 2:
        return _createFlipTransition(page, duration);
      case 3:
        return _createBounceTransition(page, duration);
      case 4:
        return _createFadeSlideTransition(page, duration);
      default:
        return _createFadeTransition(page, duration);
    }
  }

  /// Creates a zoom transition that expands from the center or from a random corner
  static PageRouteBuilder _createZoomTransition(
    Widget page,
    Duration duration,
  ) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Randomly choose alignment for zoom origin
        final alignments = [
          Alignment.center,
          Alignment.topLeft,
          Alignment.topRight,
          Alignment.bottomLeft,
          Alignment.bottomRight,
        ];
        final alignment = alignments[_random.nextInt(alignments.length)];

        return ScaleTransition(
          alignment: alignment,
          scale: Tween<double>(
            begin: 0.2,
            end: 1.0,
          ).chain(CurveTween(curve: Curves.elasticOut)).animate(animation),
          child: child,
        );
      },
    );
  }

  /// Creates a rotation and slide transition
  static PageRouteBuilder _createRotateAndSlideTransition(
    Widget page,
    Duration duration,
  ) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Random slide direction (left or right)
        final direction = _random.nextBool() ? 1 : -1;

        return RotationTransition(
          turns: Tween<double>(
            begin: direction * 0.1,
            end: 0.0,
          ).chain(CurveTween(curve: Curves.easeOutBack)).animate(animation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(direction.toDouble(), 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  /// Creates a 3D flip transition around Y axis
  static PageRouteBuilder _createFlipTransition(
    Widget page,
    Duration duration,
  ) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (context, child) {
            final rotateAnim = Tween(
              begin: pi,
              end: 0.0,
            ).chain(CurveTween(curve: Curves.easeOutBack)).animate(animation);

            return Transform(
              alignment: Alignment.center,
              transform:
                  Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(rotateAnim.value),
              child: child,
            );
          },
        );
      },
    );
  }

  /// Creates a bounce transition with fade
  static PageRouteBuilder _createBounceTransition(
    Widget page,
    Duration duration,
  ) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return AnimatedBuilder(
          animation: animation,
          child: FadeTransition(opacity: animation, child: child),
          builder: (context, child) {
            final bounce =
                sin(animation.value * pi * 3) * (1 - animation.value) * 30;
            return Transform.translate(offset: Offset(0, bounce), child: child);
          },
        );
      },
    );
  }

  /// Creates a fade transition with slide from bottom
  static PageRouteBuilder _createFadeSlideTransition(
    Widget page,
    Duration duration,
  ) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutBack)).animate(animation),
            child: child,
          ),
        );
      },
    );
  }

  /// Creates a simple fade transition
  static PageRouteBuilder _createFadeTransition(
    Widget page,
    Duration duration,
  ) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

/// A custom PageRoute that applies one of the custom transitions
class CustomPageRoute<T> extends PageRoute<T> {
  final Widget page;
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  )
  transitionBuilder;

  CustomPageRoute({
    required this.page,
    required this.transitionBuilder,
    RouteSettings? settings,
  }) : super(settings: settings);

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return page;
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return transitionBuilder(context, animation, secondaryAnimation, child);
  }

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);
}

/// Custom page transitions builder for use with MaterialApp's theme
class CustomPageTransitionsBuilder extends PageTransitionsBuilder {
  final Widget Function(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  )
  transitionBuilder;

  const CustomPageTransitionsBuilder({required this.transitionBuilder});

  @override
  Widget buildTransitions<T>(
    PageRoute<T>? route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return transitionBuilder(context, animation, secondaryAnimation, child);
  }
}

/// No transition (instant)
Widget noTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return child;
}

/// Fade transition
Widget fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}

/// Slide transition from right
Widget slideRightTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  const begin = Offset(1.0, 0.0);
  const end = Offset.zero;
  const curve = Curves.easeInOutCubic;

  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  var offsetAnimation = animation.drive(tween);

  return SlideTransition(
    position: offsetAnimation,
    child: FadeTransition(opacity: animation, child: child),
  );
}

/// Scale transition
Widget scaleTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return ScaleTransition(
    scale: CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
    child: FadeTransition(opacity: animation, child: child),
  );
}

/// Random transition - chooses one of the above randomly
Widget randomTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final transitions = [fadeTransition, slideRightTransition, scaleTransition];

  final random = Random();
  final index = random.nextInt(transitions.length);

  return transitions[index](context, animation, secondaryAnimation, child);
}
