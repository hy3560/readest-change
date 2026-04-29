import 'package:flutter/material.dart';
import '../widgets/reader_engine_pdf.dart';
import '../widgets/reader_engine_epub.dart';

class DualReaderScreen extends StatefulWidget {
  const DualReaderScreen({super.key});

  @override
  State<DualReaderScreen> createState() => _DualReaderScreenState();
}

class _DualReaderScreenState extends State<DualReaderScreen> {
  bool _isVerticalSplit = false;
  bool _showRuler = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Readest Professional"),
        actions: [
          IconButton(
            icon: Icon(_showRuler ? Icons.straighten : Icons.straighten_outlined),
            onPressed: () => setState(() => _showRuler = !_showRuler),
            tooltip: "阅读标尺",
          ),
          IconButton(
            icon: Icon(_isVerticalSplit ? Icons.view_stream : Icons.view_column),
            onPressed: () => setState(() => _isVerticalSplit = !_isVerticalSplit),
          ),
        ],
      ),
      body: _isVerticalSplit 
          ? Column(
              children: [
                Expanded(child: const ReaderEnginePdf(filePath: "https://example.com/tech.pdf")),
                const Divider(height: 1, thickness: 2),
                Expanded(child: ReaderEngineEpub(showRuler: _showRuler)),
              ],
            )
          : Row(
              children: [
                Expanded(child: const ReaderEnginePdf(filePath: "https://example.com/ref.pdf")),
                const VerticalDivider(width: 1, thickness: 2),
                Expanded(child: ReaderEngineEpub(showRuler: _showRuler)),
              ],
            ),
    );
  }
}