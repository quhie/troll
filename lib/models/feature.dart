import 'package:flutter/material.dart';

/// A feature represents a navigation option or action in the app
class Feature {
  /// The display name of the feature
  final String name;

  /// The callback function executed when the feature is tapped
  final VoidCallback onTap;

  /// The icon to display for the feature
  final IconData icon;

  /// Optional description of what the feature does
  final String? description;

  /// Optional color for the feature (overrides default group color)
  final Color? color;

  /// Optional tag to show on the feature (e.g. "New", "Popular")
  final String? tag;

  /// Create a new feature
  const Feature({
    required this.name,
    required this.onTap,
    required this.icon,
    this.description,
    this.color,
    this.tag,
  });
}

/// A group of related features
class FeatureGroup {
  /// The title of the group
  final String title;

  /// The icon representing the group
  final IconData icon;

  /// List of features in this group
  final List<Feature> features;

  /// Optional color for the group (used as default for features)
  final Color? color;

  /// Create a new feature group
  const FeatureGroup({
    required this.title,
    required this.icon,
    required this.features,
    this.color,
  });
}
