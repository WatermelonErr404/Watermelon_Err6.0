import 'package:flutter/material.dart';

class ISLAnimationScreen extends StatefulWidget {
  final String transcribedText;

  const ISLAnimationScreen({super.key, required this.transcribedText});

  @override
  _ISLAnimationScreenState createState() => _ISLAnimationScreenState();
}

class _ISLAnimationScreenState extends State<ISLAnimationScreen>
    with SingleTickerProviderStateMixin {
  double gestureSpeed = 1.0;
  late AnimationController _controller;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    // Initial duration is 2 seconds (adjustable by gestureSpeed)
    _controller = AnimationController(
      duration: Duration(milliseconds: (2000 / gestureSpeed).round()),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Control functions for the animation (these are simulated)
  void _playAnimation() {
    setState(() {
      isPlaying = true;
      _controller.forward();
    });
  }

  void _pauseAnimation() {
    setState(() {
      isPlaying = false;
      _controller.stop();
    });
  }

  void _repeatAnimation() {
    setState(() {
      isPlaying = true;
      _controller.repeat();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ISL Animation Display"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Display the transcribed text for reference
            Text(
              "Transcribed: ${widget.transcribedText}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            // Placeholder for ISL animation display
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: Center(
                child: Text(
                  "ISL Animation Placeholder",
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Gesture speed control slider
            Text("Gesture Speed: ${gestureSpeed.toStringAsFixed(1)}x"),
            Slider(
              value: gestureSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 15,
              label: gestureSpeed.toStringAsFixed(1),
              onChanged: (value) {
                setState(() {
                  gestureSpeed = value;
                  // Update animation speed based on the slider value
                  _controller.duration = Duration(
                      milliseconds: (2000 / gestureSpeed).round());
                  if (isPlaying) {
                    // Restart the animation with the new speed if already playing
                    _controller.repeat();
                  }
                });
              },
            ),
            SizedBox(height: 20),
            // Animation control buttons: Repeat, Pause, Play
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _repeatAnimation,
                  icon: Icon(Icons.repeat),
                  label: Text("Repeat"),
                ),
                ElevatedButton.icon(
                  onPressed: _pauseAnimation,
                  icon: Icon(Icons.pause),
                  label: Text("Pause"),
                ),
                ElevatedButton.icon(
                  onPressed: _playAnimation,
                  icon: Icon(Icons.play_arrow),
                  label: Text("Play"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}