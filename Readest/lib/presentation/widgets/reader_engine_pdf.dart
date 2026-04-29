import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../domain/models/annotation_model.dart';

class ReaderEnginePdf extends StatefulWidget {
  final String filePath;
  final Function(double)? onScroll; // 用于双书同步
  final bool isAnnotationEnabled;

  const ReaderEnginePdf({
    super.key,
    required this.filePath,
    this.onScroll,
    this.isAnnotationEnabled = false,
  });

  @override
  State<ReaderEnginePdf> createState() => _ReaderEnginePdfState();
}

class _ReaderEnginePdfState extends State<ReaderEnginePdf> {
  final PdfViewerController _pdfController = PdfViewerController();
  List<DrawingPoint?> _currentPoints = [];
  
  // 模拟当前页的批注缓存
  final List<List<DrawingPoint?>> _allAnnotations = [];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 底层：PDF 渲染引擎
        SfPdfViewer.network(
          widget.filePath,
          controller: _pdfController,
          onDocumentLoaded: (details) {
            debugPrint("PDF 加载成功");
          },
          onPageChanged: (details) {
            // 当页面切换时，可以在这里通知同步逻辑
          },
        ),

        // 顶层：手写批注图层 (仅在开启时响应手势)
        if (widget.isAnnotationEnabled)
          GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                _currentPoints.add(DrawingPoint(
                  renderBox.globalToLocal(details.globalPosition),
                  Paint()
                    ..color = Colors.red
                    ..strokeCap = StrokeCap.round
                    ..strokeWidth = 3.0,
                ));
              });
            },
            onPanEnd: (details) {
              _allAnnotations.add(List.from(_currentPoints));
              _currentPoints.clear();
            },
            child: CustomPaint(
              painter: AnnotationPainter(
                currentPoints: _currentPoints,
                allAnnotations: _allAnnotations,
              ),
              size: Size.infinite,
            ),
          ),
      ],
    );
  }
}

/// 批注绘制器
class AnnotationPainter extends CustomPainter {
  final List<DrawingPoint?> currentPoints;
  final List<List<DrawingPoint?>> allAnnotations;

  AnnotationPainter({required this.currentPoints, required this.allAnnotations});

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制已保存的批注
    for (var path in allAnnotations) {
      for (int i = 0; i < path.length - 1; i++) {
        if (path[i] != null && path[i + 1] != null) {
          canvas.drawLine(path[i]!.offset, path[i + 1]!.offset, path[i]!.paint);
        }
      }
    }
    // 绘制当前正在画的线
    for (int i = 0; i < currentPoints.length - 1; i++) {
      if (currentPoints[i] != null && currentPoints[i + 1] != null) {
        canvas.drawLine(currentPoints[i]!.offset, currentPoints[i + 1]!.offset, currentPoints[i]!.paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}