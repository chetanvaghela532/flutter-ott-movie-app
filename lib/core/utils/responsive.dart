import 'package:flutter/material.dart';

class Responsive {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double width(BuildContext context, double percentage) {
    return screenWidth(context) * (percentage / 100);
  }

  static double height(BuildContext context, double percentage) {
    return screenHeight(context) * (percentage / 100);
  }

  static double fontSize(BuildContext context, double baseSize) {
    final width = screenWidth(context);
    // Scale font based on screen width
    // Base scale for 375px width (iPhone SE)
    final scale = width / 375;
    return baseSize * scale.clamp(0.8, 1.5);
  }

  static double spacing(BuildContext context, double baseSpacing) {
    final width = screenWidth(context);
    final scale = width / 375;
    return baseSpacing * scale.clamp(0.8, 1.3);
  }

  static bool isMobile(BuildContext context) {
    return screenWidth(context) < 600;
  }

  static bool isTablet(BuildContext context) {
    return screenWidth(context) >= 600 && screenWidth(context) < 1200;
  }

  static bool isDesktop(BuildContext context) {
    return screenWidth(context) >= 1200;
  }

  static int getCrossAxisCount(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }

  static double getAspectRatio(BuildContext context) {
    if (isMobile(context)) return 0.6;
    if (isTablet(context)) return 0.65;
    return 0.7;
  }
}

