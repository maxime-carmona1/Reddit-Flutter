import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xffff6100);
  static const Color secondary = Color(0xff12d4d4);
  static const Color textColor = Color(0xff615c5c);

  static const BoxShadow boxShadow = BoxShadow(
    color: Colors.black26,
    blurRadius: 20,
    offset: Offset(0, 5),
  );

  static Gradient gradientSide = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppTheme.primary,
      AppTheme.primary.withOpacity(0.65),
    ],
  );

  static Gradient gradientTop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppTheme.primary,
      AppTheme.primary.withOpacity(0.65),
    ],
  );

  // Login
  static const Color loginBackgroundColor = Color(0xffEFF7FF);
}
