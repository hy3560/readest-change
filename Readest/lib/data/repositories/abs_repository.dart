import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/models/book_model.dart';

class ABSRepository {
  final String baseUrl;
  final String libraryId;
  final String token;

  /// 构造函数不再包含硬编码 IP，由业务逻辑层从数据库读取后传入
  ABSRepository({
    required this.baseUrl,
    required this.libraryId,
    required this.token,
  });

  /// 获取 ABS 库中的所有书籍并转换为本地模型
  Future<List<BookModel>> fetchRemoteBooks() async {
    // 确保 URL 格式正确，避免多余的斜杠
    final String cleanBaseUrl = baseUrl.endsWith('/') 
        ? baseUrl.substring(0, baseUrl.length - 1) 
        : baseUrl;
        
    final endpoint = "$cleanBaseUrl/api/libraries/$libraryId/items";
    
    try {
      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List results = data['results'] ?? [];

        return results.map((item) {
          final media = item['media'] ?? {};
          final metadata = media['metadata'] ?? {};
          final itemId = item['id'];
          
          return BookModel(
            absId: itemId,
            // 动态拼接下载地址
            filePath: "$cleanBaseUrl/api/items/$itemId/download",
            title: metadata['title'] ?? "Unknown Title",
            author: metadata['authorName'] ?? "Unknown Author",
            format: _mapMimeToFormat(media['fileType'] ?? "epub"),
            lastReadTime: DateTime.now(),
            isCloudFile: true,
          );
        }).toList();
      } else {
        throw Exception("ABS 服务器同步失败: 状态码 ${response.statusCode}");
      }
    } catch (e) {
      // 在生产环境中应通过 Logger 记录，此处保留 Print 方便调试
      print("ABS Repository Error: $e");
      rethrow;
    }
  }

  /// 将 MIME 类型或文件后缀映射为统一格式
  String _mapMimeToFormat(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('pdf')) return 'PDF';
    if (lowerType.contains('epub')) return 'EPUB';
    if (lowerType.contains('mobi')) return 'MOBI';
    if (lowerType.contains('azw3')) return 'AZW3';
    if (lowerType.contains('cbz')) return 'CBZ';
    return type.toUpperCase();
  }
}