import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFFFF7043); // Coral orange
  static const Color secondaryColor = Color(0xFF2196F3); // Blue
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color warningColor = Color(0xFFFFC107); // Yellow
  static const Color errorColor = Color(0xFFF44336); // Red
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF1E1E1E);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF2C2C2C);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFFFFFFFF);

  // Border Radius
  static const double borderRadius = 12.0;
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusLarge = 16.0;

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Font Sizes
  static const double fontSizeSmall = 14.0;
  static const double fontSizeMedium = 16.0;
  static const double fontSizeLarge = 18.0;
  static const double fontSizeXL = 24.0;
  static const double fontSizeXXL = 32.0;

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: cardLight,
      error: errorColor,
      onPrimary: textLight,
      onSecondary: textLight,
      onSurface: textPrimary,
      onError: textLight,
    ),
    scaffoldBackgroundColor: backgroundLight,
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: fontSizeXXL,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: fontSizeXL,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: fontSizeLarge,
        color: textPrimary,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: fontSizeMedium,
        color: textPrimary,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: fontSizeSmall,
        color: textSecondary,
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: fontSizeMedium,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardLight,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textLight,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingM,
      ),
      hintStyle: GoogleFonts.poppins(
        color: textSecondary,
        fontSize: fontSizeMedium,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: cardLight,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: textPrimary),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: fontSizeLarge,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: cardLight,
      selectedItemColor: primaryColor,
      unselectedItemColor: textSecondary,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: textLight,
      elevation: 4,
    ),
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: cardDark,
      error: errorColor,
      onPrimary: textLight,
      onSecondary: textLight,
      onSurface: textLight,
      onError: textLight,
    ),
    scaffoldBackgroundColor: backgroundDark,
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.poppins(
        fontSize: fontSizeXXL,
        fontWeight: FontWeight.bold,
        color: textLight,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: fontSizeXL,
        fontWeight: FontWeight.bold,
        color: textLight,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: fontSizeLarge,
        color: textLight,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: fontSizeMedium,
        color: textLight,
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: fontSizeSmall,
        color: Colors.grey[400],
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: fontSizeMedium,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
    ),
    cardTheme: CardThemeData(
      color: cardDark,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: textLight,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: primaryColor, width: 1.5),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingL,
          vertical: spacingM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[850],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacingM,
        vertical: spacingM,
      ),
      hintStyle: GoogleFonts.poppins(
        color: Colors.grey[500],
        fontSize: fontSizeMedium,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: cardDark,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: textLight),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: fontSizeLarge,
        fontWeight: FontWeight.w600,
        color: textLight,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: cardDark,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey[500],
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 12,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: textLight,
      elevation: 4,
    ),
  );
}
