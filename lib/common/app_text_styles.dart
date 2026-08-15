import 'package:flutter/material.dart';

/// App-wide text style definitions.
abstract class AppTextStyle {
  /// Returns a custom [TextStyle] with Jost font family.
  static TextStyle getAppTextStyle({
    double size = 14,
    FontWeight weight = FontWeight.normal,
    FontStyle style = FontStyle.normal,
    Color color = Colors.black,
  }) {
    return TextStyle(
      color: color,
      fontSize: size,
      fontWeight: weight,
      fontStyle: style,
      fontFamily: 'Jost',
    );
  }
}
