import 'package:flutter/material.dart';
import 'package:isl_application/services/video_service.dart';
import 'package:isl_application/utils/language_utils.dart';
import 'package:video_player/video_player.dart';

class TextToISLScreen extends StatefulWidget {
  const TextToISLScreen({super.key});

  @override
  _TextToISLScreenState createState() => _TextToISLScreenState();
}

class _TextToISLScreenState extends State<TextToISLScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isShowingSign = false;
  bool _isProcessing = false;
  bool _isLoadingVideo = false;
  String _statusMessage = '';

  VideoPlayerController? _videoController;
  int _currentWordIndex = 0;
  List<String> _wordsToPlay = [];
  AppLanguage _currentLanguage = AppLanguage.english;

  @override
  void dispose() {
    _textController.dispose();
    _cleanupVideo();
    super.dispose();
  }

  Future<void> _processAndShowSigns() async {
    if (_isProcessing || _textController.text.trim().isEmpty) return;

    await _cleanupVideo();

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Processing text...';
      _isShowingSign = false;
      _currentWordIndex = 0;
      _wordsToPlay = [];
    });

    try {
      final words = VideoService.processText(
        _textController.text.trim(),
        _currentLanguage,
      );

      if (words.isEmpty) {
        throw Exception('No sign language videos found for these words');
      }

      setState(() {
        _isShowingSign = true;
        _wordsToPlay = words;
        _currentWordIndex = 0;
        _statusMessage = 'Loading sign language...';
      });

      await _playNextWord();
    } catch (e) {
      _showErrorSnackBar(e.toString());
      setState(() {
        _isShowingSign = false;
        _currentWordIndex = 0;
        _wordsToPlay = [];
      });
    } finally {
      setState(() {
        _isProcessing = false;
        _statusMessage = '';
      });
    }
  }

  Future<void> _playNextWord() async {
    if (_currentWordIndex >= _wordsToPlay.length) {
      await _cleanupVideo();
      _resetScreen();
      return;
    }

    if (_currentWordIndex < 0 || _wordsToPlay.isEmpty) {
      await _cleanupVideo();
      return;
    }

    final videoPath = VideoService.getVideoPathForWord(
      _wordsToPlay[_currentWordIndex],
      _currentLanguage,
    );

    if (videoPath == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "No video available for \"${_wordsToPlay[_currentWordIndex]}\"",
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      _currentWordIndex++;
      await _playNextWord();
      return;
    }

    try {
      await _cleanupVideo();
      _videoController = VideoPlayerController.asset(videoPath);

      setState(() => _isLoadingVideo = true);
      await _videoController!.initialize();

      if (!mounted) return;
      setState(() => _isLoadingVideo = false);

      _videoController!.removeListener(_onVideoProgress);
      _videoController!.addListener(_onVideoProgress);

      if (!mounted) return;
      await _videoController!.play();
    } catch (e) {
      debugPrint('Error playing video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error playing video for \"${_wordsToPlay[_currentWordIndex]}\"",
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      _currentWordIndex++;
      await _playNextWord();
    }
  }

  void _onVideoProgress() {
    if (_videoController == null || !mounted) return;

    if (_videoController!.value.position >= _videoController!.value.duration) {
      _currentWordIndex++;
      _playNextWord();
    }
  }

  Future<void> _cleanupVideo() async {
    try {
      if (_videoController != null) {
        _videoController!.removeListener(_onVideoProgress);
        await _videoController!.pause();
        await _videoController!.dispose();
        _videoController = null;
      }
    } catch (e) {
      debugPrint('Error cleaning up video: $e');
    }
  }

  void _resetScreen() {
    setState(() {
      _isShowingSign = false;
      _currentWordIndex = 0;
      _wordsToPlay = [];
      _statusMessage = '';
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Text to ISL',
          style: Theme.of(context)
              .textTheme
              .displayMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [_buildLanguageSelector(isDarkMode)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    _statusMessage,
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
              _buildTextInput(isDarkMode),
              const SizedBox(height: 20),
              _buildConvertButton(),
              const SizedBox(height: 20),
              if (_isShowingSign) Expanded(child: _buildVideoContainer()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[800] : Colors.white,
          border: Border.all(color: Colors.blue[100]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton<AppLanguage>(
          value: _currentLanguage,
          dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
          underline: Container(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          items: _buildLanguageMenuItems(),
          onChanged: _onLanguageChanged,
        ),
      ),
    );
  }

  List<DropdownMenuItem<AppLanguage>> _buildLanguageMenuItems() {
    return AppLanguage.values.map((AppLanguage language) {
      return DropdownMenuItem<AppLanguage>(
        value: language,
        child: Text(
          LanguageUtils.getLanguageName(language),
          style: TextStyle(
            color: Colors.blue[700],
            fontWeight: _currentLanguage == language
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      );
    }).toList();
  }

  void _onLanguageChanged(AppLanguage? newValue) {
    if (newValue != null && newValue != _currentLanguage) {
      setState(() {
        _currentLanguage = newValue;
        _isShowingSign = false;
        _statusMessage = '';
      });
      _cleanupVideo();
    }
  }

  Widget _buildTextInput(bool isDarkMode) {
    return TextField(
      controller: _textController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Enter text to convert to ISL...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
      ),
    );
  }

  Widget _buildConvertButton() {
    return ElevatedButton(
      onPressed: _isProcessing ? null : _processAndShowSigns,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        backgroundColor: Colors.blue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        _isProcessing ? 'Converting...' : 'Convert to ISL',
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }

  Widget _buildVideoContainer() {
    if (_isLoadingVideo) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Center(child: Text('Preparing video...'));
    }

    return SizedBox(
      height: 10,
      width: 400, // Adjust the height as needed
      child: AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      ),
    );
  }
}
