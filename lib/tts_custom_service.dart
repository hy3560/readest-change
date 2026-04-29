import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';

class TTSCustomService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Dio _dio = Dio();

  // --- 配置你的 VPS 地址 ---
  final String vpsUrl = "http://23.95.28.133:你的端口/tts"; 

  Future<void> speak(String text, double rate, double pitch) async {
    try {
      // 停止当前播放
      await _audioPlayer.stop();

      // 这里的参数取决于你 VPS 上 TTS 引擎的 API 格式
      // 以下是常见的请求示例
      String audioUrl = "$vpsUrl?text=${Uri.encodeComponent(text)}&speed=$rate&pitch=$pitch";
      
      // 直接通过 audioplayers 播放网络音频流
      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      print("TTS播放失败: $e");
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }
}