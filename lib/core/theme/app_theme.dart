import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // Define our color palette
  static const Color mintGreen = Color(0xFF98D7C2);
  static const Color lightMintGreen = Color(0xFFDEF5EC);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color mediumGrey = Color(0xFFE0E0E0);
  static const Color darkGrey = Color(0xFF757575);

  // Light theme
  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: mintGreen,
      scaffoldBackgroundColor: white,
      colorScheme: const ColorScheme.light(
        primary: mintGreen,
        secondary: lightMintGreen,
        onPrimary: black,
        onSecondary: black,
        background: white,
        surface: white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: black,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: black),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: mintGreen,
        unselectedLabelColor: darkGrey,
        indicatorColor: mintGreen,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: mintGreen,
        unselectedItemColor: darkGrey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mintGreen,
          foregroundColor: black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: mintGreen,
          side: const BorderSide(color: mintGreen),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: mintGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: mintGreen),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      dividerTheme: const DividerThemeData(
        color: mediumGrey,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: black, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: black, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: black, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: black, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: black, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: black, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: black, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: black, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: black, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: black),
        bodyMedium: TextStyle(color: black),
        bodySmall: TextStyle(color: darkGrey),
        labelLarge: TextStyle(color: black, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: black),
        labelSmall: TextStyle(color: darkGrey),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: mintGreen,
        barBackgroundColor: white,
        scaffoldBackgroundColor: white,
        textTheme: CupertinoTextThemeData(
          primaryColor: mintGreen,
        ),
      ),
    );
  }
}
