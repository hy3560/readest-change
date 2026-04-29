import 'package:flutter/material.dart';

class StatsDashboardScreen extends StatelessWidget {
  const StatsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("阅读数据统计")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickStats(),
            const SizedBox(height: 30),
            const Text("最近 7 天活跃度", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildActivityChart(),
            const SizedBox(height: 30),
            _buildBookBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _statCard("累计阅读", "128", "小时", Colors.blue),
        const SizedBox(width: 15),
        _statCard("本周完成", "3", "本书", Colors.green),
      ],
    );
  }

  Widget _statCard(String label, String value, String unit, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: color)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
                const SizedBox(width: 4),
                Text(unit, style: TextStyle(fontSize: 12, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    // 这里可以使用 fl_chart 库，此处先用模拟条形图占位
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) => Container(
          width: 20,
          height: (index + 1) * 20.0,
          decoration: BoxDecoration(
            color: Colors.blueAccent.withOpacity(0.6),
            borderRadius: BorderRadius.circular(4),
          ),
        )),
      ),
    );
  }

  Widget _buildBookBreakdown() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.pie_chart, color: Colors.orange),
        title: const Text("格式分布"),
        subtitle: const Text("PDF (60%) | EPUB (30%) | Others (10%)"),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}