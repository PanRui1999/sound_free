import 'dart:developer';

import 'package:flutter/material.dart';

class FavoriteItem extends StatefulWidget {
  final String name;

  const FavoriteItem({super.key, required this.name});

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
      onTap: () {
        log("${_name}：点击事件");
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
