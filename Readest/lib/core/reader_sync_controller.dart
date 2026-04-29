import 'package:flutter/material.dart';

class ReaderSyncController extends ChangeNotifier {
  bool _isSyncEnabled = false;
  bool get isSyncEnabled => _isSyncEnabled;

  void toggleSync() {
    _isSyncEnabled = !_isSyncEnabled;
    notifyListeners();
  }

  /// 计算同步位置偏移
  /// [sourceProgress] 源书籍的阅读进度 (0.0 - 1.0)
  /// [targetController] 目标书籍的控制器
  void syncPosition(double sourceProgress, dynamic targetController) {
    if (!_isSyncEnabled) return;
    
    // 逻辑：如果开启同步，则将目标书籍跳转至相同百分比位置
    // 注意：PDF 和 EPUB 的跳转 API 不同，需在 UI 层判断类型
    if (targetController is ScrollController) {
      final maxScroll = targetController.position.maxScrollExtent;
      targetController.jumpTo(maxScroll * sourceProgress);
    }
  }
}