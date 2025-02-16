import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  late YoutubePlayerController _controller;
  bool _isFullScreen = false;
  bool _isPlayerReady = false;

  final List<Map<String, String>> islInfo = [
    {
      'title': 'What is ISL?',
      'content':
          'Indian Sign Language (ISL) is the primary sign language used by deaf communities in India. It is a visual-gestural language with its own grammar and syntax.',
      'image': 'assets/images/isl_intro.jpeg',
    },
    {
      'title': 'History of ISL',
      'content':
          'ISL has evolved over many years and is influenced by the rich cultural diversity of India. The first school for the deaf in India was established in 1884 in Bombay.',
      'image': 'assets/images/isl_history.webp',
    },
    {
      'title': 'Unique Features',
      'content':
          'ISL has its own unique features including hand shapes, movements, facial expressions, and body postures. It varies across different regions of India.',
      'image': 'assets/images/isl_features.avif',
    },
  ];

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId: 'hGOL-7FC6vk',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
        showLiveFullscreenButton: true,
        forceHD: true,
        useHybridComposition: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        setState(() {
          _isFullScreen = false;
        });
      },
      onEnterFullScreen: () {
        setState(() {
          _isFullScreen = true;
        });
      },
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
        ),
        onReady: () {
          setState(() {
            _isPlayerReady = true;
          });
          _controller.play();
        },
      ),
      builder: (context, player) {
        return Scaffold(
          appBar: _isFullScreen
              ? null
              : AppBar(
                  title: const Text('About SIGNIFY'),
                ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Video Player Section
                player,

                // Video Controls Section
                if (!_isFullScreen && _isPlayerReady)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          onPressed: () {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.replay),
                          onPressed: () {
                            _controller.seekTo(const Duration(seconds: 0));
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            _controller.value.volume == 0
                                ? Icons.volume_off
                                : Icons.volume_up,
                          ),
                          onPressed: () {
                            if (_controller.value.volume != 0) {
                              _controller.unMute();
                            } else {
                              _controller.mute();
                            }
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),

                // ISL Information Section
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'About Indian Sign Language',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // ISL Info Cards
                ...islInfo
                    .map((info) => Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 10.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8.0),
                                ),
                                child: Image.asset(
                                  info['image']!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      info['title']!,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      info['content']!,
                                      style: const TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    SizedBox(height: 10)
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),

                // Additional Resources Section
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Additional Resources',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      ListTile(
                        leading: Icon(Icons.school),
                        title: Text('ISL Research and Training Center'),
                        subtitle: Text(
                            'ISLRTC is dedicated to promoting ISL education and research'),
                      ),
                      ListTile(
                        leading: Icon(Icons.book),
                        title: Text('ISL Dictionary'),
                        subtitle: Text(
                            'Access the official ISL dictionary with common signs'),
                      ),
                      ListTile(
                        leading: Icon(Icons.people),
                        title: Text('Deaf Communities in India'),
                        subtitle:
                            Text('Connect with deaf communities across India'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
