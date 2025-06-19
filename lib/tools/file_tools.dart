import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';

class FileTools {
  static const MethodChannel _channel = MethodChannel(
    'com.example.saf_file_scanner',
  );

  static List<File> scanFiles(String path, List<String> extensions) {
    final dir = Directory(path);
    final files = <File>[];
    if (!dir.existsSync()) return [];
    var entities = dir.listSync(followLinks: true);
    for (final entity in entities) {
      print("发现的文件: ${entity.path}");
      if (entity is File && extensions.contains(p.extension(entity.path))) {
        files.add(entity);
      }
    }
    File test = File(
      p.join(dir.path, "/storage/emulated/0/Music/358000282.aac"),
    );
    print("直接访问结果: ${test.existsSync()}");

    return files;
  }

  // 请求目录访问权限
  static Future<Map<String, dynamic>?> requestDirectoryAccess({
    String? directoryPath,
  }) async {
    try {
      Map<Object?, Object?>? result;
      if (directoryPath == null) {
        result = await _channel.invokeMethod('requestDirectoryAccess');
      } else {
        result = await _channel.invokeMethod('requestDirectoryAccess', {
          'directoryPath': directoryPath,
        });
      }
      if (result != null) {
        return result.cast<String, dynamic>();
      }
      return null;
    } on PlatformException catch (e) {
      print("获取目录权限失败: ${e.message}");
      return null;
    }
  }

  // 扫描指定目录下的文件
  static Future<List<Map<String, dynamic>>?> scanFilestest(
    String directoryUri,
  ) async {
    try {
      final result = await _channel.invokeMethod('scanFiles', {
        'directoryUri': directoryUri,
      });
      if (result is List) {
        return List<Map<String, dynamic>>.from(result);
      }
      return [];
    } on PlatformException catch (e) {
      print("扫描文件失败: ${e.message}");
      return null;
    }
  }
}
