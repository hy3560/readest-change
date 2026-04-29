import 'package:flutter/material.dart';
import '../../core/api_discovery_service.dart';

class SettingsApiScreen extends StatefulWidget {
  const SettingsApiScreen({super.key});

  @override
  State<SettingsApiScreen> createState() => _SettingsApiScreenState();
}

class _SettingsApiScreenState extends State<SettingsApiScreen> {
  final _discoveryService = ApiDiscoveryService();
  
  // 控制器：用于获取用户输入的 URL 和 Key
  final _aiUrlController = TextEditingController();
  final _aiKeyController = TextEditingController();
  
  List<String> _availableModels = [];
  String? _selectedModel;
  bool _isSearching = false;

  /// 执行动态嗅探
  Future<void> _handleDiscovery() async {
    if (_aiUrlController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("请先输入 Base URL")),
      );
      return;
    }

    setState(() => _isSearching = true);
    
    try {
      final models = await _discoveryService.fetchAvailableAIModels(
        _aiUrlController.text.trim(),
        _aiKeyController.text.trim(),
      );
      
      setState(() {
        _availableModels = models;
        if (models.isNotEmpty) _selectedModel = models.first;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("成功发现 ${models.length} 个模型")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("API 嗅探与配置")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle("AI 总结服务配置"),
          const SizedBox(height: 12),
          TextField(
            controller: _aiUrlController,
            decoration: const InputDecoration(
              labelText: "AI Base URL",
              hintText: "例如: https://api.openai.com",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _aiKeyController,
            decoration: const InputDecoration(
              labelText: "API Key",
              hintText: "sk-...",
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isSearching ? null : _handleDiscovery,
            icon: _isSearching 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.search),
            label: const Text("动态嗅探可用模型"),
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          ),
          
          if (_availableModels.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text("选择默认模型:", style: TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedModel,
              items: _availableModels.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
              onChanged: (val) => setState(() => _selectedModel = val),
            ),
          ],
          
          const Divider(height: 40),
          _buildSectionTitle("ABS 远程库配置"),
          const Text("请在“书架 -> 添加远程库”中输入 IP 和 Token"),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Colors.blueAccent,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  @override
  void dispose() {
    _aiUrlController.dispose();
    _aiKeyController.dispose();
    _discoveryService.dispose();
    super.dispose();
  }
}