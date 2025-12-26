import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ================ MODERN COLOR PALETTE ================
  static const Color primaryColor = Color(0xFF3B82F6);     // Modern Blue (Changed from Black)
  static const Color secondaryColor = Color(0xFF8B5CF6);   // Purple
  static const Color accentColor = Color(0xFF10B981);      // Emerald Green
  static const Color warningColor = Color(0xFFF59E0B);     // Amber
  static const Color errorColor = Color(0xFFEF4444);       // Red
  
  static const Color backgroundColor = Color(0xFFF8FAFC);  // Light Blue Gray
  static const Color surfaceColor = Color(0xFFFFFFFF);     // White
  static const Color cardColor = Color(0xFFFFFFFF);        // White with shadow
  
  static const Color textPrimary = Color(0xFF1F2937);      // Dark Gray
  static const Color textSecondary = Color(0xFF6B7280);    // Gray
  static const Color textTertiary = Color(0xFF9CA3AF);     // Light Gray
  
  static const Color borderColor = Color(0xFFE5E7EB);      // Light Border
  static const Color dividerColor = Color(0xFFF3F4F6);     // Divider

  // ================ GRADIENTS ================
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primaryColor, Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get successGradient => LinearGradient(
    colors: [accentColor, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ================ SHADOWS ================
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0x0A000000),
      blurRadius: 20,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primaryColor.withOpacity(0.2),
      blurRadius: 10,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  // ================ BORDER RADIUS ================
  static BorderRadius get smallRadius => BorderRadius.circular(8);
  static BorderRadius get mediumRadius => BorderRadius.circular(12);
  static BorderRadius get largeRadius => BorderRadius.circular(16);
  static BorderRadius get xlRadius => BorderRadius.circular(24);
  static BorderRadius get fullRadius => BorderRadius.circular(999);

  // ================ PADDING ================
  static EdgeInsets get smallPadding => const EdgeInsets.all(8);
  static EdgeInsets get mediumPadding => const EdgeInsets.all(12);
  static EdgeInsets get largePadding => const EdgeInsets.all(16);
  static EdgeInsets get xlPadding => const EdgeInsets.all(24);

  // ================ TEXT STYLES ================
  static TextStyle get heading1 => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.2,
  );
  
  static TextStyle get heading2 => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.3,
  );
  
  static TextStyle get heading3 => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );
  
  static TextStyle get heading4 => GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );
  
  static TextStyle get bodySmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    height: 1.5,
  );
  
  static TextStyle get buttonText => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );
  
  static TextStyle get priceText => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: primaryColor,
  );
  
  static TextStyle get salePriceText => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: errorColor,
  );
  
  static TextStyle get badgeText => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  // ================ MAIN THEME ================
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: Colors.white,
      ),
      
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      
      // Text Theme
      textTheme: TextTheme(
        displayLarge: heading1,
        displayMedium: heading2,
        displaySmall: heading3,
        headlineMedium: heading4,
        headlineSmall: heading4,
        titleLarge: heading4,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: buttonText,
        labelMedium: buttonText.copyWith(fontSize: 14),
        labelSmall: buttonText.copyWith(fontSize: 12),
      ),
      
      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: heading4.copyWith(color: textPrimary),
        surfaceTintColor: Colors.transparent,
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: largeRadius),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: buttonText,
          shadowColor: primaryColor.withOpacity(0.3),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: largeRadius),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: buttonText.copyWith(color: primaryColor),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: buttonText.copyWith(color: primaryColor),
          shape: RoundedRectangleBorder(borderRadius: largeRadius),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      // Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: mediumRadius,
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: mediumRadius,
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: mediumRadius,
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: mediumRadius,
          borderSide: const BorderSide(color: errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: mediumRadius,
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        hintStyle: bodyMedium.copyWith(color: textTertiary),
        labelStyle: bodyMedium.copyWith(color: textSecondary),
        errorStyle: bodySmall.copyWith(color: errorColor),
      ),
      
      // Cards
      cardTheme: const CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: largeRadius,
          side: const BorderSide(color: borderColor, width: 1),
        ),
        color: surfaceColor,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
      ),
      
      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: textTertiary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: bodySmall.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: bodySmall,
      ),
      
      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: largeRadius),
      ),
      
      // Dividers
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 0,
      ),
      
      // Progress Indicators
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
        linearTrackColor: Color(0xFFE5E7EB),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF3F4F6),
        selectedColor: primaryColor,
        labelStyle: bodySmall.copyWith(fontWeight: FontWeight.w500),
        secondaryLabelStyle: bodySmall.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: fullRadius),
      ),
    );
  }

  // ================ DARK THEME ================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF60A5FA),      // Lighter Blue
        secondary: Color(0xFFA78BFA),    // Lighter Purple
        tertiary: Color(0xFF34D399),     // Lighter Green
        surface: Color(0xFF1F2937),      // Dark Surface
        background: Color(0xFF111827),   // Dark Background
        error: Color(0xFFF87171),        // Light Red
      ),
      
      scaffoldBackgroundColor: const Color(0xFF111827),
      cardColor: const Color(0xFF1F2937),
      
      textTheme: TextTheme(
        displayLarge: heading1.copyWith(color: Colors.white),
        displayMedium: heading2.copyWith(color: Colors.white),
        displaySmall: heading3.copyWith(color: Colors.white),
        headlineMedium: heading4.copyWith(color: Colors.white),
        bodyLarge: bodyLarge.copyWith(color: const Color(0xFFD1D5DB)),
        bodyMedium: bodyMedium.copyWith(color: const Color(0xFF9CA3AF)),
        bodySmall: bodySmall.copyWith(color: const Color(0xFF6B7280)),
      ),
    );
  }
}