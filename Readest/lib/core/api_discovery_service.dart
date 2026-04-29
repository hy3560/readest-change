import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// 错误处理异常类
class DiscoveryException implements Exception {
  final String message;
  DiscoveryException(this.message);
  @override
  String toString() => "DiscoveryException: $message";
}

/// 核心任务：动态 API 嗅探服务
/// 支持在客户端填入 BaseURL 后，自动拉取并展示模型/语音列表。
class ApiDiscoveryService {
  final http.Client _httpClient;

  ApiDiscoveryService({http.Client? client}) : _httpClient = client ?? http.Client();

  /// 嗅探 AI 模型列表 (兼容 OpenAI 格式的 /v1/models)
  /// [baseUrl] 用户输入的接口地址
  /// [apiKey] 用户密钥
  Future<List<String>> fetchAvailableAIModels(String baseUrl, String apiKey) async {
    final cleanUrl = _normalizeUrl(baseUrl, '/v1/models');
    
    try {
      final response = await _httpClient.get(
        Uri.parse(cleanUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List models = data['data'] ?? [];
        return models.map((m) => m['id'].toString()).toList();
      } else {
        throw DiscoveryException("AI 服务响应错误: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("AI Discovery Error: $e");
      throw DiscoveryException("无法连接到 AI 服务器，请检查 BaseURL 或网络。");
    }
  }

  /// 嗅探 TTS 语音列表
  /// [baseUrl] 用户输入的 TTS 服务地址
  Future<List<Map<String, String>>> fetchTTSVoices(String baseUrl) async {
    final cleanUrl = _normalizeUrl(baseUrl, '/v1/voices');

    try {
      final response = await _httpClient.get(
        Uri.parse(cleanUrl),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((v) => {
          'id': v['voice_id']?.toString() ?? '',
          'name': v['name']?.toString() ?? '未知语音',
          'lang': v['language']?.toString() ?? 'zh-CN',
        }).toList();
      } else {
        throw DiscoveryException("TTS 服务响应错误: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("TTS Discovery Error: $e");
      // 返回 Mock 数据或空列表，防止界面崩溃
      return [];
    }
  }

  /// ABS (Audiobookshelf) 集成探测
  /// [serverUrl] 示例：http://23.95.28.133:13378
  Future<bool> pingABSServer(String serverUrl, String token) async {
    final uri = Uri.parse("$serverUrl/api/libraries");
    try {
      final response = await _httpClient.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// 私有工具：规范化 URL 拼接
  String _normalizeUrl(String base, String endpoint) {
    var url = base.trim();
    if (url.endsWith('/')) {
      url = url.substring(0, url.length - 1);
    }
    // 如果用户输入的 URL 已经包含了 endpoint，则不再拼接
    if (url.contains(endpoint)) {
      return url;
    }
    return "$url$endpoint";
  }

  void dispose() {
    _httpClient.close();
  }
}