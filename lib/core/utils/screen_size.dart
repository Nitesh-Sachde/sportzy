import 'package:flutter/material.dart';

class ScreenSize {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static double screenOrientation(BuildContext context) {
    return MediaQuery.of(context).orientation.index == 0
        ? screenWidth(context)
        : screenHeight(context);
  }

  static TextScaler getTextScaleFactor(BuildContext context) {
    return MediaQuery.textScalerOf(context);
  }
}
