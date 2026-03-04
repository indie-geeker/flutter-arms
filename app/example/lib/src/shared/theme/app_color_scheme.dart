import 'package:flutter/material.dart';

/// App-wide supported color schemes.
enum AppColorScheme {
  blue(Colors.blue, 'blue'),
  green(Colors.green, 'green'),
  purple(Colors.purple, 'purple'),
  orange(Colors.orange, 'orange'),
  teal(Colors.teal, 'teal');

  const AppColorScheme(this.color, this.name);

  final Color color;
  final String name;
}
