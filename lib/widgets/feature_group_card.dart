import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/feature.dart';
import '../utils/app_theme.dart';
import 'feature_button.dart';

/// A card that displays a group of related features in a grid
class FeatureGroupCard extends StatefulWidget {
  /// The feature group to display
  final FeatureGroup featureGroup;

  /// Whether the card is initially expanded
  final bool initiallyExpanded;

  /// Size of the feature buttons
  final FeatureButtonSize buttonSize;

  /// Number of buttons per row
  final int buttonsPerRow;

  /// Optional callback when expansion state changes
  final ValueChanged<bool>? onExpansionChanged;

  /// Creates a feature group card
  const FeatureGroupCard({
    Key? key,
    required this.featureGroup,
    this.initiallyExpanded = true,
    this.buttonSize = FeatureButtonSize.medium,
    this.buttonsPerRow = 2,
    this.onExpansionChanged,
  }) : super(key: key);

  @override
  State<FeatureGroupCard> createState() => _FeatureGroupCardState();
}

class _FeatureGroupCardState extends State<FeatureGroupCard>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: _isExpanded ? 1.0 : 0.0,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FeatureGroupCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initiallyExpanded != oldWidget.initiallyExpanded &&
        widget.initiallyExpanded != _isExpanded) {
      _setExpanded(widget.initiallyExpanded);
    }
  }

  void _toggleExpanded() {
    _setExpanded(!_isExpanded);
  }

  void _setExpanded(bool expanded) {
    if (_isExpanded == expanded) return;

    setState(() {
      _isExpanded = expanded;
    });

    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }

    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    final groupColor = widget.featureGroup.color ?? AppTheme.primaryColor;

    // Header for the card
    final header = Row(
      children: [
        Icon(
          widget.featureGroup.icon,
          color: isDarkMode ? Colors.white : groupColor,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            widget.featureGroup.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDarkMode ? Colors.white : null,
            ),
          ),
        ),
        IconButton(
          onPressed: _toggleExpanded,
          icon: RotationTransition(
            turns: Tween<double>(begin: 0, end: 0.5).animate(_expandAnimation),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: isDarkMode ? Colors.white : null,
            ),
          ),
        ),
      ],
    );

    // Modern style card
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _buildFeaturesGrid()
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 100.ms)
                    .slide(begin: const Offset(0, 0.1), end: Offset.zero),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a grid of feature buttons
  Widget _buildFeaturesGrid() {
    // Calculate the number of rows needed
    final int itemCount = widget.featureGroup.features.length;
    final int rowCount = (itemCount / widget.buttonsPerRow).ceil();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.buttonsPerRow,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index >= itemCount) return const SizedBox();

        final feature = widget.featureGroup.features[index];

        return FeatureButton(feature: feature, size: widget.buttonSize)
            .animate()
            .fadeIn(
              duration: 300.ms,
              delay: Duration(milliseconds: 100 + (index * 50)),
            )
            .slide(
              begin: const Offset(0, 0.2),
              end: Offset.zero,
              curve: Curves.easeOutCubic,
            );
      },
    );
  }
}
