import 'package:hive/hive.dart';

part 'app_settings.g.dart'; // 生成文件

@HiveType(typeId: 5)
class AppSettings extends HiveObject {
  @HiveField(0)
  List<String> scanningPaths = [];

  AppSettings({this.scanningPaths = const []});
}
