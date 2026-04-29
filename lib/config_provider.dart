import 'package:flutter/material.dart';

class ConfigProvider extends ChangeNotifier {
  double speechRate = 0.5; // 语速
  double pitch = 1.0;      // 音调
  bool isAutoReading = false;

  void updateSettings({double? rate, double? p, bool? auto}) {
    if (rate != null) speechRate = rate;
    if (p != null) pitch = p;
    if (auto != null) isAutoReading = auto;
    notifyListeners();
  }
}