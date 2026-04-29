import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> init() async {
    await _flutterTts.setLanguage("zh-CN");
    await _flutterTts.setSpeechVolume(1.0);
  }

  Future<void> speak(String text, double rate, double pitch) async {
    await _flutterTts.setSpeechRate(rate);
    await _flutterTts.setPitch(pitch);
    await _flutterTts.speak(text);
  }

  Future<void> stop() async => await _flutterTts.stop();
}