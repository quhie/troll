import 'package:flutter/material.dart';
import '../models/feature.dart';
import '../utils/app_theme.dart';

/// A reusable button widget for features
class FeatureButton extends StatelessWidget {
  /// The feature to display
  final Feature feature;

  /// The size of the button
  final FeatureButtonSize size;

  /// Creates a feature button
  const FeatureButton({
    Key? key,
    required this.feature,
    this.size = FeatureButtonSize.medium,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    // Determine the color of the feature
    final featureColor = feature.color ?? AppTheme.primaryColor;

    // Get the size of the button based on the size parameter
    final buttonSize = _getButtonSize(size);

    return Card(
      color: isDarkMode ? Colors.grey.shade800 : Colors.white,
      elevation: 2,
      child: InkWell(
        onTap: feature.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: buttonSize.width,
          height: buttonSize.height,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (feature.tag != null) _buildTag(feature.tag!, featureColor),
              Icon(
                feature.icon,
                color: featureColor,
                size: buttonSize.iconSize,
              ),
              const SizedBox(height: 8),
              Text(
                feature.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (feature.description != null) ...[
                const SizedBox(height: 4),
                Text(
                  feature.description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:
                        isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build a tag widget for the feature
  Widget _buildTag(String tag, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Get button dimensions based on size
  ButtonDimensions _getButtonSize(FeatureButtonSize size) {
    switch (size) {
      case FeatureButtonSize.small:
        return const ButtonDimensions(width: 90, height: 90, iconSize: 28);
      case FeatureButtonSize.medium:
        return const ButtonDimensions(width: 140, height: 140, iconSize: 36);
      case FeatureButtonSize.large:
        return const ButtonDimensions(width: 180, height: 180, iconSize: 48);
    }
  }
}

/// Size options for feature buttons
enum FeatureButtonSize {
  /// Small button size
  small,

  /// Medium button size (default)
  medium,

  /// Large button size
  large,
}

/// Dimensions for a button at a specific size
class ButtonDimensions {
  /// Width of the button
  final double width;

  /// Height of the button
  final double height;

  /// Size of the icon
  final double iconSize;

  /// Create button dimensions
  const ButtonDimensions({
    required this.width,
    required this.height,
    required this.iconSize,
  });
}
