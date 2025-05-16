import 'package:flutter/material.dart';

/// A responsive grid layout that adapts to the available screen width
///
/// This widget dynamically calculates the number of columns based on
/// the screen width and the minimum width of each child.
class ResponsiveGrid extends StatelessWidget {
  /// The list of widgets to display in the grid
  final List<Widget> children;

  /// The minimum width required for each child
  final double minChildWidth;

  /// The spacing between children
  final double spacing;

  /// The cross-axis spacing between children
  final double crossAxisSpacing;

  /// The main-axis spacing between children
  final double mainAxisSpacing;

  /// The amount of padding around the grid
  final EdgeInsetsGeometry padding;

  /// The aspect ratio of each child (width/height)
  final double childAspectRatio;

  /// Whether to use SliverGrid or regular Grid
  final bool asSliver;

  const ResponsiveGrid({
    Key? key,
    required this.children,
    this.minChildWidth = 300,
    this.spacing = 16,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
    this.padding = const EdgeInsets.all(16),
    this.childAspectRatio = 1.0,
    this.asSliver = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Return appropriate grid type based on asSliver flag
    return asSliver
        ? _buildSliverGrid(context)
        : Padding(padding: padding, child: _buildRegularGrid(context));
  }

  /// Builds a SliverGrid for use in CustomScrollView
  SliverPadding _buildSliverGrid(BuildContext context) {
    return SliverPadding(
      padding: padding,
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: minChildWidth,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        delegate: SliverChildListDelegate(children),
      ),
    );
  }

  /// Builds a regular GridView
  Widget _buildRegularGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate optimal column count based on available width
        final width = constraints.maxWidth;
        final columnCount = (width / (minChildWidth + spacing)).floor();
        final adjustedColumnCount = columnCount > 0 ? columnCount : 1;

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: adjustedColumnCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
          children: children,
        );
      },
    );
  }
}

/// An extension to GridView for creating responsive grids more easily
extension ResponsiveGridExtension on GridView {
  /// Creates a responsive grid that adjusts columns based on screen width
  static Widget responsive({
    required List<Widget> children,
    double minChildWidth = 300,
    double spacing = 16,
    double crossAxisSpacing = 16,
    double mainAxisSpacing = 16,
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
    double childAspectRatio = 1.0,
    ScrollPhysics? physics,
    bool shrinkWrap = false,
  }) {
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final columnCount = (width / minChildWidth).floor();
          final adjustedColumnCount = columnCount > 0 ? columnCount : 1;

          return GridView.count(
            shrinkWrap: shrinkWrap,
            physics: physics,
            crossAxisCount: adjustedColumnCount,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: childAspectRatio,
            children: children,
          );
        },
      ),
    );
  }
}
