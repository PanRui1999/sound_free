import 'package:flutter/material.dart';
import '../components/search_bar.dart' show TopSearchBar;
import '../components/favorite_item.dart' show FavoriteItem;
import '../components/SoundPlayer.dart' show SoundPlayer;
import 'package:just_audio/just_audio.dart' show AudioPlayer;

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
              onPressed: () {},
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
              TopSearchBar(),
              const SizedBox(height: 20),
              const FavoriteSection(),
              const SizedBox(height: 10),
              SoundPlayer(audioPlayer: AudioPlayer()),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoriteSection extends StatelessWidget {
  const FavoriteSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    "收藏",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 1,
                itemBuilder: (context, index) {
                  return FavoriteItem();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
