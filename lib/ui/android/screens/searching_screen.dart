import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sound_free/controllers/app_settings_controller.dart';
import 'package:sound_free/models/plugin.dart';
import 'package:sound_free/models/song.dart';
import 'package:sound_free/models/sound.dart';
import 'package:sound_free/tools/file_tools.dart';
import 'package:sound_free/tools/global_data.dart';
import 'package:sound_free/tools/js_engine.dart';
import 'package:sound_free/ui/android/components/search_bar.dart';
import 'package:sound_free/ui/android/components/sound_player.dart';

class SearchingScreen extends StatefulWidget {
  const SearchingScreen({super.key});

  @override
  State<SearchingScreen> createState() => _SearchingScreen();
}

class _SearchingScreen extends State<SearchingScreen> {
  String _query = "";
  List<Map<String, dynamic>> _pluginsState = [];
  final GlobalKey<_SearchingResultSectionState> _searchingResultSectionStateKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pluginsState = JsEngine.instance.map((engine) => engine.plugin).toList().map((p) => p.stateMap).toList();
    _pluginsState.insert(0, {
      "plugin": Plugin(name: "local-memory", canBeToProvideSoundSource: true, path: "local"),
      "isSelected": true,
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _query = ModalRoute.of(context)?.settings.arguments as String;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                      _searchingResultSectionStateKey.currentState?.onSearching(text);
                    },
                  ),
                  SizedBox(height: 10),
                  _buildWidgetOfSoundSources(),
                ],
              ),
            ),
            SearchingResultSection(key: _searchingResultSectionStateKey, plugins: _pluginsState, firstSearchingText: _query),
            SoundPlayer(audioPlayer: GlobalData().defualtAudioPlayer),
          ],
        ),
      ),
    );
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
                    _searchingResultSectionStateKey.currentState!._isSearching) {
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
  final String firstSearchingText;

  const SearchingResultSection({super.key, required this.plugins, required this.firstSearchingText});

  @override
  State<StatefulWidget> createState() => _SearchingResultSectionState();
}

class _SearchingResultSectionState extends State<SearchingResultSection> {
  bool _isSearching = true;
  final List<Sound> _searchingContents = [];
  final List<String> _canScanPathInLocal = AppSettingsController().allOfScaningPaths();

  _SearchingResultSectionState();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    onSearching(widget.firstSearchingText);
  }

  @override
  Widget build(BuildContext context) {
    var itemCount = _isSearching ? 1 : _searchingContents.length;

    return Expanded(
      child: ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) {
          if (_isSearching) {
            return Center(
              child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red), strokeWidth: 3),
            );
          } else {
            var source = _searchingContents[index];
            if (source is Song) {
              return ListTile(title: Text(source.name));
            }
          }
          return SizedBox.shrink();
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
        if (plugin['plugin'].name == "local-memory" && plugin['isSelected'] == true) {
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
      _isSearching = false;
    });
  }

  Future<List<Sound>> _scanLocalSourceFiles() async {
    List<Sound> sounds = [];
    List<String> format = ['.mp3', '.wav', '.aac', '.flac'];
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
                TextButton(child: const Text('取消'), onPressed: () => Navigator.pop(ctx)),
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
      final directoryUri = await FileTools.requestDirectoryAccess(directoryPath: path);
      // 2. 如果成功获取到目录URI，则扫描文件
      if (directoryUri!["path"].toString().isNotEmpty) {
        final files = await FileTools.scanFiles(directoryUri["uri"], format);
        for (var item in files) {
          Song s = Song(name: item["name"], singer: "", sourcePath: item["path"], isLocal: true, format: SoundFormat.mp3);
          switch (item["suffix"].toString().toLowerCase()) {
            case 'wav':
              s.format = SoundFormat.wav;
              break;
            case 'aac':
              s.format = SoundFormat.aac;
              break;
            case 'flac':
              s.format = SoundFormat.flac;
              break;
          }
          sounds.add(s);
        }
      }
    }
    return sounds;
  }
}

extension _PluginExtenxion on Plugin {
  Map<String, dynamic> get stateMap => {'plugin': this, 'isSelected': false};
}
