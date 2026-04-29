import 'package:flutter/material.dart';
import 'package:flutter_highlighter/flutter_highlighter.dart';
import 'package:flutter_highlighter/themes/atom-one-dark.dart';

class CodeHighlighter {
  /// 将原始文本转换为高亮 Widget
  static Widget highlight(String code, {String language = 'dart'}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF282C34),
        borderRadius: BorderRadius.circular(8),
      ),
      child: HighlightView(
        code,
        language: language,
        theme: atomOneDarkTheme,
        padding: const EdgeInsets.all(8),
        textStyle: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
        ),
      ),
    );
  }
}