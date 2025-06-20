import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';

class FileTools {
  static const MethodChannel _channel = MethodChannel(
    'com.example.saf_file_scanner',
  );

  static List<File> scanFilesss(String path, List<String> extensions) {
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
  static Future<List<Map<String, dynamic>>?> scanFiles(
    String directoryUri,
    List<String> extensions,
  ) async {
    try {
      final dynamic result = await _channel.invokeMethod('scanFiles', {
        'directoryUri': directoryUri,
      });
      if (result == null) {
        return null;
      }
      final List<Map<String, dynamic>> convertedResult = result
          .cast<Map<dynamic, dynamic>>()
          .map<Map<String, dynamic>>((map) => Map<String, dynamic>.from(map))
          .toList();
      return convertedResult;
    } on PlatformException catch (e) {
      print("扫描文件失败: ${e.message}");
      return null;
    }
  }
}
