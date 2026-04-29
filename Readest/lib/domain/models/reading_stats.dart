import 'package:isar/isar.dart';

part 'reading_stats.g.dart';

@collection
class ReadingStats {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  final DateTime date; // 按天计算

  final int minutesRead; // 当日阅读分钟数
  final int pagesCompleted;
  final String mostReadBookTitle;

  ReadingStats({
    required this.date,
    this.minutesRead = 0,
    this.pagesCompleted = 0,
    this.mostReadBookTitle = "",
  });
}