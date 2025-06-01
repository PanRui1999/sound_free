import 'package:flutter/material.dart';
import 'package:sound_free/models/favorites_collection.dart';
import 'package:sound_free/controllers/hive_favorites_controller.dart';
import 'package:sound_free/ui/android/components/favorite_item.dart';

class FavoriteSection extends StatefulWidget {
  const FavoriteSection({super.key});
  @override
  State<FavoriteSection> createState() => _FavoriteSectionState();
}

class _FavoriteSectionState extends State<FavoriteSection> {
  final List<FavoritesCollection> favoriteItems = [];
  final HiveFavoritesController _controller = HiveFavoritesController();
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshFavoritesList();
  }

  void _refreshFavoritesList() {
    favoriteItems.clear();
    favoriteItems.addAll(_controller.all());
  }

  void _newFavoriteItem(String name) {
    if (_controller.add(name)) {
      favoriteItems.add(FavoritesCollection(name: name));
      setState(() {});
    }
  }

  void _editFavoriteItem(String oldName, String newName) {
    var f = favoriteItems.firstWhere((e)=> e.name == oldName);
    if (_controller.rename(f, newName)) {
      f.name = newName;
    }
  }

  void _deleteFavoriteItem(String name) {
    if (_controller.delete(name)) {
      favoriteItems.removeWhere((element) => element.name == name);
      setState(() {});
    }
  }

  Future<String?> newFavoriteItem({
    String operation = 'new',
    String oldName = ''
  }) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: _textEditingController,
          decoration: InputDecoration(hintText: "请输入收藏夹名称"),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _textEditingController.clear();
              Navigator.pop(context);
            },
            child: Text("取消"),
          ),
          TextButton(
            onPressed: () {
              if (_textEditingController.text.isNotEmpty) {
                Navigator.pop(context, _textEditingController.text);
              }
              _textEditingController.clear();
            },
            child: Text("确认"),
          ),
        ],
      ),
    );
    if (result != null) {
      if (operation == 'new') {
        _newFavoriteItem(result);
      } else if (operation == 'edit') {
        _editFavoriteItem(oldName, result);
      }
    }
    return result;
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
            const SizedBox(height: 8),
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
                  return index == favoriteItems.length
                      ? FavoriteAddSection(onTap: newFavoriteItem)
                      : FavoriteItem(
                          key: Key(favoriteItems[index].name),
                          name: favoriteItems[index].name,
                          onDelete: _deleteFavoriteItem,
                          onRename: newFavoriteItem,
                        );
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
  final VoidCallback onTap;

  const FavoriteAddSection({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.grey),
            const SizedBox(width: 6.0),
            Text(
              "新建收藏夹",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
