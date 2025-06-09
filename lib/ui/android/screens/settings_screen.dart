import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sound_free/controllers/app_settings_controller.dart';

class SettingsScreen extends StatefulWidget {
  final _appSettingsController = AppSettingsController();

  SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  List? _scanningPaths;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scanningPaths = widget._appSettingsController.allOfScaningPaths();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('应用设置')),
      body: Padding(
        padding: EdgeInsetsGeometry.all(6),
        child: ListView(
          children: [
            _buildScanDirectory(context),
            SizedBox(height: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('关于本软件', style: TextStyle(fontSize: 20.0)),
                const Text(
                  '本软件完全开源免费且采用GLPv3协议。项目源码托管于Github。如果你以任何付费的方式获得此软件请联系对方进行退款投诉以保障你的权益。',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: TextButton(
                      onPressed: () async {
                        final Uri url = Uri.parse(
                          'https://github.com/PanRui1999/sound_free',
                        );
                        if (!await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        )) {
                          throw Exception('无法打开 $url');
                        }
                      },
                      child: const Text("访问此软件的Github仓库"),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScanDirectory(context) {
    List<Widget> scanningItems = [];
    for (var path in _scanningPaths!) {
      scanningItems.add(
        Row(
          children: [
            Expanded(
              child: Text(
                path,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            IconButton(
              onPressed: () {
                widget._appSettingsController.deleteScaningPath(path);
                setState(() {
                  _scanningPaths?.removeWhere((p)=> p == path);
                });
              },
              icon: Icon(Icons.remove),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: const Text('本地音乐目录', style: TextStyle(fontSize: 20.0)),
            ),
            IconButton(
              onPressed: () async {
                final status = await Permission.storage.request();
                if (!status.isGranted) {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text('需要存储权限'),
                      content: Text('请授予存储权限以选择音乐目录'),
                    ),
                  );
                  return;
                }
                String? selectedDirectory = await FilePicker.platform
                    .getDirectoryPath();
                if (selectedDirectory != null &&
                    selectedDirectory.isNotEmpty &&
                    _scanningPaths!.contains(selectedDirectory) == false) {
                  widget._appSettingsController.addScaningPath(
                    selectedDirectory,
                  );
                  setState(() {
                    _scanningPaths!.add(selectedDirectory);
                  });
                }
              },
              icon: Icon(Icons.add),
            ),
          ],
        ),
        Column(children: scanningItems),
      ],
    );
  }
}
