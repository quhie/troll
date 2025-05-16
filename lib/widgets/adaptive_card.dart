import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../utils/app_theme.dart';

/// A redesigned modern card with enhanced animations and visual effects
class AdaptiveCard extends StatefulWidget {
  /// The main content of the card
  final Widget child;

  /// Optional header widget displayed at the top of the card
  final Widget? header;

  /// Optional title for the card
  final String? title;

  /// Optional subtitle for the card
  final String? subtitle;

  /// Optional icon to display in the card header
  final IconData? icon;

  /// Optional color for the icon and card accent
  final Color? accentColor;

  /// Optional actions to display at the bottom of the card
  final List<Widget>? actions;

  /// Card padding
  final EdgeInsetsGeometry padding;

  /// Card margin
  final EdgeInsetsGeometry margin;

  /// Optional border radius
  final BorderRadius? borderRadius;

  /// Optional card elevation
  final double elevation;

  /// Whether to enable card ripple effect on tap
  final bool enableRipple;

  /// Optional callback when card is tapped
  final VoidCallback? onTap;

  /// Whether to use a gradient background for the card
  final bool useGradientBackground;

  /// Optional background gradient
  final Gradient? backgroundGradient;

  /// Optional border color for the card
  final Color? borderColor;

  /// Optional background color for the card
  final Color? backgroundColor;

  /// Whether to show a glow effect
  final bool showGlow;

  /// Whether to animate the card
  final bool animate;

  /// Optional callback on long press
  final VoidCallback? onLongPress;

  /// Optional semantic label for accessibility
  final String? semanticLabel;

  /// Creates an adaptive card
  const AdaptiveCard({
    Key? key,
    required this.child,
    this.header,
    this.title,
    this.subtitle,
    this.icon,
    this.accentColor,
    this.actions,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(8.0),
    this.borderRadius,
    this.elevation = 1.0,
    this.enableRipple = true,
    this.onTap,
    this.useGradientBackground = false,
    this.backgroundGradient,
    this.borderColor,
    this.backgroundColor,
    this.showGlow = false,
    this.animate = true,
    this.onLongPress,
    this.semanticLabel,
  }) : super(key: key);

  @override
  State<AdaptiveCard> createState() => _AdaptiveCardState();
}

