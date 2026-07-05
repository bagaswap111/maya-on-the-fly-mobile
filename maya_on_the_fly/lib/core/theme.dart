import 'package:flutter/material.dart';
import '../design/tokens.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: DesignTokens.primary,
        onPrimary: DesignTokens.onPrimary,
        secondary: DesignTokens.signatureCoral,
        surface: DesignTokens.canvas,
        onSurface: DesignTokens.ink,
        error: DesignTokens.signatureCoral,
      ),
      scaffoldBackgroundColor: DesignTokens.canvas,
      appBarTheme: const AppBarTheme(
        backgroundColor: DesignTokens.canvas,
        foregroundColor: DesignTokens.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: DesignTokens.titleMd,
          fontWeight: FontWeight.w400,
          color: DesignTokens.ink,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DesignTokens.canvas,
        selectedItemColor: DesignTokens.primary,
        unselectedItemColor: DesignTokens.muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: DesignTokens.displayXl, fontWeight: FontWeight.w500, color: DesignTokens.ink),
        displayMedium: TextStyle(fontSize: DesignTokens.displayMd, fontWeight: FontWeight.w400, color: DesignTokens.ink),
        headlineLarge: TextStyle(fontSize: DesignTokens.titleLg, fontWeight: FontWeight.w400, color: DesignTokens.ink),
        headlineMedium: TextStyle(fontSize: DesignTokens.titleMd, fontWeight: FontWeight.w400, color: DesignTokens.ink),
        titleMedium: TextStyle(fontSize: DesignTokens.titleSm, fontWeight: FontWeight.w500, color: DesignTokens.ink),
        labelLarge: TextStyle(fontSize: DesignTokens.buttonSize, fontWeight: FontWeight.w500, color: DesignTokens.ink),
        bodyMedium: TextStyle(fontSize: DesignTokens.bodyMd, fontWeight: FontWeight.w400, color: DesignTokens.body),
        bodySmall: TextStyle(fontSize: DesignTokens.caption, fontWeight: FontWeight.w500, color: DesignTokens.muted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.primary,
          foregroundColor: DesignTokens.onPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusLg)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: DesignTokens.buttonSize, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DesignTokens.ink,
          side: const BorderSide(color: DesignTokens.hairline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusLg)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: DesignTokens.buttonSize, fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          borderSide: const BorderSide(color: DesignTokens.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          borderSide: const BorderSide(color: DesignTokens.infoBorder, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          borderSide: const BorderSide(color: DesignTokens.signatureCoral, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor: DesignTokens.canvas,
      ),
      dividerTheme: const DividerThemeData(
        color: DesignTokens.hairline,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: DesignTokens.surfaceSoft,
        labelStyle: const TextStyle(fontSize: DesignTokens.bodyMd, color: DesignTokens.body),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusSm)),
        side: const BorderSide(color: DesignTokens.hairline),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: DesignTokens.canvas,
        onPrimary: DesignTokens.primary,
        secondary: DesignTokens.signatureCoral,
        surface: DesignTokens.surfaceDark,
        onSurface: DesignTokens.onDark,
        error: DesignTokens.signatureCoral,
      ),
      scaffoldBackgroundColor: DesignTokens.surfaceDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: DesignTokens.surfaceDark,
        foregroundColor: DesignTokens.onDark,
        elevation: 0,
        centerTitle: false,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DesignTokens.surfaceDark,
        selectedItemColor: DesignTokens.onDark,
        unselectedItemColor: DesignTokens.muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: DesignTokens.bodyMd, fontWeight: FontWeight.w400, color: DesignTokens.onDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignTokens.canvas,
          foregroundColor: DesignTokens.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignTokens.radiusLg)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          borderSide: const BorderSide(color: DesignTokens.borderStrong),
        ),
      ),
      dividerTheme: const DividerThemeData(color: DesignTokens.borderStrong, thickness: 1),
    );
  }
}
