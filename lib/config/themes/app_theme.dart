import 'package:flutter/material.dart';

import '/core/constants/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primarySwatch: Colors.blue,
      primaryColor: AppColors.blueColor,
      scaffoldBackgroundColor: AppColors.realWhiteColor,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.black87, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.black87, fontSize: 14),
        bodySmall: TextStyle(color: Colors.black87, fontSize: 12),
        titleLarge: TextStyle(color: Colors.black87, fontSize: 22, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500),
        labelLarge: TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: Colors.black87, fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(color: Colors.black87, fontSize: 10, fontWeight: FontWeight.w500),
        headlineLarge: TextStyle(color: Colors.black87, fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: Colors.black87, fontSize: 28, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold),
        displayLarge: TextStyle(color: Colors.black87, fontSize: 57, fontWeight: FontWeight.w400),
        displayMedium: TextStyle(color: Colors.black87, fontSize: 45, fontWeight: FontWeight.w400),
        displaySmall: TextStyle(color: Colors.black87, fontSize: 36, fontWeight: FontWeight.w400),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.realWhiteColor,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: Colors.black87, fontSize: 16),
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
        helperStyle: const TextStyle(color: Colors.black54, fontSize: 12),
        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.blueColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.realWhiteColor,
        selectedItemColor: AppColors.blueColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: Colors.black87,
          fontSize: 16,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.black87,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      iconTheme: const IconThemeData(
        color: Colors.black87,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primarySwatch: Colors.blue,
      primaryColor: AppColors.blueColor,
      scaffoldBackgroundColor: AppColors.blackColor,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppColors.whiteColor, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.whiteColor, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.whiteColor, fontSize: 12),
        titleLarge: TextStyle(color: AppColors.whiteColor, fontSize: 22, fontWeight: FontWeight.bold),
        titleMedium: TextStyle(color: AppColors.whiteColor, fontSize: 18, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: AppColors.whiteColor, fontSize: 16, fontWeight: FontWeight.w500),
        labelLarge: TextStyle(color: AppColors.whiteColor, fontSize: 14, fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: AppColors.whiteColor, fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: TextStyle(color: AppColors.whiteColor, fontSize: 10, fontWeight: FontWeight.w500),
        headlineLarge: TextStyle(color: AppColors.whiteColor, fontSize: 32, fontWeight: FontWeight.bold),
        headlineMedium: TextStyle(color: AppColors.whiteColor, fontSize: 28, fontWeight: FontWeight.bold),
        headlineSmall: TextStyle(color: AppColors.whiteColor, fontSize: 24, fontWeight: FontWeight.bold),
        displayLarge: TextStyle(color: AppColors.whiteColor, fontSize: 57, fontWeight: FontWeight.w400),
        displayMedium: TextStyle(color: AppColors.whiteColor, fontSize: 45, fontWeight: FontWeight.w400),
        displaySmall: TextStyle(color: AppColors.whiteColor, fontSize: 36, fontWeight: FontWeight.w400),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.blackColor,
        foregroundColor: AppColors.whiteColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.whiteColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.whiteColor),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blueColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: AppColors.whiteColor, fontSize: 16),
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
        helperStyle: const TextStyle(color: Colors.grey, fontSize: 12),
        errorStyle: const TextStyle(color: Colors.red, fontSize: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.blueColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[900],
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.blackColor,
        selectedItemColor: AppColors.blueColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      cardTheme: const CardThemeData(
        color: Colors.black,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: Colors.grey,
        titleTextStyle: TextStyle(
          color: AppColors.whiteColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(
          color: AppColors.whiteColor,
          fontSize: 16,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.grey,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.whiteColor,
      ),
    );
  }
}
