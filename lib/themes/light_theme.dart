import 'package:flutter/material.dart';

class Primary {
  static const Color backgroundColor = Colors.white;
  static const Color accentColor = Colors.orange;
  static const Color primaryColor = Colors.lightGreen;
  static const TextStyle paragraph = TextStyle(
    color: Colors.black,
  );
  static const TextStyle orangeParagraph = TextStyle(
    color: Colors.lightGreen,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle bigHeading = TextStyle(
    color: Colors.black,
    fontSize: 20,
  );
  static const TextStyle bigWhiteHeading = TextStyle(
    color: Colors.white,
    fontSize: 22,
  );
  static const TextStyle whiteText = TextStyle(
    color: Colors.white,
  );
  static const TextStyle cardText = TextStyle(
    color: Colors.black,
    fontSize: 11,
  );
  static const TextStyle lightParagraph = TextStyle(
    color: Colors.black54,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle heading = TextStyle(
      color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0);
  static const TextStyle shawarmaHeading = TextStyle(
      color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16.0);
  static ThemeData primaryTheme = ThemeData(
      backgroundColor: Colors.white,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.white,
        elevation: 10,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: TextStyle(color: Colors.black),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.white,
        elevation: 10,
        modalBackgroundColor: Colors.black.withOpacity(.6),
        modalElevation: 15,
      ),
      errorColor: Colors.black,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        elevation: 10,
        enableFeedback: true,
      ),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.orange)
          .copyWith(secondary: Colors.black));
}
