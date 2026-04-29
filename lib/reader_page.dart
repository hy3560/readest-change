import 'package:flutter/material.dart';
import 'services/tts_service.dart';
import 'models/book_config.dart';
import 'package:provider/provider.dart';

class ReaderPage extends StatefulWidget {
  final String content; // 书籍文本内容
  const ReaderPage({super.key, required this.content});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  final TTSService _tts = TTSService();

  @override
  void initState() {
    super.initState();
    _tts.init();
  }

  // 仿 Readest 的设置面板
  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<BookConfig>(
          builder: (context, config, child) => Container(
            padding: const EdgeInsets.all(20),
            height: 250,
            child: Column(
              children: [
                Text("阅读与 TTS 设置", style: TextStyle(fontWeight: FontWeight.bold)),
                const Divider(),
                // 语速调节
                Row(children: [
                  const Text("语速"),
                  Expanded(
                    child: Slider(
                      value: config.speechRate,
                      onChanged: (v) => config.updateConfig(sr: v),
                      min: 0.1, max: 1.0,
                    ),
                  ),
                ]),
                // 字号调节
                Row(children: [
                  const Text("字号"),
                  Expanded(
                    child: Slider(
                      value: config.fontSize,
                      onChanged: (v) => config.updateConfig(fs: v),
                      min: 12, max: 30,
                    ),
                  ),
                ]),
                ElevatedButton(onPressed: () => _tts.stop(), child: const Text("停止播放"))
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = Provider.of<BookConfig>(context);
    final paragraphs = widget.content.split('\n');

    return Scaffold(
      backgroundColor: config.backgroundColor,
      body: GestureDetector(
        onTap: () => _showSettings(context), // 点击弹出菜单
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: paragraphs.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onLongPress: () => _tts.speak(paragraphs[index], config.speechRate, config.pitch),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    paragraphs[index],
                    style: TextStyle(fontSize: config.fontSize, height: 1.6),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}