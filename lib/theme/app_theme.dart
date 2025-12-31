import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ✅ Dark Mode ko chalane ke liye Ye Provider Class add ki hai
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme(bool isOn) {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class AppTheme {
  // ================ MODERN COLOR PALETTE ================
  static const Color primaryColor = Color(0xFF3B82F6);     // Modern Blue
  static const Color secondaryColor = Color(0xFF8B5CF6);   // Purple
  static const Color accentColor = Color(0xFF10B981);      // Emerald Green
  static const Color warningColor = Color(0xFFF59E0B);     // Amber
  static const Color errorColor = Color(0xFFEF4444);       // Red
  static const Color successColor = Color(0xFF10B981);     // Green for success
  
  static const Color backgroundColor = Color(0xFFF8FAFC);  // Light Blue Gray
  static const Color surfaceColor = Color(0xFFFFFFFF);     // White
  static const Color cardColor = Color(0xFFFFFFFF);        // White
  
  static const Color textPrimary = Color(0xFF1F2937);      // Dark Gray
  static const Color textSecondary = Color(0xFF6B7280);    // Gray
  static const Color textTertiary = Color(0xFF9CA3AF);     // Light Gray
  
  static const Color borderColor = Color(0xFFE5E7EB);      // Light Border
  static const Color dividerColor = Color(0xFFF3F4F6);     // Divider
  static const Color shimmerColor = Color(0xFFE5E7EB);     // Shimmer/Placeholder

  // ================ PRODUCT SPECIFIC COLORS ================
  static const Color saleBadgeColor = Color(0xFFEF4444);   // Red for SALE badge
  static const Color newBadgeColor = Color(0xFF10B981);    // Green for NEW badge
  static const Color bestsellerBadgeColor = Color(0xFF3B82F6); // Blue for BEST SELLER
  static const Color limitedBadgeColor = Color(0xFF8B5CF6); // Purple for LIMITED
  
  static const Color stockWarningColor = Color(0xFFF59E0B); // Orange for low stock
  static const Color outOfStockColor = Color(0xFFEF4444);  // Red for out of stock
  
  // ================ GRADIENTS ================
  static LinearGradient get primaryGradient => const LinearGradient(
    colors: [primaryColor, Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get successGradient => const LinearGradient(
    colors: [accentColor, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get saleGradient => const LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static LinearGradient get premiumGradient => const LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ================ SHADOWS ================
  static List<BoxShadow> get cardShadow => [
    const BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 20,
      offset: Offset(0, 4),
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
  
  static List<BoxShadow> get productCardShadow => [
    const BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 15,
      offset: Offset(0, 6),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get floatingShadow => [
    const BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 25,
      offset: Offset(0, 10),
      spreadRadius: 0,
    ),
  ];

  // ================ BORDER RADIUS ================
  static BorderRadius get xsRadius => BorderRadius.circular(6);
  static BorderRadius get smallRadius => BorderRadius.circular(8);
  static BorderRadius get mediumRadius => BorderRadius.circular(12);
  static BorderRadius get largeRadius => BorderRadius.circular(16);
  static BorderRadius get xlRadius => BorderRadius.circular(20);
  static BorderRadius get xxlRadius => BorderRadius.circular(24);
  static BorderRadius get fullRadius => BorderRadius.circular(999);

  // ================ PADDING ================
  static EdgeInsets get xsPadding => const EdgeInsets.all(4);
  static EdgeInsets get smallPadding => const EdgeInsets.all(8);
  static EdgeInsets get mediumPadding => const EdgeInsets.all(12);
  static EdgeInsets get largePadding => const EdgeInsets.all(16);
  static EdgeInsets get xlPadding => const EdgeInsets.all(20);
  static EdgeInsets get xxlPadding => const EdgeInsets.all(24);
  
  static EdgeInsets get screenPadding => const EdgeInsets.symmetric(horizontal: 16);
  static EdgeInsets get cardPadding => const EdgeInsets.all(12);

  // ================ TEXT STYLES ================
  static TextStyle get heading1 => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w800, 
    color: textPrimary,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  static TextStyle get heading2 => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.3,
    letterSpacing: -0.3,
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
  
  static TextStyle get heading5 => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );
  
  static TextStyle get heading6 => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );
  
  static TextStyle get bodyLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.6, 
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
  
  static TextStyle get caption => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    height: 1.4,
  );
  
  // ================ BUTTON TEXT STYLES ================
  static TextStyle get buttonLarge => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.5,
  );
  
  static TextStyle get buttonMedium => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.3,
  );
  
  static TextStyle get buttonSmall => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );
  
  // ================ PRODUCT TEXT STYLES ================
  static TextStyle get productName => GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.3,
  );
  
  static TextStyle get productPrice => GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: primaryColor,
  );
  
  static TextStyle get productSalePrice => GoogleFonts.inter(
    fontSize: 20, 
    fontWeight: FontWeight.w800,
    color: saleBadgeColor,
  );
  
  static TextStyle get productOriginalPrice => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textTertiary,
    decoration: TextDecoration.lineThrough,
  );
  
  static TextStyle get productBadge => GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w800,
    color: Colors.white,
    letterSpacing: 0.8,
  );
  
  static TextStyle get stockWarningText => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: stockWarningColor,
    letterSpacing: 0.3,
  );
  
  static TextStyle get outOfStockText => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.3,
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
        headlineSmall: heading5,
        titleLarge: heading5,
        titleMedium: heading6,
        titleSmall: heading6.copyWith(fontSize: 14),
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: buttonLarge,
        labelMedium: buttonMedium,
        labelSmall: buttonSmall,
      ),
      
      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: heading6.copyWith(color: textPrimary),
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 1,
      ),
      
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: mediumRadius),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: buttonMedium,
          shadowColor: primaryColor.withOpacity(0.3),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: mediumRadius),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: buttonMedium.copyWith(color: primaryColor),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: buttonMedium.copyWith(color: primaryColor),
          shape: RoundedRectangleBorder(borderRadius: mediumRadius),
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
      // ✅ FIX: Use CardThemeData
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: largeRadius,
          side: const BorderSide(color: borderColor, width: 1),
        ),
        color: surfaceColor,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
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
        showSelectedLabels: true,
        showUnselectedLabels: true,
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
        circularTrackColor: Color(0xFFE5E7EB),
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFF3F4F6),
        selectedColor: primaryColor,
        disabledColor: textTertiary.withOpacity(0.1),
        labelStyle: bodySmall.copyWith(fontWeight: FontWeight.w500),
        secondaryLabelStyle: bodySmall.copyWith(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: fullRadius),
        side: BorderSide.none,
        checkmarkColor: Colors.white,
      ),
      
      // Dialog Theme
      // ✅ FIX: Use DialogThemeData
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: xlRadius),
        titleTextStyle: heading5,
        contentTextStyle: bodyMedium,
      ),
      
      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: bodyMedium.copyWith(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: mediumRadius),
        elevation: 6,
      ),
      
      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        modalBackgroundColor: surfaceColor,
        modalElevation: 16,
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
        headlineSmall: heading5.copyWith(color: Colors.white),
        titleLarge: heading5.copyWith(color: Colors.white),
        titleMedium: heading6.copyWith(color: Colors.white),
        titleSmall: heading6.copyWith(fontSize: 14, color: Colors.white),
        bodyLarge: bodyLarge.copyWith(color: const Color(0xFFD1D5DB)),
        bodyMedium: bodyMedium.copyWith(color: const Color(0xFF9CA3AF)),
        bodySmall: bodySmall.copyWith(color: const Color(0xFF6B7280)),
        labelLarge: buttonLarge.copyWith(color: Colors.white),
        labelMedium: buttonMedium.copyWith(color: Colors.white),
        labelSmall: buttonSmall.copyWith(color: Colors.white),
      ),
      
      // ✅ FIX: Use CardThemeData
      cardTheme: CardThemeData(
        color: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(
          borderRadius: largeRadius,
          side: const BorderSide(color: Color(0xFF374151), width: 1),
        ),
      ),
    );
  }
  
  // ================ HELPER METHODS ================
  static Color getBadgeColor(String badgeType) {
    switch (badgeType.toLowerCase()) {
      case 'sale':
        return saleBadgeColor;
      case 'new':
        return newBadgeColor;
      case 'best seller':
      case 'bestseller':
        return bestsellerBadgeColor;
      case 'limited':
      case 'limited edition':
        return limitedBadgeColor;
      default:
        return primaryColor;
    }
  }
  
  static TextStyle getBadgeTextStyle(String badgeType) {
    return productBadge.copyWith(
      color: Colors.white,
      backgroundColor: getBadgeColor(badgeType),
    );
  }
}