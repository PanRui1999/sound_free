import 'package:flutter/material.dart';
import 'package:sound_free/models/plugin.dart';
import 'package:sound_free/tools/global_data.dart';
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

  @override
  void initState() {
    _pluginsState = GlobalData().runningPlugins.map((p) => p.stateMap).toList();
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
                  TopSearchBar(text: _query),
                  SizedBox(height: 10),
                  _buildWidgetOfSoundSources(),
                ],
              ),
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
                      ? Colors.red.withOpacity(0.2) // 选中背景
                      : Colors.grey.withOpacity(0.1),
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

extension _PluginExtenxion on Plugin {
  Map<String, dynamic> get stateMap => {'plugin': this, 'isSelected': false};
}
