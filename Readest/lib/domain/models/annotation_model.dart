import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

part 'annotation_model.g.dart';

@collection
class AnnotationModel {
  Id id = Isar.autoIncrement;

  final String bookId; // 关联书籍的路径或 ABS ID
  final int pageNumber;
  
  // 将笔迹存储为 JSON 字符串，便于持久化
  final String pointsJson; 
  final int colorValue;
  final double strokeWidth;

  AnnotationModel({
    required this.bookId,
    required this.pageNumber,
    required this.pointsJson,
    this.colorValue = 0xFFFF0000, // 默认红色
    this.strokeWidth = 2.0,
  });
}

class DrawingPoint {
  final Offset offset;
  final Paint paint;

  DrawingPoint(this.offset, this.paint);
}