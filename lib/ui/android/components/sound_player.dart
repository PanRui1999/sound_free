import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:sound_free/models/song.dart';
import 'package:sound_free/models/sound.dart';

class SoundPlayer extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const SoundPlayer({super.key, required this.audioPlayer});
  @override
  State<SoundPlayer> createState() => _SoundPlayer();
}

class _SoundPlayer extends State<SoundPlayer> {
  final List<Song> _playList = [];

  @override
  void initState() {
    super.initState();
    // Set a sequence of audio sources that will be played by the audio player.
    var playlist = <AudioSource>[
      AudioSource.uri(
        Uri.parse("http://music.163.com/song/media/outer/url?id=447925558.mp3"),
      ),
    ];
    _playList.add(
      Song(
        name: "test1",
        singer: "周",
        sourcePath: "pathtest1",
        isLocal: false,
        format: SoundFormat.mp3,
      ),
    );
    _playList.add(
      Song(
        name: "test2",
        singer: "刘",
        sourcePath: "pathtest1",
        isLocal: false,
        format: SoundFormat.mp3,
      ),
    );
    _playList.add(
      Song(
        name: "test3",
        singer: "张",
        sourcePath: "pathtest1",
        isLocal: false,
        format: SoundFormat.mp3,
      ),
    );
    _playList.add(
      Song(
        name: "test1",
        singer: "周",
        sourcePath: "pathtest1",
        isLocal: false,
        format: SoundFormat.mp3,
      ),
    );
    _playList.add(
      Song(
        name: "test2",
        singer: "刘",
        sourcePath: "pathtest1",
        isLocal: false,
        format: SoundFormat.mp3,
      ),
    );
    _playList.add(
      Song(
        name: "test3",
        singer: "张",
        sourcePath: "pathtest1",
        isLocal: false,
        format: SoundFormat.mp3,
      ),
    );
    widget.audioPlayer
        .setAudioSources(
          playlist,
          initialIndex: 0,
          initialPosition: Duration.zero,
        )
        .catchError((error) {
          // catch load errors: 404, invalid url ...
          log("配置音源时发生错误 $error", level: 99);
          return null;
        });
  }

  @override
  void dispose() {
    widget.audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
        ),
      ),
      child: Column(
        children: [
          LinearProgressIndicator(
            minHeight: 2,
            value: 0.5,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation(Colors.red),
          ),
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
                            stream: widget.audioPlayer.sequenceStateStream,
                            builder: (_, __) {
                              return _previousButton();
                            },
                          ),
                          StreamBuilder<PlayerState>(
                            stream: widget.audioPlayer.playerStateStream,
                            builder: (_, snapshot) {
                              final playerState = snapshot.data;
                              if (playerState == null) {
                                return _playPauseButton(
                                  ProcessingState.completed,
                                );
                              } else {
                                return _playPauseButton(
                                  playerState.processingState,
                                );
                              }
                            },
                          ),
                          StreamBuilder<SequenceState>(
                            stream: widget.audioPlayer.sequenceStateStream,
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

  Widget _playPauseButton(ProcessingState processingState) {
    const iconSize = 50.0;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return Container(
        margin: EdgeInsets.all(8.0),
        width: iconSize,
        height: iconSize,
        child: CircularProgressIndicator(),
      );
    } else if (widget.audioPlayer.playing != true) {
      return IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: iconSize,
        onPressed: widget.audioPlayer.play,
      );
    } else if (processingState != ProcessingState.completed) {
      return IconButton(
        icon: Icon(Icons.pause),
        iconSize: iconSize,
        onPressed: widget.audioPlayer.pause,
      );
    } else {
      return IconButton(
        icon: Icon(Icons.replay),
        iconSize: iconSize,
        onPressed: () => widget.audioPlayer.seek(
          Duration.zero,
          index: widget.audioPlayer.effectiveIndices.first,
        ),
      );
    }
  }

  Widget _previousButton() {
    return IconButton(
      iconSize: 36,
      icon: Icon(Icons.skip_previous),
      onPressed: widget.audioPlayer.hasPrevious
          ? widget.audioPlayer.seekToPrevious
          : null,
    );
  }

  Widget _nextButton() {
    return IconButton(
      iconSize: 36,
      icon: Icon(Icons.skip_next),
      onPressed: widget.audioPlayer.hasNext
          ? widget.audioPlayer.seekToNext
          : null,
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
          onPressed: () => widget.audioPlayer.seek(Duration.zero, index: index),
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
}
