import 'package:isar/isar.dart';

part 'abs_config.g.dart';

@collection
class AbsConfig {
  Id id = 0; // 固定 ID 确保单条配置

  final String serverUrl;
  final String libraryId;
  final String token;

  AbsConfig({
    required this.serverUrl,
    required this.libraryId,
    required this.token,
  });
}