
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor = Color(0xFF3899FA);
const Color textColor = Color(0xFF171A1F);
const Color secondaryTextColor = Color(0xFF565D6D);
const Color backgroundColor = Color(0xFFFFFFFF);
const Color lightBlueBackground = Color(0xFFF0F7FF);
const Color lightYellowBackground = Color(0xFFF9F7E2);
const Color successColor = Color(0xFF20DF60);
const Color errorColor = Color(0xFFEB4747);
const Color warningColor = Color(0xFFD7CA42);

final ThemeData appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryColor,
    primary: primaryColor,
    secondary: primaryColor,
    error: errorColor,
    surface: backgroundColor,
    brightness: Brightness.light,
  ),
  textTheme: GoogleFonts.interTextTheme(
    ThemeData.light().textTheme,
  ).copyWith(
    displayLarge: GoogleFonts.manrope(
      color: textColor,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: GoogleFonts.manrope(
      color: textColor,
      fontWeight: FontWeight.bold,
    ),
    displaySmall: GoogleFonts.manrope(
      color: textColor,
      fontWeight: FontWeight.bold,
    ),
    headlineLarge: GoogleFonts.manrope(
      color: textColor,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: GoogleFonts.manrope(
      color: textColor,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: GoogleFonts.manrope(
      color: textColor,
      fontWeight: FontWeight.bold,
    ),
    titleLarge: GoogleFonts.inter(
      color: textColor,
      fontWeight: FontWeight.w600,
    ),
    titleMedium: GoogleFonts.inter(
      color: textColor,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: GoogleFonts.inter(
      color: textColor,
      fontWeight: FontWeight.w600,
    ),
    bodyLarge: GoogleFonts.inter(
      color: secondaryTextColor,
    ),
    bodyMedium: GoogleFonts.inter(
      color: secondaryTextColor,
    ),
    bodySmall: GoogleFonts.inter(
      color: secondaryTextColor,
    ),
    labelLarge: GoogleFonts.inter(
      color: textColor,
      fontWeight: FontWeight.w600,
    ),
    labelMedium: GoogleFonts.inter(
      color: textColor,
    ),
    labelSmall: GoogleFonts.inter(
      color: textColor,
    ),
  ),
  scaffoldBackgroundColor: backgroundColor,
  appBarTheme: const AppBarTheme(
    backgroundColor: backgroundColor,
    elevation: 0,
    iconTheme: IconThemeData(color: textColor),
  ),
  buttonTheme: ButtonThemeData(
    buttonColor: primaryColor,
    textTheme: ButtonTextTheme.primary,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.0),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(
        color: secondaryTextColor,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: const BorderSide(
        color: primaryColor,
      ),
    ),
    labelStyle: GoogleFonts.inter(
      color: secondaryTextColor,
    ),
  ),
);
