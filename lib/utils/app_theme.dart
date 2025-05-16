import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/preferences_service.dart';

/// App color theme and style definitions
class AppTheme {
  // Primary and accent colors
  static const Color primaryColor = Color(0xFF4A6FE5);
  static const Color secondaryColor = Color(0xFF6C63FF);
  static const Color accentColor = Color(0xFFFF5252);
  
  // Background colors
  static const Color lightBackgroundColor = Color(0xFFF8F9FA);
  static const Color darkBackgroundColor = Color(0xFF121212);
  
  // Surface colors (for cards and raised elements)
  static const Color lightSurfaceColor = Colors.white;
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  
  // Text colors
  static const Color lightTextColor = Color(0xFF333333);
  static const Color lightSecondaryTextColor = Color(0xFF757575);
  static const Color darkTextColor = Color(0xFFF5F5F5);
  static const Color darkSecondaryTextColor = Color(0xFFB0B0B0);
  
  // Category colors with improved contrast
  static final Map<String, Color> categoryColors = {
    'phone': const Color(0xFF4A6FE5),     // Blue
    'game': const Color(0xFF43A047),      // Green
    'horror': const Color(0xFFE53935),    // Red
    'meme': const Color(0xFFFF9800),      // Orange
    'social': const Color(0xFF9C27B0),    // Purple
    'alarm': const Color(0xFFFF5252),     // Light Red
    'favorite': const Color(0xFFFF4081),  // Pink
  };
  
  // Get a theme based on dark mode setting
  static ThemeData getTheme({required bool isDarkMode}) {
    return isDarkMode ? _darkTheme : _lightTheme;
  }
  
