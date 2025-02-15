import 'package:flutter/material.dart';
import 'package:isl_application/home/home_screen.dart';

void main() {
  runApp(ISLBridgeApp());
}

class ISLBridgeApp extends StatelessWidget {
  const ISLBridgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ISL Bridge',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
// // main.dart
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
// import 'package:flutter_tts/flutter_tts.dart';

// late List<CameraDescription> cameras;

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   cameras = await availableCameras();
//   runApp(const ISLRecognitionApp());
// }

// class ISLRecognitionApp extends StatelessWidget {isl
//   const ISLRecognitionApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'ISL Recognition',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const HomeScreen(),
//     );
//   }
// }

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;
//   bool isDetecting = false;
//   FlutterTts flutterTts = FlutterTts();
//   String recognizedText = "";
//   late ImageLabeler _imageLabeler;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _initializeLabeler();
//   }

//   Future<void> _initializeLabeler() async {
//     final options = ImageLabelerOptions(confidenceThreshold: 0.75);
//     _imageLabeler = ImageLabeler(options: options);
//   }

//   Future<void> _initializeCamera() async {
//     _controller = CameraController(
//       cameras[0],
//       ResolutionPreset.medium,
//     );
//     _initializeControllerFuture = _controller.initialize();
//   }

//   Future<void> _detectSigns() async {
//     try {
//       if (!_controller.value.isStreamingImages) {
//         await _controller.startImageStream((CameraImage image) {
//           if (!isDetecting) {
//             isDetecting = true;
//             _processImage(image);
//           }
//         });
//       }
//     } catch (e) {
//       print('Error starting image stream: $e');
//     }
//   }

//   Future<void> _processImage(CameraImage image) async {
//     try {
//       final camera = cameras[0];
//       final inputImage = await _convertCameraImageToInputImage(image, camera);

//       if (inputImage != null) {
//         final List<ImageLabel> labels = await _imageLabeler.processImage(inputImage);

//         if (labels.isNotEmpty) {
//           setState(() {
//             recognizedText = "${labels[0].label} (${(labels[0].confidence * 100).toStringAsFixed(1)}%)";
//           });
//           await _speakRecognizedText();
//         }
//       }
//     } catch (e) {
//       print('Error processing image: $e');
//     } finally {
//       isDetecting = false;
//     }
//   }

//   Future<InputImage?> _convertCameraImageToInputImage(
//       CameraImage image, CameraDescription camera) async {
//     try {
//       // Using first plane for processing
//       final bytes = image.planes[0].bytes;
//       final width = image.width;
//       final height = image.height;

//       // Calculate rotation based on camera orientation
//       final rotation = camera.sensorOrientation;

//       return InputImage.fromBytes(
//         bytes: bytes,
//         metadata: InputImageMetadata(
//           size: Size(width.toDouble(), height.toDouble()),
//           rotation: rotation == 90 ? InputImageRotation.rotation90deg :
//                    rotation == 180 ? InputImageRotation.rotation180deg :
//                    rotation == 270 ? InputImageRotation.rotation270deg :
//                    InputImageRotation.rotation0deg,
//           format: InputImageFormat.bgra8888,
//           bytesPerRow: image.planes[0].bytesPerRow,
//         ),
//       );
//     } catch (e) {
//       print('Error converting image: $e');
//       return null;
//     }
//   }

//   Future<void> _speakRecognizedText() async {
//     await flutterTts.speak(recognizedText);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _imageLabeler.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('ISL Recognition'),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: FutureBuilder<void>(
//               future: _initializeControllerFuture,
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   return CameraPreview(_controller);
//                 } else {
//                   return const Center(child: CircularProgressIndicator());
//                 }
//               },
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Text(
//                   'Recognized Sign: $recognizedText',
//                   style: const TextStyle(fontSize: 20.0),
//                 ),
//                 const SizedBox(height: 8),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _detectSigns,
//         child: const Icon(Icons.camera),
//       ),
//     );
//   }
// }
