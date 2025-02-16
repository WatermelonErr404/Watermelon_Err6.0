import 'dart:async';
import 'package:flutter/material.dart';
import 'package:isl_application/services/video_service.dart';
import 'package:isl_application/utils/language_utils.dart';
import 'package:video_player/video_player.dart';
import '../services/speech_service.dart';
import '../widgets/custom_button.dart';

class VoiceToISLScreen extends StatefulWidget {
  const VoiceToISLScreen({super.key});

  @override
  _VoiceToISLScreenState createState() => _VoiceToISLScreenState();
}

class _VoiceToISLScreenState extends State<VoiceToISLScreen>
    with WidgetsBindingObserver {
  final SpeechService _speechService = SpeechService();
  String _transcribedText = '';
  bool _isListening = false;
  bool _isShowingSign = false;
  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _isLoadingVideo = false;
  String _statusMessage = '';
  final Map<AppLanguage, List<String>> _frequentPhrases = {
    AppLanguage.english: [
      'Hello, how are you',
      'Thank you very much',
      'Can you help me',
      'See you later'
    ],
    AppLanguage.hindi: [
      'नमस्ते, कैसे हैं आप',
      'बहुत बहुत धन्यवाद',
      'क्या आप मेरी मदद कर सकते हैं',
      'फिर मिलेंगे'
    ],
  };
  double _playbackSpeed = 1.0;
  final List<double> _availableSpeeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
  VideoPlayerController? _videoController;
  int _currentWordIndex = 0;
  List<String> _wordsToPlay = [];
  AppLanguage _currentLanguage = AppLanguage.english;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSpeech();
  }

  void _onPhraseSelected(String phrase) {
    setState(() {
      _transcribedText = phrase;
    });
    _processAndShowSigns();
  }

  // Add new widget to build frequent phrases
  Widget _buildFrequentPhrases() {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _frequentPhrases[_currentLanguage]!.map((phrase) {
        return ElevatedButton(
          onPressed: _isProcessing ? null : () => _onPhraseSelected(phrase),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(12),
            backgroundColor: Colors.blue[100],
            foregroundColor: Colors.blue[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            phrase,
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        );
      }).toList(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _stopListening();
      _videoController?.pause();
    }
  }

  Future<void> _initializeSpeech() async {
    try {
      final initialized = await _speechService.initialize();
      setState(() {
        _isInitialized = initialized;
      });
    } catch (e) {
      debugPrint('Error during initialization: $e');
      _showErrorSnackBar('Failed to initialize speech recognition');
    }
  }

  Future<void> _startListening() async {
    if (!_isInitialized) {
      final initialized = await _speechService.initialize();
      if (!initialized) {
        _showErrorSnackBar('Speech recognition not available');
        return;
      }
    }

    setState(() {
      _isListening = true;
      _statusMessage = 'Listening...';
      _transcribedText = ''; // Clear previous text
    });

    try {
      await _speechService.startListening(
        onResult: (text) {
          setState(() {
            _transcribedText = text;
            _statusMessage = 'Recording...';
          });
        },
        onError: (error) {
          debugPrint('Error: $error');
          setState(() {
            _isListening = false;
            _statusMessage = '';
          });
          _showErrorSnackBar(error);
        },
        language: _currentLanguage,
      );
    } catch (e) {
      _showErrorSnackBar('Failed to start listening: $e');
    }
  }

  Future<void> _stopListening() async {
    try {
      await _speechService.stopListening();
      setState(() => _isListening = false);

      if (_transcribedText.isNotEmpty) {
        debugPrint('Transcribed text: $_transcribedText');
        await _processAndShowSigns();
      }
    } catch (e) {
      _showErrorSnackBar('Error while stopping: $e');
    }
  }

  Future<void> _processAndShowSigns() async {
    if (_isProcessing) return;

    // Cleanup any existing video and state
    await _cleanupVideo();

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Processing speech...';
      _isShowingSign = false;
      _currentWordIndex = 0;
      _wordsToPlay = [];
    });

    try {
      final words =
          VideoService.processText(_transcribedText, _currentLanguage);

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
      // Set the playback speed when initializing the video
      await _videoController!.setPlaybackSpeed(_playbackSpeed);

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

  Future<void> _onSpeedChanged(double newSpeed) async {
    setState(() => _playbackSpeed = newSpeed);
    if (_videoController != null) {
      await _videoController!.setPlaybackSpeed(newSpeed);
    }
  }

  Widget _buildSpeedControl() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.speed, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              'Playback Speed: ${_playbackSpeed.toStringAsFixed(2)}x',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        Slider(
          thumbColor: Colors.blue,
          activeColor: Colors.blue,
          value: _playbackSpeed,
          min: _availableSpeeds.first,
          max: _availableSpeeds.last,
          divisions: _availableSpeeds.length - 1,
          label: '${_playbackSpeed.toStringAsFixed(2)}x',
          onChanged: _isProcessing ? null : _onSpeedChanged,
        ),
      ],
    );
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

  // Resets the screen after all videos have been played.
  void _resetScreen() {
    setState(() {
      _transcribedText = '';
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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cleanupVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Audio to ISL',
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_statusMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    _statusMessage,
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              // Add Frequent Phrases section
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        _currentLanguage == AppLanguage.english
                            ? 'Frequent Phrases'
                            : 'सामान्य वाक्य',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFrequentPhrases(),
                  ],
                ),
              ),

              _buildMicButton(),
              const SizedBox(height: 20),
              if (_transcribedText.isNotEmpty)
                _buildTranscriptContainer(isDarkMode),
              const SizedBox(height: 20),
              if (_isShowingSign) _buildVideoContainer(),
              const SizedBox(height: 20),
              if (_isShowingSign) _buildSpeedControl(),
              const SizedBox(height: 10),
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
        _transcribedText = '';
        _isShowingSign = false;
        _statusMessage = '';
      });
      _cleanupVideo();
    }
  }

  Widget _buildMicButton() {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        transform: Matrix4.identity()..scale(_isListening ? 1.1 : 1.0),
        child: CustomButton(
          onPressed: _isInitialized
              ? (_isListening ? _stopListening : _startListening)
              : null,
          isListening: _isListening,
          isEnabled: _isInitialized && !_isProcessing,
        ),
      ),
    );
  }

  Widget _buildTranscriptContainer(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _transcribedText,
        style: const TextStyle(fontSize: 18),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildVideoContainer() {
    if (_isLoadingVideo) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_videoController == null || !_videoController!.value.isInitialized) {
      return const Expanded(
        child: Center(child: Text('Preparing video...')),
      );
    }

    return Expanded(
      child: Center(
        child: AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        ),
      ),
    );
  }
}
