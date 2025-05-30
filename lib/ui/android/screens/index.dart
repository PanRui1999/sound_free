import 'package:flutter/material.dart';
import 'package:sound_free/models/favorites_collection.dart';
import '../components/search_bar.dart' show TopSearchBar;
import '../components/sound_player.dart' show SoundPlayer;
import 'package:just_audio/just_audio.dart' show AudioPlayer;
import 'package:sound_free/controllers/hive_favorites_controller.dart';
import 'package:sound_free/ui/android/components/favorite_item.dart';

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

/// 中间的收藏夹部分
class FavoriteSection extends StatefulWidget {
  const FavoriteSection({super.key});
  @override
  State<FavoriteSection> createState() => _FavoriteSectionState();
}

class _FavoriteSectionState extends State<FavoriteSection> {
  final List<FavoritesCollection> favoriteItems = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var box = HiveFavoritesController().obtainBox();
    for (var key in box.keys) {
      var v = box.get(key);
      if (v == null) continue;
      favoriteItems.add(v);
    }
  }

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
                itemCount: favoriteItems.length + 1,
                itemBuilder: (context, index) {
                  if (index == favoriteItems.length) {
                    return FavoriteAddSection();
                  } else {
                    return FavoriteItem(name: favoriteItems[index].name);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoriteAddSection extends StatelessWidget {
  const FavoriteAddSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.all(10),
        child: Row(
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: AssetImage("assets/images/favorites_image.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                "新建收藏夹",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 22, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
