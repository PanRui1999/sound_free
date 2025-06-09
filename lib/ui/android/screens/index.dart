import 'package:flutter/material.dart';
import 'package:sound_free/tools/global_data.dart';
import 'package:sound_free/ui/android/screens/searching_screen.dart';
import 'package:sound_free/ui/android/screens/settings_screen.dart';
import '../components/search_bar.dart' show TopSearchBar;
import '../components/sound_player.dart' show SoundPlayer;
import 'package:sound_free/ui/android/components/favorites_list.dart';

class Index extends StatelessWidget {
  const Index({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 36, 36),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 36, 36, 36),
        title: Column(
          children: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
              icon: Icon(Icons.settings),
              color: Colors.white,
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
          child: Column(
            children: [
              TopSearchBar(
                onSearch: (text, textEditingController) {
                  if (text.isEmpty) return;
                  textEditingController.clear();
                  FocusScope.of(context).unfocus();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SearchingScreen(),
                      settings: RouteSettings(arguments: text),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const FavoriteSection(),
              const SizedBox(height: 10),
              SoundPlayer(audioPlayer: GlobalData().defualtAudioPlayer),
            ],
          ),
        ),
      ),
    );
  }
}
