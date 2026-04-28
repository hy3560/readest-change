import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MaterialApp(home: PrivateReader(), debugShowCheckedModeBanner: false));

class PrivateReader extends StatefulWidget {
  const PrivateReader({super.key});
  @override
  State<PrivateReader> createState() => _PrivateReaderState();
}

class _PrivateReaderState extends State<PrivateReader> {
  final TextEditingController _urlController = TextEditingController();
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadSavedUrl(); // 初始化时读取保存的 IP
  }

  // 从本地存储读取上次填写的地址
  Future<void> _loadSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _urlController.text = prefs.getString('vps_url') ?? "";
    });
  }

  // 播放逻辑：对接你私有的云端接口
  Future<void> _speak(String text) async {
    String url = _urlController.text.trim();
    if (!url.startsWith('http')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("请填写正确的 API 地址 (需包含 http/https)")));
      return;
    }

    // 保存当前填写的地址到本地
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vps_url', url);

    try {
      final response = await Dio().post(
        "$url/audio/speech",
        data: {
          "model": "tts-1", 
          "input": text, 
          "voice": "zh-CN-XiaoxiaoNeural"
        },
        options: Options(responseType: ResponseType.bytes),
      );
      
      // 播放从 VPS 获取的音频二进制流
      await _player.play(BytesSource(response.data));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("云端连接失败: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // 极客深色模式
      appBar: AppBar(
        title: const Text("私有云阅听端", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text("服务器配置", style: TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                labelText: "VPS 端点地址",
                hintText: "例如 http://你的IP:8000/v1",
                hintStyle: const TextStyle(color: Colors.white30),
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                prefixIcon: const Icon(Icons.cloud_queue, color: Colors.orangeAccent),
              ),
            ),
            const SizedBox(height: 60),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.auto_stories, size: 80, color: Colors.white10),
                  const SizedBox(height: 20),
                  const Text(
                    "“晓晓的声音不仅是好听，更是自建服务的自由。”",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 16, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _speak("连接成功！私有云端语音引擎已准备就绪，欢迎使用。"),
                icon: const Icon(Icons.bolt, size: 28),
                label: const Text("测试私有云连接", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}