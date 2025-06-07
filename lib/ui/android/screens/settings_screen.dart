// 新建 settings_screen.dart 文件
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('应用设置')),
      body: Padding(
        padding: EdgeInsetsGeometry.all(6),
        child: ListView(
          children: [
            _buildScanDirectory(),
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

  Widget _buildScanDirectory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: const Text('本地音乐目录', style: TextStyle(fontSize: 20.0)),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.add),
              iconSize: 24,
              alignment: Alignment.topLeft, // 按钮自身顶部对齐
            ),
          ],
        ),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "text1",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.remove)),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "text1",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.remove)),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "text1",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.remove)),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
