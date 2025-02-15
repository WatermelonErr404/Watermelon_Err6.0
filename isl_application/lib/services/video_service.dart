// services/video_service.dart
import 'package:video_player/video_player.dart';

class VideoService {
  static Map<String, String> wordToVideoPath = {
    'hello': 'assets/hello.mp4',
    'thank': 'assets/thank.mp4',
    'you': 'assets/you.mp4',
  };

  static String? getVideoPathForWord(String word) {
    print('Attempting to find video for word: ${word.toLowerCase()}');
    final videoPath = wordToVideoPath[word.toLowerCase()];
    print('Video path found: $videoPath');
    return videoPath;
  }

  static List<String> processText(String text) {
    print('Processing text: $text');
    final words = text.toLowerCase().split(' ');
    print('Split words: $words');
    final matchedWords = words.where((word) => wordToVideoPath.containsKey(word)).toList();
    print('Matched words: $matchedWords');
    return matchedWords;
  }
}