class _AdaptiveCardState extends State<AdaptiveCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  bool _isHovered = false;
  late AnimationController _hoverController;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        widget.backgroundColor ??
        (isDark ? AppTheme.darkSurfaceColor : Colors.white);
    final textColor =
        isDark ? Colors.white.withOpacity(0.9) : Colors.black.withOpacity(0.9);
    final secondaryTextColor =
        isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7);
    final borderRadiusValue =
        widget.borderRadius ?? BorderRadius.circular(24); // Increased radius
    final effectiveAccentColor =
        widget.accentColor ??
        (isDark
            ? AppTheme.primaryColor.withOpacity(0.9)
            : AppTheme.primaryColor);

    // Build the card content
    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header
        if (widget.header != null) widget.header!,

        // Title + Icon header
        if (widget.title != null || widget.icon != null)
          Padding(
            padding: const EdgeInsets.only(
              top: 8.0,
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
            ),
            child: Row(
              children: [
                if (widget.icon != null)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: effectiveAccentColor.withOpacity(
                        _isHovered ? 0.2 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow:
                          _isHovered
                              ? [
                                BoxShadow(
                                  color: effectiveAccentColor.withOpacity(0.3),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ]
                              : null,
                    ),
                    child: Icon(
                      widget.icon,
                      color: effectiveAccentColor,
                      size: 24,
                    ),
                  ),
                if (widget.title != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title!,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            height: 1.2,
                          ),
                        ),
                        if (widget.subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              widget.subtitle!,
                              style: TextStyle(
                                fontSize: 14,
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),

        // Main content
        Padding(
          padding:
              widget.title != null || widget.icon != null
                  ? EdgeInsets.only(
                    left: widget.padding.horizontal / 2,
                    right: widget.padding.horizontal / 2,
                    bottom: widget.padding.vertical / 2,
                  )
                  : widget.padding,
          child: widget.child,
        ),

        // Action buttons
        if (widget.actions != null && widget.actions!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              left: 12.0,
              right: 12.0,
              top: 8.0,
              bottom: 12.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children:
                  widget.actions!.map((action) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: action,
                    );
                  }).toList(),
            ),
          ),
      ],
    );

    // Create the animated container
    final cardContainer = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      margin: widget.margin,
      decoration: BoxDecoration(
        color: widget.useGradientBackground ? null : cardColor,
        gradient:
            widget.useGradientBackground
                ? (widget.backgroundGradient ??
                    LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        isDark
                            ? AppTheme.primaryColor.withOpacity(0.3)
                            : AppTheme.primaryColor.withOpacity(0.1),
                        isDark
                            ? AppTheme.secondaryColor.withOpacity(0.3)
                            : AppTheme.secondaryColor.withOpacity(0.1),
                      ],
                    ))
                : null,
        borderRadius: borderRadiusValue,
        border:
            widget.borderColor != null
                ? Border.all(
                  color: widget.borderColor!.withOpacity(
                    _isHovered ? 1.0 : 0.7,
                  ),
                  width: _isHovered ? 2.0 : 1.5,
                )
                : null,
        boxShadow: [
          BoxShadow(
            color:
                _isHovered && widget.showGlow && widget.borderColor != null
                    ? widget.borderColor!.withOpacity(0.7)
                    : _isHovered
                    ? effectiveAccentColor.withOpacity(0.15)
                    : Colors.black.withOpacity(isDark ? 0.3 : 0.07),
            blurRadius:
                _isHovered
                    ? 16
                    : widget.showGlow
                    ? 12
                    : widget.elevation * 3,
            spreadRadius:
                _isHovered
                    ? 2
                    : widget.showGlow
                    ? 2
                    : widget.elevation / 3,
            offset: Offset(0, _isHovered ? 4 : widget.elevation),
          ),
        ],
      ),
      transform:
          _isPressed
              ? Matrix4.translationValues(0, 2, 0)
              : _isHovered
              ? Matrix4.translationValues(0, -2, 0)
              : Matrix4.translationValues(0, 0, 0),
      child: ClipRRect(
        borderRadius: borderRadiusValue,
        child: Material(
          color: Colors.transparent,
          child:
              widget.onTap != null
                  ? InkWell(
                    onTap: () {
                      if (widget.onTap != null) {
                        widget.onTap!();
                      }
                    },
                    onTapDown: (_) {
                      setState(() => _isPressed = true);
                    },
                    onTapUp: (_) {
                      setState(() => _isPressed = false);
                    },
                    onTapCancel: () {
                      setState(() => _isPressed = false);
                    },
                    onLongPress: widget.onLongPress,
                    hoverColor: widget.enableRipple ? null : Colors.transparent,
                    splashColor:
                        widget.enableRipple ? null : Colors.transparent,
                    highlightColor:
                        widget.enableRipple ? null : Colors.transparent,
                    onHover: (hover) {
                      setState(() => _isHovered = hover);
                      if (hover) {
                        _hoverController.forward();
                      } else {
                        _hoverController.reverse();
                      }
                    },
                    child: cardContent,
                  )
                  : cardContent,
        ),
      ),
    );

    // Wrap with semantics if label provided
    final semanticsWidget =
        widget.semanticLabel != null
            ? Semantics(label: widget.semanticLabel, child: cardContainer)
            : cardContainer;

    // Apply animations if needed
    if (widget.animate) {
      return semanticsWidget
          .animate(autoPlay: true)
          .fade(duration: const Duration(milliseconds: 400))
          .scale(
            begin: const Offset(0.96, 0.96),
            end: const Offset(1, 1),
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
          );
    }

    return semanticsWidget;
  }
}

/// A card specifically designed for feature items in the app
class FeatureCard extends StatelessWidget {
  /// The title of the feature
  final String title;

  /// Optional description
  final String? description;

  /// Icon to display
  final IconData icon;

  /// Accent color
  final Color? accentColor;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Whether to highlight this feature
  final bool isHighlighted;

  /// Creates a feature card
  const FeatureCard({
    Key? key,
    required this.title,
    this.description,
    required this.icon,
    this.accentColor,
    this.onTap,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveAccentColor =
        accentColor ??
        (isDark
            ? AppTheme.primaryColor.withOpacity(0.9)
            : AppTheme.primaryColor);

    return AdaptiveCard(
      onTap: onTap,
      accentColor: effectiveAccentColor,
      borderColor: isHighlighted ? effectiveAccentColor : null,
      margin: const EdgeInsets.all(6),
      elevation: isHighlighted ? 4 : 1,
      showGlow: isHighlighted,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: effectiveAccentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: effectiveAccentColor.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(icon, color: effectiveAccentColor, size: 30),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleXY(
                begin: 1.0,
                end: isHighlighted ? 1.1 : 1.05,
                duration: Duration(milliseconds: isHighlighted ? 1200 : 2000),
                curve: Curves.easeInOut,
              ),
          const SizedBox(height: 16),
          Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
              .animate()
              .fadeIn(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 200),
              )
              .move(begin: const Offset(0, 10), end: const Offset(0, 0)),
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12, right: 12),
              child: Text(
                    description!,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  )
                  .animate()
                  .fadeIn(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 400),
                  )
                  .move(begin: const Offset(0, 10), end: const Offset(0, 0)),
            ),
        ],
      ),
    );
  }
}
