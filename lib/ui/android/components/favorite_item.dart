import 'dart:developer';

import 'package:flutter/material.dart';

class FavoriteItem extends StatelessWidget {
  const FavoriteItem({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log("点击事件");
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
