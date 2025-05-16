// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/gestures.dart';
// import 'dart:io' show Platform;
// import '../utils/app_theme.dart';
// import '../utils/app_config.dart';

// /// A responsive scaffold that adapts to different screen sizes
// /// and orientations for better user experience.
// class ResponsiveScaffold extends StatelessWidget {
//   /// Page title to display in the AppBar
//   final String title;

//   /// Main body content
//   final Widget body;

//   /// Optional drawer menu
//   final Widget? drawer;

//   /// Optional AppBar actions
//   final List<Widget>? actions;

//   /// Optional bottom navigation bar items
//   final List<BottomNavigationBarItem>? bottomNavigationBarItems;

//   /// Current selected index for bottom navigation bar
//   final int? currentIndex;

//   /// Callback when bottom navigation tab is tapped
//   final Function(int)? onTabTapped;

//   /// App bar elevation
//   final double appBarElevation;

//   /// Whether to use a transparent app bar
//   final bool transparentAppBar;

//   /// Whether to show a back button instead of drawer button
//   final bool showBackButton;

//   /// Optional floating action button
//   final Widget? floatingActionButton;

//   /// Optional bottom padding
//   final double bottomPadding;

//   /// Optional body padding
//   final EdgeInsetsGeometry? bodyPadding;

//   /// Creates a responsive scaffold
//   const ResponsiveScaffold({
//     Key? key,
//     required this.title,
//     required this.body,
//     this.drawer,
//     this.actions,
//     this.bottomNavigationBarItems,
//     this.currentIndex,
//     this.onTabTapped,
//     this.appBarElevation = 0,
//     this.transparentAppBar = false,
//     this.showBackButton = false,
//     this.floatingActionButton,
//     this.bottomPadding = 0,
//     this.bodyPadding,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final size = MediaQuery.of(context).size;
//     final isTablet = size.width > 600;
//     final isLandscape = size.width > size.height;

//     // Dynamically calculate body padding based on screen size
//     final defaultPadding = bodyPadding ??
//         EdgeInsets.symmetric(
//           horizontal: isTablet ? AppTheme.spacingLarge : AppTheme.spacingMedium,
//           vertical: AppTheme.spacingMedium,
//         );

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           title,
//           style: TextStyle(
//             fontWeight: FontWeight.bold,
//             fontFamily: 'Poppins',
//             fontSize: isTablet ? 22 : 20,
//           ),
//         ),
//         centerTitle: true,
//         elevation: appBarElevation,
//         backgroundColor: transparentAppBar ? Colors.transparent : null,
//         automaticallyImplyLeading: showBackButton,
//         actions: actions,
//       ),
//       drawer: drawer != null && !isLandscape && !isTablet ? drawer : null,
//       body: SafeArea(
//         child: Padding(
//           padding: defaultPadding,
//           child: body,
//         ),
//       ),
//       bottomNavigationBar: bottomNavigationBarItems != null ? Container(
//         decoration: BoxDecoration(
//           color: isDark ? AppTheme.darkSurfaceColor : Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               spreadRadius: 1,
//             ),
//           ],
//         ),
//         child: SafeArea(
//           child: BottomNavigationBar(
//             items: bottomNavigationBarItems!,
//             currentIndex: currentIndex ?? 0,
//             onTap: onTabTapped,
//             backgroundColor: Colors.transparent,
//             selectedItemColor: isDark ? AppTheme.darkPrimaryColor : AppTheme.primaryColor,
//             unselectedItemColor: isDark ? Colors.grey : Colors.grey.shade700,
//             type: BottomNavigationBarType.fixed,
//             elevation: 0,
//             showSelectedLabels: true,
//             showUnselectedLabels: true,
//             selectedLabelStyle: const TextStyle(
//               fontFamily: 'Poppins',
//               fontWeight: FontWeight.w600,
//               fontSize: 12,
//             ),
//             unselectedLabelStyle: const TextStyle(
//               fontFamily: 'Poppins',
//               fontSize: 12,
//             ),
//           ),
//         ),
//       ) : null,
//       floatingActionButton: floatingActionButton,
//     );
//   }
// }

