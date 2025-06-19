import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sound_free/controllers/app_settings_controller.dart';
import 'package:sound_free/models/plugin.dart';
import 'package:sound_free/models/sound.dart';
import 'package:sound_free/tools/file_tools.dart';
import 'package:sound_free/tools/global_data.dart';
import 'package:sound_free/ui/android/components/search_bar.dart';
import 'package:sound_free/ui/android/components/sound_player.dart';
import 'package:permission_handler/permission_handler.dart';

class SearchingScreen extends StatefulWidget {
  const SearchingScreen({super.key});

  @override
  State<SearchingScreen> createState() => _SearchingScreen();
}

class _SearchingScreen extends State<SearchingScreen> {
  String _query = "";
  List<Map<String, dynamic>> _pluginsState = [];
  final GlobalKey<_SearchingResultSectionState>
  _searchingResultSectionStateKey = GlobalKey();

  @override
  void initState() {
    _pluginsState = GlobalData().runningPlugins.map((p) => p.stateMap).toList();
    _pluginsState.add({
      "plugin": Plugin(name: "local-memory", canBeToProvideSoundSource: true),
      "isSelected": true,
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.all(6),
              child: Column(
                children: [
                  TopSearchBar(
                    text: _query,
                    onSearch: (text, _) {
                      _searchingResultSectionStateKey.currentState?.onSearching(
                        text,
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  _buildWidgetOfSoundSources(),
                ],
              ),
            ),
            SearchingResultSection(
              key: _searchingResultSectionStateKey,
              plugins: _pluginsState,
            ),
            SoundPlayer(audioPlayer: GlobalData().defualtAudioPlayer),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    _query = ModalRoute.of(context)?.settings.arguments as String;
    super.didChangeDependencies();
  }

  Widget _buildWidgetOfSoundSources() {
    return SizedBox(
      height: 30, // 指定列表高度
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _pluginsState.length,
        itemBuilder: (context, index) {
          if (!_pluginsState[index]['plugin'].canBeToProvideSoundSource) {
            return SizedBox.shrink();
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              onTap: () {
                if (_searchingResultSectionStateKey.currentState == null) {
                  return;
                }
                if (_searchingResultSectionStateKey.currentState != null &&
                    _searchingResultSectionStateKey
                        .currentState!
                        ._isSearching) {
                  return;
                }
                setState(() {
                  var isSelected = _pluginsState[index]['isSelected'];
                  _pluginsState[index]['isSelected'] = !isSelected;
                  if (!isSelected) {
                    _pluginsState.insert(0, _pluginsState.removeAt(index));
                  } else {
                    _pluginsState.add(_pluginsState.removeAt(index));
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _pluginsState[index]['isSelected']
                      ? Colors.red.withValues(alpha: 0.2)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _pluginsState[index]['plugin'].name,
                  style: TextStyle(
                    fontSize: 14,
                    color: _pluginsState[index]['isSelected']
                        ? Colors
                              .red // 选中文字颜色
                        : Colors.grey,
                    fontWeight: _pluginsState[index]['isSelected']
                        ? FontWeight
                              .bold // 选中加粗
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SearchingResultSection extends StatefulWidget {
  final List<Map<String, dynamic>> plugins;

  const SearchingResultSection({super.key, required this.plugins});

  @override
  State<StatefulWidget> createState() => _SearchingResultSectionState();
}

class _SearchingResultSectionState extends State<SearchingResultSection> {
  bool _isSearching = true;
  List<Sound> _searchingContents = [];
  final List<String> _canScanPathInLocal = AppSettingsController()
      .allOfScaningPaths();

  @override
  Widget build(BuildContext context) {
    var itemCount = _isSearching ? 1 : _searchingContents.length;

    return Expanded(
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (_isSearching) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                strokeWidth: 3,
              ),
            );
          } else {
            return ListTile(title: Text(_searchingContents[index].sourcePath));
          }
        },
      ),
    );
  }

  void onSearching(String text) async {
    final List<Sound> searchingResult = [];

    // loading state
    setState(() {
      _isSearching = true;
    });

    // async searching
    for (var plugin in widget.plugins) {
      if (plugin['plugin'].canBeToProvideSoundSource) {
        if (plugin['plugin'].name == "local-memory" &&
            plugin['isSelected'] == true) {
          // scan local file
          for (var localsound in await _scanLocalSourceFiles()) {
            searchingResult.add(localsound);
          }
          continue;
        } else {
          // other plugin can be to provide sound source
        }
      }
    }

    // update _searchingContents
    setState(() {
      _searchingContents.clear();
      _searchingContents.addAll(searchingResult);
    });
  }

  Future<List<Sound>> _scanLocalSourceFiles() async {
    List<Sound> sounds = [];
    List<String> format = ['.mp3', '.wav', '.aac', '.flac'];
    var donetIndex = 0;
    final status = await Permission.storage.status;

    if (!status.isGranted) {
      final result = await Permission.storage.request();
      if (result.isDenied || result.isPermanentlyDenied) {
        if (mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('需要存储权限'),
              content: const Text('扫描本地音频文件需要存储权限'),
              actions: [
                TextButton(
                  child: const Text('取消'),
                  onPressed: () => Navigator.pop(ctx),
                ),
                TextButton(
                  child: const Text('去设置'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    openAppSettings(); // 跳转到应用设置
                  },
                ),
              ],
            ),
          );
        }
        return sounds; // 返回空列表
      }
    }
    for (var path in _canScanPathInLocal) {
      // 1. 首先请求目录访问权限
      final directoryUri = await FileTools.requestDirectoryAccess();
      // 2. 如果成功获取到目录URI，则扫描文件
      if (directoryUri != null) {
        final files = [];
        // 处理扫描结果
        if (files != null) {
          // 文件列表获取成功，可以进行处理
          for (var file in files) {
            print('文件名: ${file['name']}');
            print('是否为目录: ${file['isDirectory']}');
            print('URI: ${file['uri']}');
            // 其他属性...
          }
        }
      }

      for (var item in FileTools.scanFiles(path, format)) {
        donetIndex = item.path.lastIndexOf('.');
        switch (item.path.substring(donetIndex).toLowerCase()) {
          case '.mp3':
            sounds.add(
              Sound(
                sourcePath: item.path,
                isLocal: true,
                format: SoundFormat.mp3,
              ),
            );
            break;
          case '.wav':
            sounds.add(
              Sound(
                sourcePath: item.path,
                isLocal: true,
                format: SoundFormat.wav,
              ),
            );
            break;
          case '.aac':
            sounds.add(
              Sound(
                sourcePath: item.path,
                isLocal: true,
                format: SoundFormat.aac,
              ),
            );
            break;
          case '.flac':
            sounds.add(
              Sound(
                sourcePath: item.path,
                isLocal: true,
                format: SoundFormat.flac,
              ),
            );
            break;
        }
      }
    }
    return sounds;
  }
}

extension _PluginExtenxion on Plugin {
  Map<String, dynamic> get stateMap => {'plugin': this, 'isSelected': false};
}
