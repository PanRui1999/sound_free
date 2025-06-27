import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sound_free/models/plugin.dart';
import 'package:sound_free/tools/common_tools.dart';
import 'package:archive/archive.dart';
import 'package:sound_free/tools/global_data.dart';

class FileTools {
  static const String pluginsDirectory = "config/plugins";
  static const MethodChannel _channel = MethodChannel('com.sound_free.saf_file_directory_access');

  static List<File> scanFilesss(String path, List<String> extensions) {
    final dir = Directory(path);
    final files = <File>[];
    if (!dir.existsSync()) return [];
    var entities = dir.listSync(followLinks: true);
    for (final entity in entities) {
      if (entity is File && extensions.contains(p.extension(entity.path))) {
        files.add(entity);
      }
    }
    return files;
  }

  // 请求目录访问权限
  static Future<Map<String, dynamic>?> requestDirectoryAccess({String? directoryPath}) async {
    try {
      Map<Object?, Object?>? result;
      if (directoryPath == null) {
        result = await _channel.invokeMethod('requestDirectoryAccess');
      } else {
        result = await _channel.invokeMethod('requestDirectoryAccess', {'directoryPath': directoryPath});
      }
      if (result != null) {
        return result.cast<String, dynamic>();
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 扫描指定目录下的文件
  static Future<List<Map<String, dynamic>>> scanFiles(String directoryUri, List<String> extensions) async {
    try {
      final dynamic result = await _channel.invokeMethod('scanFiles', {'directoryUri': directoryUri, 'extensions': extensions});
      if (result == null) {
        return [];
      }
      final List<Map<String, dynamic>> convertedResult = result
          .cast<Map<dynamic, dynamic>>()
          .map<Map<String, dynamic>>((map) => Map<String, dynamic>.from(map))
          .toList();
      return convertedResult;
    } catch (e) {
      return [];
    }
  }

  static Future<String?> selectorPlugin() async {
    try {
      final dynamic result = await _channel.invokeMethod('selectFile');
      return result["path"];
    } catch (e) {
      log('file_tools:selectorPlugin 文件选择失败 异常信息$e');
      return null;
    }
  }

  static Future<bool> saveToDocumentsDirectory(File f, String path, String fileName) async {
    List<Plugin> presentPlugins = GlobalData().runningPlugins;
    final appDir = await getExternalStorageDirectory();
    if (appDir == null) return false;

    // Check whether it is a zip archive
    String suffix = fileName.substring(fileName.lastIndexOf('.'));
    if (suffix.isEmpty) return false;
    if (suffix != ".zip") return false;

    // unzip, check structure
    final archive = ZipDecoder().decodeBytes(f.readAsBytesSync());
    ArchiveFile? indexFile, versionFile;
    for (ArchiveFile file in archive) {
      if (indexFile != null && versionFile != null) break;
      // main file
      if (file.isFile && file.name == "index.lua") {
        indexFile = file;
        continue;
      }
      // version file
      if (file.isFile && file.name == "version.json") {
        versionFile = file;
        continue;
      }
    }
    if (indexFile == null || versionFile == null) return false;

    // check present plugin
    final versionContentString = utf8.decode(versionFile.content as List<int>);
    dynamic versionContentJson;
    try {
      versionContentJson = json.decode(versionContentString);
      // check structure of plugin version
      if (versionContentJson['name'] == null) return false;
      if (versionContentJson['version'] == null) return false;
      if (versionContentJson['canBeToProvideSoundSource'] == null) return false;

      for (int i = 0; i < presentPlugins.length; i++) {
        Plugin plugin = presentPlugins[i];
        if (plugin.name == versionContentJson["name"]) {
          // uninstall this plugin
          presentPlugins.removeAt(i);
          // delete local plugin
          Directory dir = Directory(plugin.path);
          if (dir.existsSync()) {
            dir.deleteSync(recursive: true);
          }
          break;
        }
      }
    } catch (e) {
      return false;
    }

    // save plugin
    final baseDirectory = Directory('${appDir.path}/$path/${CommonTools.generateUuid()}');
    if (!baseDirectory.existsSync()) {
      baseDirectory.createSync(recursive: true);
    }
    try {
      // create and write 'index.lua'
      final indexContent = indexFile.content as List<int>;
      Plugin newPlugin = Plugin(
        name: versionContentJson['name'],
        path: baseDirectory.path,
        canBeToProvideSoundSource: versionContentJson["canBeToProvideSoundSource"],
      );
      newPlugin.scriptContent = utf8.decode(indexFile.content);

      File temp1 = File('${baseDirectory.path}/index.lua');
      if(!temp1.existsSync()) temp1.createSync();
      temp1.writeAsBytesSync(indexContent);

      // create and write 'version.json'
      File temp2 = File('${baseDirectory.path}/version.json');
      if(!temp2.existsSync()) temp2.createSync();
      temp2.writeAsStringSync(versionContentString);

      // install plugin
      presentPlugins.add(newPlugin);
      return true;
    } catch (e) {
      // delete base directory if there happening error
      baseDirectory.deleteSync();
      return false;
    }
  }

  static Future<List<Plugin>> allOfPluginsInLocal() async {
    List<Plugin> list = [];
    final appDir = await getExternalStorageDirectory();
    if (appDir == null) return list;
    final directory = Directory('${appDir.path}/$pluginsDirectory');
    if(!directory.existsSync()) directory.createSync(recursive: true);
    var entities = directory.listSync(followLinks: false);
    try {
      for (var entity in entities) {
        if (entity is Directory) {
          Plugin? plugin;
          final versionFile = File('${entity.path}/version.json');
          final luaScriptFile = File('${entity.path}/index.lua');
          if (versionFile.existsSync() && luaScriptFile.existsSync()) {
            final json = jsonDecode(await versionFile.readAsString());
            if (json['name'] == null) break;
            if (json['version'] == null) break;
            if (json['canBeToProvideSoundSource'] == null) break;
            plugin = Plugin(name: json['name'], path: entity.path, canBeToProvideSoundSource: json['canBeToProvideSoundSource']);
            plugin.scriptContent = luaScriptFile.readAsStringSync();
          }
          if (plugin != null) {
            list.add(plugin);
          }
        }
      }
    } catch (e) {
      return [];
    }
    return list;
  }
}
