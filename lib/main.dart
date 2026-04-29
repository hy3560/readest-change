import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config_provider.dart';
import 'reader_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ConfigProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(), // 仿 Readest 的深色模式
      home: const ReaderScreen(
        // 这里替换为你图片中 Audiobookshelf 的具体图书流地址
        pdfUrl: 'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      ),
    );
  }
}