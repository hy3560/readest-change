import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:vocsy_epub_viewer/vocsy_epub_viewer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'dart:io';

void main() => runApp(const MaterialApp(
  home: ReadestX(),
  debugShowCheckedModeBanner: false,
));

class ReadestX extends StatefulWidget {
  const ReadestX({super.key});
  @override
  State<ReadestX> createState() => _ReadestXState();
}

class _ReadestXState extends State<ReadestX> {
  final AudioPlayer _player = AudioPlayer();
  final TextEditingController _urlController = TextEditingController();
  
  List<dynamic> _voices = [];
  String? _currentVoice;
  List<PlatformFile> _myBooks = [];
  bool _isConnecting = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _urlController.text = prefs.getString('vps_url') ?? "";
    if (_urlController.text.isNotEmpty) _refreshVoices();
  }

  // 核心：从 VPS 动态同步所有可用 TTS 音色
  Future<void> _refreshVoices() async {
    String url = _urlController.text.trim();
    if (!url.startsWith('http')) return;
    setState(() => _isConnecting = true);
    try {
      final res = await Dio().get("$url/models");
      setState(() {
        _voices = res.data['data'];
        _currentVoice = _voices.isNotEmpty ? _voices[0]['id'] : null;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('vps_url', url);
    } catch (e) {
      debugPrint("VPS连接失败: $e");
    } finally {
      setState(() => _isConnecting = false);
    }
  }

  // 核心：图书馆管理 - 导入书籍
  Future<void> _importBook() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub', 'pdf', 'txt'],
    );
    if (result != null) {
      setState(() => _myBooks.add(result.files.first));
    }
  }

  // 核心：阅读模式切换 (EPUB分页/PDF滚动)
  void _readBook(PlatformFile file) {
    if (file.extension == 'epub') {
      VocsyEpub.setConfig(
        themeColor: Colors.orangeAccent,
        identifier: "ios_book_${file.name}",
        scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
        enableTts: true,
      );
      VocsyEpub.open(file.path!);
    } else if (file.extension == 'pdf') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
        appBar: AppBar(title: Text(file.name)),
        body: SfPdfViewer.file(File(file.path!)),
      )));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("READEST PRIVATE", style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(icon: const Icon(Icons.cloud_sync, color: Colors.orangeAccent), onPressed: _refreshVoices),
        ],
      ),
      body: Column(
        children: [
          // 顶部设置区
          _buildSettingsHeader(),
          // 图书馆内容
          Expanded(
            child: _myBooks.isEmpty ? _buildEmptyHome() : _buildBookGrid(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orangeAccent,
        onPressed: _importBook,
        child: const Icon(Icons.add_link, color: Colors.black, size: 30),
      ),
    );
  }

  Widget _buildSettingsHeader() {
    return Container(
      padding: const EdgeInsets.all(15),
      color: Colors.black,
      child: Column(
        children: [
          TextField(
            controller: _urlController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "VPS Endpoint (http://ip:8000/v1)",
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true, fillColor: Colors.white10,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 10),
          DropdownButton<String>(
            value: _currentVoice,
            dropdownColor: Colors.grey[900],
            isExpanded: true,
            style: const TextStyle(color: Colors.orangeAccent),
            hint: const Text("请先获取音色列表", style: TextStyle(color: Colors.white30)),
            items: _voices.map((v) => DropdownMenuItem<String>(
              value: v['id'], child: Text("当前音色: ${v['id']}"),
            )).toList(),
            onChanged: (val) => setState(() => _currentVoice = val),
          ),
        ],
      ),
    );
  }

  Widget _buildBookGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.6, crossAxisSpacing: 15),
      itemCount: _myBooks.length,
      itemBuilder: (ctx, i) => GestureDetector(
        onTap: () => _readBook(_myBooks[i]),
        child: Column(
          children: [
            Expanded(child: Container(decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.menu_book, color: Colors.white24, size: 40))),
            Text(_myBooks[i].name, style: const TextStyle(color: Colors.white70, fontSize: 11), maxLines: 2, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyHome() {
    return Center(
      child: Opacity(opacity: 0.3, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.auto_stories, size: 100, color: Colors.white),
        const SizedBox(height: 10),
        const Text("私有图书馆已就绪", style: TextStyle(color: Colors.white, fontSize: 18)),
      ])),
    );
  }
}