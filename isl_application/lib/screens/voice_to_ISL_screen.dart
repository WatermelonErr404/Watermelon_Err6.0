// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:isl_application/services/video_service.dart';
import 'package:isl_application/utils/language_utils.dart';
import 'package:isl_application/widgets/sign_video_player.dart';
import 'package:video_player/video_player.dart';
import '../services/speech_service.dart';
import '../widgets/custom_button.dart';

class VoiceToISLScreen extends StatefulWidget {
  @override
  _VoiceToISLScreenState createState() => _VoiceToISLScreenState();
} // screens/home_screen.dart

class _VoiceToISLScreenState extends State<VoiceToISLScreen> {
  final SpeechService _speechService = SpeechService();
  String _transcribedText = '';
  bool _isListening = false;
  bool _isShowingSign = false;
  bool _isInitialized = false;
  
  VideoPlayerController? _videoController;
  int _currentWordIndex = 0;
  List<String> _wordsToPlay = [];
  AppLanguage _currentLanguage = AppLanguage.english;
  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _debugCheckVideoAssets(); // Add this to verify video assets
  }

  void _debugCheckVideoAssets() async {
    final videoPath = VideoService.getVideoPathForWord(
        _wordsToPlay[_currentWordIndex], _currentLanguage);
    print('Debug: Checking video path: $videoPath');

    if (videoPath != null) {
      try {
        final controller = VideoPlayerController.asset(videoPath);
        await controller.initialize();
        print('Debug: Video successfully loaded!');
        controller.dispose();
      } catch (e) {
        print('Debug: Error loading video: $e');
      }
    }
  }

  Future<void> _initializeSpeech() async {
    try {
      final initialized = await _speechService.initialize();
      setState(() {
        _isInitialized = initialized;
      });
    } catch (e) {
      print('Error during initialization: $e');
    }
  }

  void _startListening() async {
    if (!_isInitialized) {
      final initialized = await _speechService.initialize();
      if (!initialized) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Speech recognition not available'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isListening = true);

    await _speechService.startListening(
      onResult: (text) {
        setState(() => _transcribedText = text);
      },
      onError: (error) {
        print('Error: $error');
        setState(() => _isListening = false);
      },
      language: _currentLanguage,
    );
  }

  void _stopListening() async {
    await _speechService.stopListening();
    setState(() => _isListening = false);

    if (_transcribedText.isNotEmpty) {
      print('Transcribed text: $_transcribedText');
      _processAndShowSigns();
    }
  }

  void _processAndShowSigns() async {
    final words = VideoService.processText(_transcribedText, _currentLanguage);
    print('Debug: Words to process: $words');

    if (words.isEmpty) {
      print('Debug: No matching words found');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('No sign language videos found for these words')),
      );
      return;
    }

    setState(() {
      _isShowingSign = true;
      _wordsToPlay = words;
      _currentWordIndex = 0;
    });

    _playNextWord();
  }

  void _playNextWord() async {
    if (_currentWordIndex >= _wordsToPlay.length) {
      setState(() {
        _isShowingSign = false;
        _videoController?.dispose();
        _videoController = null;
      });
      return;
    }

    final videoPath = VideoService.getVideoPathForWord(
        _wordsToPlay[_currentWordIndex], _currentLanguage);
    print('Debug: Playing video path: $videoPath');

    if (videoPath == null) {
      _currentWordIndex++;
      _playNextWord();
      return;
    }

    try {
      _videoController?.dispose();
      _videoController = VideoPlayerController.asset(videoPath);

      await _videoController!.initialize();
      setState(() {}); // Trigger rebuild after initialization

      _videoController!.addListener(() {
        if (_videoController!.value.position >=
            _videoController!.value.duration) {
          _currentWordIndex++;
          _playNextWord();
        }
      });

      _videoController!.play();
    } catch (e) {
      print('Debug: Error playing video: $e');
      _currentWordIndex++;
      _playNextWord();
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ISL Translator'),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: DropdownButton<AppLanguage>(
              value: _currentLanguage,
              dropdownColor: Theme.of(context).primaryColor,
              underline: Container(),
              icon: Icon(Icons.language, color: Colors.blue),
              items: AppLanguage.values.map((AppLanguage language) {
                return DropdownMenuItem<AppLanguage>(
                  value: language,
                  child: Text(
                    LanguageUtils.getLanguageName(language),
                    style: TextStyle(
                      color: _currentLanguage == language
                          ? Colors.black
                          : Colors.blue,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (AppLanguage? newValue) {
                if (newValue != null) {
                  setState(() {
                    _currentLanguage = newValue;
                    _transcribedText = '';
                    _isShowingSign = false;
                    _videoController?.dispose();
                    _videoController = null;
                  });
                }
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomButton(
              onPressed: _isInitialized
                  ? (_isListening ? _stopListening : _startListening)
                  : null,
              isListening: _isListening,
              isEnabled: _isInitialized,
            ),
            SizedBox(height: 20),
            if (_transcribedText.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _transcribedText,
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(height: 20),
            if (_isShowingSign &&
                _videoController != null &&
                _videoController!.value.isInitialized)
              Container(
                height: 300, // Fixed height for video container
                child: AspectRatio(
                  aspectRatio: _videoController!.value.aspectRatio,
                  child: VideoPlayer(_videoController!),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
