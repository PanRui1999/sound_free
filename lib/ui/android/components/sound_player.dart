import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SoundPlayer extends StatefulWidget {
  final AudioPlayer audioPlayer;

  const SoundPlayer({super.key, required this.audioPlayer});
  @override
  State<SoundPlayer> createState() => _SoundPlayer();
}

class _SoundPlayer extends State<SoundPlayer> {
  @override
  void initState() {
    super.initState();
    // Set a sequence of audio sources that will be played by the audio player.
    var playlist = <AudioSource>[
      AudioSource.uri(
        Uri.parse("http://music.163.com/song/media/outer/url?id=447925558.mp3"),
      ),
    ];
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
                            child: IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.list),
                              iconSize: 28.0,
                            ),
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
}
