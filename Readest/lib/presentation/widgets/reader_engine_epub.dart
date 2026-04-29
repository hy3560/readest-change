import 'package:flutter/material.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/github.dart';

class ReaderEngineEpub extends StatefulWidget {
  final String? filePath; // 本地路径或网络 URL
  final double fontSize;
  final double lineHeight;
  final bool showRuler; // 阅读标尺开关

  const ReaderEngineEpub({
    super.key,
    this.filePath,
    this.fontSize = 18.0,
    this.lineHeight = 1.5,
    this.showRuler = false,
  });

  @override
  State<ReaderEngineEpub> createState() => _ReaderEngineEpubState();
}

class _ReaderEngineEpubState extends State<ReaderEngineEpub> {
  late EpubController _epubController;

  @override
  void initState() {
    super.initState();
    // 初始化控制器，支持从网络加载
    _epubController = EpubController(
      document: EpubDocument.openAsset('assets/sample.epub'), // 默认示例
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        EpubView(
          controller: _epubController,
          builders: EpubViewBuilders<DefaultBuilderOptions>(
            options: const DefaultBuilderOptions(),
            // 自定义章节标题样式
            chapterDividerBuilder: (_) => const Divider(height: 32),
          ),
        ),
        
        // 阅读标尺 (Reading Ruler)
        if (widget.showRuler) const ReadingRulerOverlay(),
        
        // 底部进度指示器
        Positioned(
          bottom: 10,
          right: 10,
          child: EpubPageActual(
            controller: _epubController,
            builder: (curr, total) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.black54,
              child: Text(
                '$curr / $total',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _epubController.dispose();
    super.dispose();
  }
}

/// 阅读标尺组件：帮助用户聚焦当前行
class ReadingRulerOverlay extends StatefulWidget {
  const ReadingRulerOverlay({super.key});

  @override
  State<ReadingRulerOverlay> createState() => _ReadingRulerOverlayState();
}

class _ReadingRulerOverlayState extends State<ReadingRulerOverlay> {
  double _top = 200.0;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _top,
      left: 0,
      right: 0,
      child: GestureDetector(
        onVerticalDragUpdate: (details) {
          setState(() {
            _top += details.delta.dy;
          });
        },
        child: Opacity(
          opacity: 0.3,
          child: Container(
            height: 30,
            color: Colors.yellow,
            child: const Icon(Icons.drag_handle, size: 16),
          ),
        ),
      ),
    );
  }
}