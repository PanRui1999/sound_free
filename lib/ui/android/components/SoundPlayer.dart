import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SoundPlayer extends StatefulWidget {
  const SoundPlayer({super.key});
  @override
  State<SoundPlayer> createState() => _SoundPlayer();
}

class _SoundPlayer extends State<SoundPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // Set a sequence of audio sources that will be played by the audio player.
    var playlist = <AudioSource>[
      AudioSource.uri(
        Uri.parse(
          "https://lv-sycdn.kuwo.cn/d42b064138c39bc645137030670b59b1/6835c115/resource/30106/trackmedia/M8000009TIka3l8J6p.mp3",
        ),
      ),
      AudioSource.uri(
        Uri.parse(
          "https://archive.org/download/igm-v8_202101/IGM%20-%20Vol.%208/15%20Pokemon%20Red%20-%20Cerulean%20City%20%28Game%20Freak%29.mp3",
        ),
      ),
      AudioSource.uri(
        Uri.parse(
          "https://scummbar.com/mi2/MI1-CD/01%20-%20Opening%20Themes%20-%20Introduction.mp3",
        ),
      ),
    ];
    _audioPlayer
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
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder<SequenceState>(
            stream: _audioPlayer.sequenceStateStream,
            builder: (_, __) {
              return _previousButton();
            },
          ),
          StreamBuilder<PlayerState>(
            stream: _audioPlayer.playerStateStream,
            builder: (_, snapshot) {
              final playerState = snapshot.data;
              if (playerState == null) {
                return _playPauseButton(ProcessingState.completed);
              } else {
                return _playPauseButton(playerState.processingState);
              }
            },
          ),
          StreamBuilder<SequenceState>(
            stream: _audioPlayer.sequenceStateStream,
            builder: (_, __) {
              return _nextButton();
            },
          ),
        ],
      ),
    );
  }

  Widget _playPauseButton(ProcessingState processingState) {
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return Container(
        margin: EdgeInsets.all(8.0),
        width: 64.0,
        height: 64.0,
        child: CircularProgressIndicator(),
      );
    } else if (_audioPlayer.playing != true) {
      return IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 64.0,
        onPressed: _audioPlayer.play,
      );
    } else if (processingState != ProcessingState.completed) {
      return IconButton(
        icon: Icon(Icons.pause),
        iconSize: 64.0,
        onPressed: _audioPlayer.pause,
      );
    } else {
      return IconButton(
        icon: Icon(Icons.replay),
        iconSize: 64.0,
        onPressed: () => _audioPlayer.seek(
          Duration.zero,
          index: _audioPlayer.effectiveIndices.first,
        ),
      );
    }
  }

  Widget _previousButton() {
    return IconButton(
      icon: Icon(Icons.skip_previous),
      onPressed: _audioPlayer.hasPrevious ? _audioPlayer.seekToPrevious : null,
    );
  }

  Widget _nextButton() {
    return IconButton(
      icon: Icon(Icons.skip_next),
      onPressed: _audioPlayer.hasNext ? _audioPlayer.seekToNext : null,
    );
  }
}
