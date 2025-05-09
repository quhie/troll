import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // App colors - Updated to vibrant troll-like colors
  static const Color primaryColor = Color(0xFF8E24AA); // Bright purple
  static const Color secondaryColor = Color(0xFF76FF03); // Lime green
  static const Color accentColor = Color(0xFF00E5FF); // Neon blue
  static const Color highlightColor = Color(0xFFFF4081); // Hot pink
  static const Color energyColor = Color(0xFFFFEA00); // Electric yellow
  static const Color errorColor = Color(0xFFFF3D00); // Vivid red for error screens
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color cardColor = Colors.white;
  static const Color textColor = Color(0xFF212121);
  
  // Dark theme colors - more intense for "Evil Troll Mode"
  static const Color darkPrimaryColor = Color(0xFF6A1B9A); // Darker purple 
  static const Color darkSecondaryColor = Color(0xFF64DD17); // Darker lime
  static const Color darkAccentColor = Color(0xFF00B8D4); // Darker neon blue
  static const Color darkHighlightColor = Color(0xFFF50057); // Darker hot pink
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkTextColor = Color(0xFFEEEEEE);
  
  // Gradients for backgrounds
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryColor, Color(0xFF6A1B9A)],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryColor, Color(0xFF64DD17)],
  );
  
  static const LinearGradient energyGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [energyColor, highlightColor],
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkPrimaryColor, Color(0xFF4A148C)],
  );
  
  // Get theme data
  static ThemeData lightTheme() {
    return ThemeData(
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      // Use Google Fonts for playful typography
      textTheme: GoogleFonts.chewyTextTheme().apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primaryColor,
          elevation: 5,
          shadowColor: primaryColor.withOpacity(0.5),
          // Exaggerated rounded corners
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 8,
        shadowColor: primaryColor.withOpacity(0.4),
        // Exaggerated rounded corners
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.luckiestGuy(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 28,
        ),
      ),
      // Update button styles
      iconTheme: IconThemeData(
        color: primaryColor,
        size: 28,
      ),
    );
  }
  
  static ThemeData darkTheme() {
    return ThemeData(
      primaryColor: darkPrimaryColor,
      colorScheme: ColorScheme.dark(
        primary: darkPrimaryColor,
        secondary: darkSecondaryColor,
        tertiary: darkAccentColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: darkBackgroundColor,
      // Use same playful fonts for dark theme
      textTheme: GoogleFonts.chewyTextTheme().apply(
        bodyColor: darkTextColor,
        displayColor: darkTextColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: darkPrimaryColor,
          elevation: 5,
          shadowColor: darkHighlightColor.withOpacity(0.5),
          // Exaggerated rounded corners
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
        ),
      ),
      cardTheme: CardTheme(
        color: darkCardColor,
        elevation: 8,
        shadowColor: darkHighlightColor.withOpacity(0.5),
        // Exaggerated rounded corners
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.luckiestGuy(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
          size: 28,
        ),
      ),
      // Update button styles
      iconTheme: IconThemeData(
        color: darkHighlightColor,
        size: 28,
      ),
    );
  }
} 