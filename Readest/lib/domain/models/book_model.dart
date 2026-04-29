import 'package:isar/isar.dart';

// 执行命令后生成：flutter pub run build_runner build
part 'book_model.g.dart';

@collection
class BookModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  final String filePath; // 本地路径或云端唯一标识

  final String title;
  final String author;
  final String format; // EPUB, PDF, MOBI...
  
  final String? coverPath; // 封面图路径
  final double progress; // 阅读进度 0.0 - 1.0
  final DateTime lastReadTime;
  
  // 针对 ABS 集成的元数据
  final String? absId;
  final bool isCloudFile;

  // 全文搜索索引
  @Index(type: IndexType.value)
  final List<String> keywords;

  BookModel({
    required this.filePath,
    required this.title,
    required this.author,
    required this.format,
    this.coverPath,
    this.progress = 0.0,
    required this.lastReadTime,
    this.absId,
    this.isCloudFile = false,
    this.keywords = const [],
  });

  // Flutter 3.x 推荐使用 CopyWith 模式而非 Getter 修改
  BookModel copyWith({
    double? progress,
    DateTime? lastReadTime,
    String? coverPath,
  }) {
    return BookModel(
      filePath: filePath,
      title: title,
      author: author,
      format: format,
      coverPath: coverPath ?? this.coverPath,
      progress: progress ?? this.progress,
      lastReadTime: lastReadTime ?? this.lastReadTime,
      absId: absId,
      isCloudFile: isCloudFile,
      keywords: keywords,
    );
  }
}