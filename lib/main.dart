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
  
  List<dynamic> _serverVoices = []; // 动态存储服务器返回的音色
  String? _selectedVoice; // 当前选中的音色标识符符
  bool _isLoadingVoices = false; // 是否正在加载

  @override
  void initState() {
    super.initState();
    _loadInitialSettings();
  }

  // 加载初始配置
  Future<void> _loadInitialSettings() async {
    final prefs = await SharedPreferences.getInstance();
    String savedUrl = prefs.getString('vps_url') ?? "";
    setState(() {
      _urlController.text = savedUrl;
      _selectedVoice = prefs.getString('selected_voice');
    });
    // 如果有保存的地址，自动拉取一次音色列表
    if (savedUrl.isNotEmpty) {
      _fetchVoices(savedUrl);
    }
  }

  // --- 核心功能：从服务器获取可用音色列表 ---
  Future<void> _fetchVoices(String url) async {
    if (!url.startsWith('http')) return;
    setState(() => _isLoadingVoices = true);
    
    try {
      // 访问 OpenAI 兼容标准的 /v1/models 接口
      final response = await Dio().get("$url/models");
      final List<dynamic> models = response.data['data'];
      
      setState(() {
        _serverVoices = models;
        // 如果之前选过的音色还在列表里就保留，否则默认选第一个
        if (_selectedVoice == null || !models.any((m) => m['id'] == _selectedVoice)) {
          _selectedVoice = models.isNotEmpty ? models[0]['id'] : null;
        }
        _isLoadingVoices = false;
      });
    } catch (e) {
      setState(() => _isLoadingVoices = false);
      print("获取音色失败: $e");
    }
  }

  Future<void> _speak(String text) async {
    String url = _urlController.text.trim();
    if (_selectedVoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("请先连接服务器并选择音色")));
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('vps_url', url);
    await prefs.setString('selected_voice', _selectedVoice!);

    try {
      final response = await Dio().post(
        "$url/audio/speech",
        data: {
          "model": "tts-1", 
          "input": text, 
          "voice": _selectedVoice 
        },
        options: Options(responseType: ResponseType.bytes),
      );
      await _player.play(BytesSource(response.data));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("合成失败: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text("私有云阅听 - 动态版"), backgroundColor: Colors.black),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("1. 服务器配置", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: _urlController,
              onChanged: (val) => _fetchVoices(val.trim()), // 地址变动自动刷新
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true, fillColor: Colors.white.withOpacity(0.05),
                hintText: "http://你的IP:8000/v1", hintStyle: const TextStyle(color: Colors.white24),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.orangeAccent),
                  onPressed: () => _fetchVoices(_urlController.text.trim()),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 30),
            const Text("2. 服务器可用音色", style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _isLoadingVoices 
              ? const LinearProgressIndicator(color: Colors.orangeAccent)
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedVoice,
                      dropdownColor: const Color(0xFF222222),
                      isExpanded: true,
                      hint: const Text("等待获取音色...", style: TextStyle(color: Colors.white30)),
                      style: const TextStyle(color: Colors.white),
                      items: _serverVoices.map((v) => DropdownMenuItem(
                        value: v['id'].toString(),
                        child: Text(v['id'].toString()),
                      )).toList(),
                      onChanged: (val) => setState(() => _selectedVoice = val),
                    ),
                  ),
                ),
            const SizedBox(height: 60),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                minimumSize: const Size(double.infinity, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () => _speak("连接成功。当前正在使用服务器端的动态音色。"),
              icon: const Icon(Icons.bolt, color: Colors.black),
              label: const Text("测试连接", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}