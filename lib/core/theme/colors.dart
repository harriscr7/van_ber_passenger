import 'package:flutter/material.dart';

class AppColors {
  // Solid Colors
  static const Color red = Color(0xFFD83E3E);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color darkGray = Color(0xFF1E1E1E);
  static const Color green = Color(0xFF198754);

  // Linear Gradient 1: Yellow to Orange
  static const LinearGradient yellowToOrange = LinearGradient(
    colors: [Color(0xFFFFE61C), Color(0xFFFFA929)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Linear Gradient 2: Dark Red to Bright Red
  static const LinearGradient darkRedToRed = LinearGradient(
    colors: [Color(0xFF571616), Color(0xFFD83E3E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
