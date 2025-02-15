// widgets/sign_video_player.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../services/video_service.dart';

class SignVideoPlayer extends StatefulWidget {
  final String text;

  SignVideoPlayer({required this.text});

  @override
  _SignVideoPlayerState createState() => _SignVideoPlayerState();
}

class _SignVideoPlayerState extends State<SignVideoPlayer> {
  late VideoPlayerController _controller;
  List<String> _words = [];
  int _currentWordIndex = 0;

  @override
  void initState() {
    super.initState();
    _words = VideoService.processText(widget.text);
    if (_words.isNotEmpty) {
      _initializeVideo(_words[0]);
    }
  }

  void _initializeVideo(String word) {
    final videoPath = VideoService.getVideoPathForWord(word);
    if (videoPath != null) {
      _controller = VideoPlayerController.asset(videoPath)
        ..initialize().then((_) {
          setState(() {});
          _controller.play();
          _controller.addListener(_onVideoComplete);
        });
    }
  }

  void _onVideoComplete() {
    if (_controller.value.position >= _controller.value.duration) {
      if (_currentWordIndex < _words.length - 1) {
        _currentWordIndex++;
        _initializeVideo(_words[_currentWordIndex]);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      child: _controller.value.isInitialized
          ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}