  // Light theme
  static final ThemeData _lightTheme = ThemeData(
      brightness: Brightness.light,
    primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: lightSurfaceColor,
      background: lightBackgroundColor,
      error: accentColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: lightTextColor,
      onBackground: lightTextColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: lightBackgroundColor,
    cardTheme: CardTheme(
      color: lightSurfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
      appBarTheme: const AppBarTheme(
      color: lightSurfaceColor,
        elevation: 0,
      iconTheme: IconThemeData(
        color: lightTextColor,
      ),
      titleTextStyle: TextStyle(
        color: lightTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: lightTextColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: lightTextColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: lightTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: lightTextColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: lightTextColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: lightTextColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: lightTextColor,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        color: lightSecondaryTextColor,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        color: lightSecondaryTextColor,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    ),
    buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    ),
    iconTheme: const IconThemeData(
      color: lightTextColor,
      size: 24,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade300,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: lightSurfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: lightSecondaryTextColor,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: lightSurfaceColor,
      selectedIconTheme: const IconThemeData(
        color: primaryColor,
      ),
      unselectedIconTheme: IconThemeData(
        color: Colors.grey.shade600,
      ),
      selectedLabelTextStyle: const TextStyle(
        color: primaryColor,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 14,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.grey.shade900,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: primaryColor,
      unselectedLabelColor: Colors.grey.shade600,
      indicatorColor: primaryColor,
      indicatorSize: TabBarIndicatorSize.tab,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      waitDuration: const Duration(milliseconds: 500),
      showDuration: const Duration(seconds: 2),
      preferBelow: true,
      enableFeedback: true,
    ),
  );
  
  // Dark theme
  static final ThemeData _darkTheme = ThemeData(
      brightness: Brightness.dark,
    primaryColor: primaryColor,
      colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: darkSurfaceColor,
      background: darkBackgroundColor,
      error: accentColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: darkTextColor,
      onBackground: darkTextColor,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
    cardTheme: CardTheme(
      color: darkSurfaceColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
      appBarTheme: const AppBarTheme(
      color: darkSurfaceColor,
        elevation: 0,
      iconTheme: IconThemeData(
        color: darkTextColor,
      ),
      titleTextStyle: TextStyle(
        color: darkTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: darkTextColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: darkTextColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: darkTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleLarge: TextStyle(
        color: darkTextColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: darkTextColor,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      titleSmall: TextStyle(
        color: darkTextColor,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: darkTextColor,
        fontSize: 16,
        fontWeight: FontWeight.normal,
      ),
      bodyMedium: TextStyle(
        color: darkSecondaryTextColor,
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      bodySmall: TextStyle(
        color: darkSecondaryTextColor,
        fontSize: 12,
        fontWeight: FontWeight.normal,
      ),
    ),
    buttonTheme: ButtonThemeData(
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    ),
    iconTheme: const IconThemeData(
      color: darkTextColor,
      size: 24,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade800,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: darkSurfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: darkSecondaryTextColor,
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: darkSurfaceColor,
      selectedIconTheme: const IconThemeData(
        color: primaryColor,
      ),
      unselectedIconTheme: IconThemeData(
        color: Colors.grey.shade400,
      ),
      selectedLabelTextStyle: const TextStyle(
        color: primaryColor,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelTextStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 14,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade900,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.grey.shade800,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    tabBarTheme: TabBarTheme(
      labelColor: primaryColor,
      unselectedLabelColor: Colors.grey.shade400,
      indicatorColor: primaryColor,
      indicatorSize: TabBarIndicatorSize.tab,
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      waitDuration: const Duration(milliseconds: 500),
      showDuration: const Duration(seconds: 2),
      preferBelow: true,
      enableFeedback: true,
    ),
  );
  
  // Method to get the appropriate color based on category name
  static Color getCategoryColor(String categoryName) {
    return categoryColors[categoryName.toLowerCase()] ?? primaryColor;
  }
  
  // Method to get a color with better contrast
  static Color getTextColorForBackground(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}

// Custom class for a frosted glass effect
class FrostedGlassBox extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final Color color;
  final double blur;
  
  const FrostedGlassBox({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.borderRadius = 20.0,
    this.color = Colors.white,
    this.blur = 10.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color.withAlpha(51), // 0.2 * 255 = 51
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: color.withAlpha(77), // 0.3 * 255 = 77
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// Custom painter for blob shapes
class BlobPainter extends CustomPainter {
  final Color color;
  final int numPoints;
  final double minRadius;
  final double maxRadius;
  final double animValue;
  
  BlobPainter({
    required this.color,
    this.numPoints = 8,
    this.minRadius = 50.0,
    this.maxRadius = 100.0,
    this.animValue = 0.0,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    final pathMetrics = _createBlobPath(center, size).computeMetrics();
    final path = Path();
    
    for (final metric in pathMetrics) {
      path.addPath(
        metric.extractPath(0, metric.length),
        Offset.zero,
      );
    }
    
    canvas.drawPath(path, paint);
  }
  
  Path _createBlobPath(Offset center, Size size) {
    final path = Path();
    // Using a constant seed for reproducibility
    final angleStep = 2 * pi / numPoints;
    
    List<Offset> points = [];
    for (int i = 0; i < numPoints; i++) {
      final theta = i * angleStep;
      final radiusVariation = sin(theta * 3 + animValue * 2 * pi) * (maxRadius - minRadius) / 4;
      final radius = minRadius + (maxRadius - minRadius) / 2 + radiusVariation;
      
      final x = center.dx + radius * cos(theta);
      final y = center.dy + radius * sin(theta);
      points.add(Offset(x, y));
    }
    
    path.moveTo(points[0].dx, points[0].dy);
    
    for (int i = 0; i < points.length; i++) {
      final current = points[i];
      final next = points[(i + 1) % points.length];
      final controlPoint1 = Offset(
        current.dx + (next.dx - current.dx) / 3,
        current.dy + (next.dy - current.dy) / 3,
      );
      final controlPoint2 = Offset(
        current.dx + 2 * (next.dx - current.dx) / 3,
        current.dy + 2 * (next.dy - current.dy) / 3,
      );
      
      path.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        next.dx, next.dy,
      );
    }
    
    path.close();
    return path;
  }
  
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// Class for creating morphing blob buttons
class MorphingBlob extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color color;
  final double size;
  
  const MorphingBlob({
    super.key,
    required this.child,
    required this.onTap,
    required this.color,
    this.size = 100.0,
  });
  
  @override
  State<MorphingBlob> createState() => _MorphingBlobState();
}

class _MorphingBlobState extends State<MorphingBlob> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: BlobPainter(
                    color: widget.color,
                    animValue: _controller.value,
                  ),
                ),
                child!,
              ],
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
} 