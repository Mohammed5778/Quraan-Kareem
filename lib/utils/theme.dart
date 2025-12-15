import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.teal,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      color: Colors.teal,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.roboto(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.openSans(),
      bodyMedium: GoogleFonts.openSans(),
      displayLarge: GoogleFonts.playfairDisplay(),
      displayMedium: GoogleFonts.playfairDisplay(),
      displaySmall: GoogleFonts.playfairDisplay(),
      headlineMedium: GoogleFonts.playfairDisplay(),
      headlineSmall: GoogleFonts.playfairDisplay(),
      titleLarge: GoogleFonts.playfairDisplay(),
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal).copyWith(secondary: Colors.amber),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.teal[700],
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      color: Colors.grey[800],
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.roboto(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: GoogleFonts.openSans(color: Colors.white),
      bodyMedium: GoogleFonts.openSans(color: Colors.white),
      displayLarge: GoogleFonts.playfairDisplay(color: Colors.white),
      displayMedium: GoogleFonts.playfairDisplay(color: Colors.white),
      displaySmall: GoogleFonts.playfairDisplay(color: Colors.white),
      headlineMedium: GoogleFonts.playfairDisplay(color: Colors.white),
      headlineSmall: GoogleFonts.playfairDisplay(color: Colors.white),
      titleLarge: GoogleFonts.playfairDisplay(color: Colors.white),
    ),
    colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.teal, brightness: Brightness.dark).copyWith(secondary: Colors.amber),
  );
}
