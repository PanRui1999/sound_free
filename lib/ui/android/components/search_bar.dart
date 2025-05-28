import 'package:flutter/material.dart';

class TopSearchBar extends StatefulWidget {
  final Function(String)? onSearch; // 搜索回调

  const TopSearchBar({super.key, this.onSearch});

  @override
  State<TopSearchBar> createState() => _TopSearchBarState();
}

class _TopSearchBarState extends State<TopSearchBar> {
  // 添加文本控制器来管理输入内容
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    // 销毁控制器以防内存泄漏
    _textController.dispose();
    super.dispose();
  }

  // 处理搜索按钮点击
  void _handleSearch() {
    final searchText = _textController.text;
    // 调用搜索回调
    if (widget.onSearch != null) {
      widget.onSearch!(searchText);
    }
    // 清空输入框
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.fromLTRB(12, 2, 2, 2),
      height: 40.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4.0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController, // 使用控制器
              decoration: InputDecoration(
                hintText: '搜索音频...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 12.0),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(fontSize: 14.0),
            ),
          ),
          TextButton(
            onPressed: _handleSearch, // 设置按钮点击回调
            child: Text("搜索"),
          ),
        ],
      ),
    );
  }
}
