import 'package:flutter/material.dart';

class FavoriteItem extends StatefulWidget {
  final String name;
  final ValueChanged<String> onDelete;
  final Future<String?> Function({String operation, String oldName}) onRename;

  const FavoriteItem({
    super.key,
    required this.name,
    required this.onDelete,
    required this.onRename,
  });

  @override
  State<StatefulWidget> createState() => _FavoriteItem();
}

class _FavoriteItem extends State<FavoriteItem> {
  late String _name;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _name = widget.name;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {},
      onLongPress: () async {
        var result = await showDialog<String>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, "edit"),
                    child: const Text(
                      '修改名称',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, "delete"),
                    child: Text(
                      '删除收藏',
                      style: TextStyle(fontSize: 20),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          },
        );
        // check
        if (context.mounted) {
          switch (result) {
            case "edit":
              var newName = await widget.onRename(
                operation: 'edit',
                oldName: _name,
              );
              if (newName != null) {
                _name = newName;
                setState(() {});
              }
              break;
            case "delete":
              widget.onDelete(_name);
              break;
          }
        }
      },
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
                _name,
                overflow: TextOverflow.clip,
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: 22),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
