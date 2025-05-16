import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../utils/app_config.dart';

/// Text widget with glitch animation effect that supports accessibility
class GlitchText extends StatefulWidget {
  /// The text to display with the glitch effect
  final String text;

  /// The text style to apply
  final TextStyle? style;

  /// Intensity of the glitch effect (0.0 to 1.0)
  final double intensity;

  /// Whether to enable the glitch effect
  final bool enableGlitch;

  /// Additional semantic description for accessibility
  final String? semanticLabel;

  /// Create a glitch text effect
  const GlitchText(
    this.text, {
    Key? key,
    this.style,
    this.intensity = 0.2,
    this.enableGlitch = true,
    this.semanticLabel,
  }) : super(key: key);

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Random _random;
  String _displayText = '';
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _random = Random();
    _displayText = widget.text;

    // Create and configure animation controller with reduced animation if needed
    _controller = AnimationController(
      vsync: this,
      duration:
          AppConfig.enableReducedMotion
              ? const Duration(milliseconds: 4000)
              : const Duration(milliseconds: 2000),
    );

    // Only start animations if enabled
    if (widget.enableGlitch && AppConfig.enableAnimations) {
      _controller.addListener(_updateGlitchText);
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.removeListener(_updateGlitchText);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GlitchText oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update text if changed
    if (oldWidget.text != widget.text) {
      _displayText = widget.text;
    }

    // Handle animation state changes
    if (oldWidget.enableGlitch != widget.enableGlitch) {
      if (widget.enableGlitch && AppConfig.enableAnimations) {
        _controller.addListener(_updateGlitchText);
        if (!_controller.isAnimating) {
          _controller.repeat();
        }
      } else {
        _controller.removeListener(_updateGlitchText);
        _controller.stop();
        // Reset to the original text
        if (_displayText != widget.text) {
          setState(() {
            _displayText = widget.text;
          });
        }
      }
    }
  }

  void _updateGlitchText() {
    if (_isDisposed) return;

    // Limit the frequency of glitch effects for better performance
    if (_random.nextDouble() < widget.intensity * 0.4 * _controller.value) {
      setState(() {
        _displayText = _glitchString(widget.text);
      });
    } else if (_displayText != widget.text) {
      setState(() {
        _displayText = widget.text;
      });
    }
  }

  String _glitchString(String input) {
    if (input.isEmpty) return input;

    // Determine how many characters to glitch - optimize for performance
    final glitchCount = max(
      1,
      min(3, (input.length * widget.intensity * 0.3).round()),
    );
    final positions = List.generate(input.length, (index) => index)
      ..shuffle(_random);
    final glitchPositions = positions.take(glitchCount).toList();

    // Create a copy of the string as a list of characters
    final chars = input.split('');

    // Replace characters at random positions with simpler substitutions
    for (final pos in glitchPositions) {
      if (pos < chars.length) {
        // Use a simpler replacement strategy for better performance
        final replacementType = _random.nextInt(2);
        switch (replacementType) {
          case 0:
            // Replace with a random ASCII character
            chars[pos] = String.fromCharCode(_random.nextInt(26) + 65);
            break;
          case 1:
            // Replace with a special character (limited set for performance)
            final specialChars = ['#', '%', '!'];
            chars[pos] = specialChars[_random.nextInt(specialChars.length)];
            break;
        }
      }
    }

    return chars.join();
  }

  @override
  Widget build(BuildContext context) {
    // Use Semantics for accessibility
    return Semantics(
      label: widget.semanticLabel ?? widget.text,
      excludeSemantics:
          true, // Hide the visual representation from screen readers
      child: Text(_displayText, style: widget.style),
    );
  }
}
