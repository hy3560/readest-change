import 'package:flutter/material.dart';

class BookConfig extends ChangeNotifier {
  double fontSize = 18.0;
  double speechRate = 0.5;
  double pitch = 1.0;
  Color backgroundColor = const Color(0xFFF5F5DC); // 米色纸张感
  
  void updateConfig({double? fs, double? sr, double? p, Color? bg}) {
    if (fs != null) fontSize = fs;
    if (sr != null) speechRate = sr;
    if (p != null) pitch = p;
    if (bg != null) backgroundColor = bg;
    notifyListeners();
  }
}