// /// A responsive builder that helps create layouts that adapt to different
// /// screen sizes. Makes it easier to create responsive UIs without repetitive code.
// class ResponsiveBuilder extends StatelessWidget {
//   /// Builder function for small mobile screens (< 600 width)
//   final Widget Function(BuildContext, BoxConstraints) mobileBuilder;

//   /// Optional builder function for tablet screens (>= 600 width)
//   final Widget Function(BuildContext, BoxConstraints)? tabletBuilder;

//   /// Optional builder function for desktop screens (>= 1200 width)
//   final Widget Function(BuildContext, BoxConstraints)? desktopBuilder;

//   /// Creates a responsive builder
//   const ResponsiveBuilder({
//     Key? key,
//     required this.mobileBuilder,
//     this.tabletBuilder,
//     this.desktopBuilder,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         if (constraints.maxWidth >= 1200 && desktopBuilder != null) {
//           return desktopBuilder!(context, constraints);
//         }

//         if (constraints.maxWidth >= 600 && tabletBuilder != null) {
//           return tabletBuilder!(context, constraints);
//         }

//         return mobileBuilder(context, constraints);
//       },
//     );
//   }
// }

// /// Grid helper that changes the number of columns based on available width
// class ResponsiveGrid extends StatelessWidget {
//   /// The list of widgets to display in a grid
//   final List<Widget> children;

//   /// Spacing between items
//   final double spacing;

//   /// Number of columns on mobile screens
//   final int mobileColumns;

//   /// Number of columns on tablet screens
//   final int tabletColumns;

//   /// Number of columns on desktop screens
//   final int desktopColumns;

//   /// Child aspect ratio
//   final double childAspectRatio;

//   /// Creates a responsive grid
//   const ResponsiveGrid({
//     Key? key,
//     required this.children,
//     this.spacing = 16.0,
//     this.mobileColumns = 2,
//     this.tabletColumns = 3,
//     this.desktopColumns = 4,
//     this.childAspectRatio = 1.0,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ResponsiveBuilder(
//       mobileBuilder: (context, constraints) => _buildGrid(mobileColumns),
//       tabletBuilder: (context, constraints) => _buildGrid(tabletColumns),
//       desktopBuilder: (context, constraints) => _buildGrid(desktopColumns),
//     );
//   }

//   Widget _buildGrid(int crossAxisCount) {
//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: crossAxisCount,
//         crossAxisSpacing: spacing,
//         mainAxisSpacing: spacing,
//         childAspectRatio: childAspectRatio,
//       ),
//       itemCount: children.length,
//       itemBuilder: (context, index) => children[index],
//     );
//   }
// }

// /// A responsive scaffold that adapts to different screen sizes and platforms
// class ResponsiveScaffoldOld extends StatelessWidget {
//   /// App bar for the scaffold
//   final PreferredSizeWidget? appBar;

//   /// Body content of the scaffold
//   final Widget body;

//   /// Optional bottom navigation bar
//   final Widget? bottomNavigationBar;

//   /// Optional floating action button
//   final Widget? floatingActionButton;

//   /// Position of the floating action button
//   final FloatingActionButtonLocation? floatingActionButtonLocation;

//   /// Optional bottom sheet
//   final Widget? bottomSheet;

//   /// Optional drawer
//   final Widget? drawer;

//   /// Optional end drawer
//   final Widget? endDrawer;

//   /// Background color of the scaffold
//   final Color? backgroundColor;

//   /// Background image of the scaffold
//   final DecorationImage? backgroundImage;

//   /// Background gradient of the scaffold
//   final Gradient? backgroundGradient;

//   /// Whether to extend the body behind the app bar
//   final bool extendBodyBehindAppBar;

//   /// Whether to resize to avoid the bottom inset
//   final bool? resizeToAvoidBottomInset;

//   /// Whether to use a gradient background
//   final bool useGradientBackground;

