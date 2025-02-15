import 'package:flutter/material.dart';
import 'package:isl_application/home/isl_animation_screen.dart';

class SpeechInputScreen extends StatefulWidget {
  @override
  _SpeechInputScreenState createState() => _SpeechInputScreenState();
}

class _SpeechInputScreenState extends State<SpeechInputScreen> {
  // Simulated transcribed text
  String transcribedText = '';

  // Simulate starting to listen and updating transcription
  void _listen() {
    // In a real application, integrate your speech recognition logic here.
    setState(() {
      transcribedText = 'Hello, how are you today?';
    });
  }

  // Navigate to ISL Animation Screen
  void _translateToISL() {
    if (transcribedText.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ISLAnimationScreen(
            transcribedText: transcribedText,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please record some speech first.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Speech Input"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Live text transcription display
            Container(
              padding: EdgeInsets.all(16.0),
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: SingleChildScrollView(
                child: Text(
                  transcribedText.isEmpty
                      ? 'Your transcribed text will appear here.'
                      : transcribedText,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _translateToISL,
              child: Text("Translate to ISL"),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        tooltip: 'Press & Speak',
        child: Icon(Icons.mic),
      ),
    );
  }
}
