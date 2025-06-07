import 'package:flutter/material.dart';
import 'package:sound_free/models/song.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sound_free/models/sound.dart';

class SoundPlayer extends StatefulWidget {
  final List<Sound> _soundList = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  final double _componentHeight = 120;

  SoundPlayer({super.key});
  @override
  State<SoundPlayer> createState() => _SoundPlayer();
}

class _SoundPlayer extends State<SoundPlayer> {
  final List<Song> _playList = [];
  final double _progress = 0.2;

  @override
  void initState() {
    super.initState();
    // Set a sequence of audio sources that will be played by the audio player.
  }

  @override
  void dispose() {
    widget._audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget._componentHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: CircleAvatar(
                    radius: 38,
                    backgroundImage: AssetImage(
                      "assets/images/Vinyl_image.png",
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(height: 10),
                      Expanded(
                        child: Text(
                          "测试歌曲名称测试歌曲名称测试歌曲名称测试歌曲名称测试歌曲名称测试歌曲名称测试歌曲名称测试歌曲名称",
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          StreamBuilder<SequenceState>(
                            stream: widget._audioPlayer.sequenceStateStream,
                            builder: (_, __) {
                              return _previousButton();
                            },
                          ),
                          StreamBuilder<PlayerState>(
                            stream: widget._audioPlayer.playerStateStream,
                            builder: (_, snapshot) {
                              return _playPauseButton(snapshot.data);
                            },
                          ),
                          StreamBuilder<SequenceState>(
                            stream: widget._audioPlayer.sequenceStateStream,
                            builder: (_, __) {
                              return _nextButton();
                            },
                          ),
                          Padding(
                            padding: EdgeInsetsGeometry.only(left: 30.0),
                            child: _playListIconButton(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    const double thumbRadius = 5.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        double trackWidth = constraints.maxWidth;
        return Container(
          height: thumbRadius * 3, // 增加容器高度
          alignment: Alignment.center, // 垂直居中
          child: GestureDetector(
            behavior: HitTestBehavior.opaque, // 扩大点击区域
            onHorizontalDragUpdate: (details) {
              setState(() {
                _progress = (details.localPosition.dx / trackWidth).clamp(
                  0.0,
                  1.0,
                );
              });
            },
            onHorizontalDragEnd: (_) {
              _onProgressChanged(_progress);
            },
            child: Stack(
              clipBehavior: Clip.none, // 允许子组件溢出
              children: [
                // 进度条前景
                Positioned(
                  left: 0,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 10),
                    width: trackWidth * _progress,
                    height: 2,
                    color: Colors.red,
                  ),
                ),
                // 滑块指示器
                Positioned(
                  left: trackWidth * _progress - thumbRadius,
                  top: -thumbRadius,
                  child: Container(
                    width: thumbRadius * 2,
                    height: thumbRadius * 2,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _playPauseButton(PlayerState? playerState) {
    const iconSize = 50.0;
    if (playerState == null ||
        playerState.processingState == ProcessingState.idle) {
      return IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: iconSize,
        onPressed: () {},
      );
    }
    if (playerState.playing) {
      if (playerState.processingState == ProcessingState.completed ||
          playerState.processingState == ProcessingState.loading ||
          playerState.processingState == ProcessingState.buffering) {
        return IconButton(
          icon: Icon(Icons.pause),
          iconSize: iconSize,
          onPressed: widget._audioPlayer.pause,
        );
      }
      return IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: iconSize,
        onPressed: () {},
      );
    } else {
      if (playerState.processingState == ProcessingState.loading ||
          playerState.processingState == ProcessingState.buffering) {
        return Container(
          margin: EdgeInsets.all(8.0),
          width: iconSize,
          height: iconSize,
          child: CircularProgressIndicator(),
        );
      }
      return IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: iconSize,
        onPressed: widget._audioPlayer.play,
      );
    }
  }

  Widget _previousButton() {
    return IconButton(
      iconSize: 36,
      icon: Icon(Icons.skip_previous),
      onPressed: widget._audioPlayer.seekToPrevious,
    );
  }

  Widget _nextButton() {
    return IconButton(
      iconSize: 36,
      icon: Icon(Icons.skip_next),
      onPressed: widget._audioPlayer.seekToNext,
    );
  }

  Widget _playListIconButton() {
    return IconButton(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => StatefulBuilder(
            builder: (context, setModelState) {
              return Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                ),
                child: Column(
                  children: [
                    // 顶部控制栏
                    Container(
                      height: 50,
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('播放列表'),
                          IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    // 播放列表
                    Expanded(
                      child: ListView.builder(
                        itemCount: _playList.length,
                        itemBuilder: (context, index) {
                          return _buildPlaylistItem(
                            context,
                            index,
                            setModelState,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
      icon: Icon(Icons.list),
      iconSize: 28.0,
    );
  }

  Widget _buildPlaylistItem(context, index, setModelState) {
    final metadata = _playList[index];
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        children: [
          Icon(
            Icons.music_note,
            size: 24,
            color: index == 0 ? Colors.red : Colors.grey[600],
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metadata.name,
                  style: TextStyle(
                    fontSize: 16,
                    color: index == 0 ? Colors.red : Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                Text(
                  metadata.singer,
                  style: TextStyle(
                    fontSize: 12,
                    color: index == 0 ? Colors.red : Colors.grey[600],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          _buildActionButtons(index, setModelState),
        ],
      ),
    );
  }

  Widget _buildActionButtons(index, setModelState) {
    const iconSize = 24.0;
    if (index == 0) {
      // in playing
      return SizedBox();
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          iconSize: iconSize,
          icon: Icon(Icons.play_arrow, color: Colors.blue),
          onPressed: () {},
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          iconSize: iconSize,
          icon: Icon(
            Icons.upgrade,
            color: index == 1 ? Colors.white : Colors.blue,
          ),
          onPressed: () {
            if (index == 1) return;
            var temp = _playList[index];
            _playList.removeAt(index);
            _playList.insert(1, temp);
            setModelState(() {});
          },
        ),
        IconButton(
          padding: EdgeInsets.zero,
          constraints: BoxConstraints(),
          iconSize: iconSize,
          icon: Icon(Icons.delete, color: Colors.grey[600]),
          onPressed: () {
            _playList.removeAt(index);
            setModelState(() {});
          },
        ),
      ],
    );
  }

  void _onProgressChanged(double progress) {
    // 这里实现实际进度改变逻辑，例如：
    // widget._audioPlayer.seek(Duration(seconds: (totalDuration * progress).toInt()));
    print('进度更新到: ${(progress * 100).toStringAsFixed(1)}%');
  }
}