//   /// Semantic label for the scaffold
//   final String? semanticLabel;

//   /// Extra safe area inset at the top
//   final double extraTopPadding;

//   const ResponsiveScaffoldOld({
//     Key? key,
//     this.appBar,
//     required this.body,
//     this.bottomNavigationBar,
//     this.floatingActionButton,
//     this.floatingActionButtonLocation,
//     this.bottomSheet,
//     this.drawer,
//     this.endDrawer,
//     this.backgroundColor,
//     this.backgroundImage,
//     this.backgroundGradient,
//     this.extendBodyBehindAppBar = false,
//     this.resizeToAvoidBottomInset,
//     this.useGradientBackground = true,
//     this.semanticLabel,
//     this.extraTopPadding = 0,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final defaultBackground = isDark ? Colors.black : AppTheme.backgroundColor;
//     final defaultGradient = AppTheme.futuristicGradient;

//     // Set status bar style based on theme and platform
//     final statusBarBrightness = isDark ? Brightness.light : Brightness.dark;
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
//       statusBarBrightness: AppConfig.isIOS ? statusBarBrightness : Brightness.light,
//       statusBarIconBrightness: AppConfig.isIOS ? (isDark ? Brightness.light : Brightness.dark) : Brightness.light,
//       statusBarColor: Colors.transparent,
//     ));

//     // Create the scaffold with appropriate configuration
//     Widget scaffoldWidget = Scaffold(
//       appBar: appBar,
//       body: Container(
//         decoration: useGradientBackground
//             ? BoxDecoration(
//                 color: backgroundColor ?? defaultBackground,
//                 image: backgroundImage,
//                 gradient: backgroundGradient ?? defaultGradient,
//               )
//             : null,
//         child: SafeArea(
//           top: !extendBodyBehindAppBar && extraTopPadding <= 0,
//           bottom: true,
//           child: Padding(
//             padding: EdgeInsets.only(top: extraTopPadding),
//             child: body,
//           ),
//         ),
//       ),
//       backgroundColor: useGradientBackground ? null : (backgroundColor ?? defaultBackground),
//       bottomNavigationBar: bottomNavigationBar,
//       floatingActionButton: floatingActionButton,
//       floatingActionButtonLocation: floatingActionButtonLocation,
//       bottomSheet: bottomSheet,
//       drawer: drawer,
//       endDrawer: endDrawer,
//       extendBodyBehindAppBar: extendBodyBehindAppBar,
//       resizeToAvoidBottomInset: resizeToAvoidBottomInset,
//     );

//     // Add semantics if provided
//     if (semanticLabel != null) {
//       return Semantics(
//         label: semanticLabel,
//         child: scaffoldWidget,
//       );
//     }

//     return scaffoldWidget;
//   }

//   /// Factory constructor for creating a scaffold with a cyberpunk theme
//   factory ResponsiveScaffoldOld.cyberpunk({
//     Key? key,
//     PreferredSizeWidget? appBar,
//     required Widget body,
//     Widget? bottomNavigationBar,
//     Widget? floatingActionButton,
//     FloatingActionButtonLocation? floatingActionButtonLocation,
//     Widget? bottomSheet,
//     Color? backgroundColor,
//     bool extendBodyBehindAppBar = false,
//     Widget? drawer,
//     Widget? endDrawer,
//     double extraTopPadding = 0,
//   }) {
//     return ResponsiveScaffoldOld(
//       key: key,
//       appBar: appBar,
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: AppTheme.futuristicGradient,
//         ),
//         child: body,
//       ),
//       bottomNavigationBar: bottomNavigationBar,
//       floatingActionButton: floatingActionButton,
//       floatingActionButtonLocation: floatingActionButtonLocation,
//       bottomSheet: bottomSheet,
//       backgroundColor: backgroundColor,
//       drawer: drawer,
//       endDrawer: endDrawer,
//       extendBodyBehindAppBar: extendBodyBehindAppBar,
//       extraTopPadding: extraTopPadding,
//     );
//   }
// }
