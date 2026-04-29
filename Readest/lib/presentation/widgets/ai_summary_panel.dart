import 'package:flutter/material.dart';

class AiSummaryPanel extends StatelessWidget {
  final String content;
  final bool isLoading;
  final String summary;

  const AiSummaryPanel({
    super.key,
    required this.content,
    this.isLoading = false,
    this.summary = "",
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("AI 智能总结", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              if (isLoading) const CircularProgressIndicator() else const Icon(Icons.auto_awesome, color: Colors.amber),
            ],
          ),
          const Divider(),
          Flexible(
            child: SingleChildScrollView(
              child: Text(
                isLoading ? "AI 正在深度阅读并思考中..." : summary,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("关闭")),
              ElevatedButton(onPressed: () {}, child: const Text("复制总结")),
            ],
          )
        ],
      ),
    );
  }
}