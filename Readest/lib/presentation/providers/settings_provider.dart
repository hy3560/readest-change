import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  String _absUrl = "";
  String _absToken = "";
  String _absLibraryId = "";

  String get absUrl => _absUrl;
  String get absToken => _absToken;
  String get absLibraryId => _absLibraryId;

  void updateAbsConfig(String url, String token, String libraryId) {
    _absUrl = url;
    _absToken = token;
    _absLibraryId = libraryId;
    notifyListeners();
  }
}