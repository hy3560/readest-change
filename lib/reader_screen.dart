import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config_provider.dart';
import 'tts_custom_service.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final TTSCustomService _tts = TTSCustomService();
  
  // 模拟从你的 Audiobookshelf 获取的文字内容
  final String bookContent = "这是从你的 VPS 服务器加载的内容。\n"
      "你已经成功在 23.95.28.133 上部署了 TTS 环境。\n"
      "点击任意段落，系统会发送请求到你的 VPS 生成语音并播放。\n"
      "再次点击屏幕中央可以调整语速。";

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<ConfigProvider>(context);
    List<String> paragraphs = bookContent.split('\n');

    return Scaffold(
      // 背景颜色跟随配置，实现 Readest 的护眼模式
      backgroundColor: const Color(0xFF1A1A1A), 
      body: Stack(
        children: [
          // 1. 阅读正文层
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(25, 60, 25, 40),
            itemCount: paragraphs.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => _tts.speak(paragraphs[index], config.speechRate, config.pitch),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    paragraphs[index],
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      height: 1.8,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              );
            },
          ),
          
          // 2. 顶部透明返回键
          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white54),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          // 3. 底部控制条 (点击文字自动显示，或长按显示)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.orangeAccent,
              onPressed: () => _showSettings(context),
              child: const Icon(Icons.tune),
            ),
          )
        ],
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2D2D2D),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Consumer<ConfigProvider>(
        builder: (context, config, child) => Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("VPS TTS 配置", style: TextStyle(color: Colors.white, fontSize: 16)),
              Slider(
                value: config.speechRate,
                activeColor: Colors.orangeAccent,
                onChanged: (v) => config.updateSettings(rate: v),
                min: 0.1, max: 2.0,
              ),
              Text("当前语速: ${config.speechRate.toStringAsFixed(1)}x", style: const TextStyle(color: Colors.white54)),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                onPressed: () => _tts.stop(),
                child: const Text("停止播放"),
              )
            ],
          ),
        ),
      ),
    );
  }
}