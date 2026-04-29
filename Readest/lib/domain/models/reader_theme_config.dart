import 'package:flutter/material.dart';

class ReaderThemeConfig {
  final double fontSize;
  final double lineHeight;
  final Color backgroundColor;
  final Color textColor;
  final String fontFamily;

  const ReaderThemeConfig({
    this.fontSize = 18.0,
    this.lineHeight = 1.6,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.fontFamily = 'System',
  });

  // 预设主题：护眼模式
  factory ReaderThemeConfig.sepia() => const ReaderThemeConfig(
    backgroundColor: Color(0xFFF4ECD8),
    textColor: Color(0xFF5B4636),
  );

  // 预设主题：深色模式
  factory ReaderThemeConfig.dark() => const ReaderThemeConfig(
    backgroundColor: Color(0xFF1A1A1A),
    textColor: Color(0xFFD1D1D1),
  );
}