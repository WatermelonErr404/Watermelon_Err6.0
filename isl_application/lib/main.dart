import 'package:flutter/material.dart';
import 'package:opencv_4/opencv_4.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Verify OpenCV is working
  try {
    String? version = await Cv2.version();
    print("OpenCV Version: $version");
  } catch (e) {
    print("OpenCV Error: $e");
  }
  
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool isCameraInitialized = false;
  bool _isProcessing = false;
  Uint8List? _processedImage;
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0],
          ResolutionPreset.medium,  // Using medium for better performance
          imageFormatGroup: ImageFormatGroup.jpeg,
        );
        await _cameraController!.initialize();
        setState(() {
          isCameraInitialized = true;
        });
      }
    } catch (e) {
      print("Camera initialization error: $e");
    }
  }

  Future<void> _processImage(String imagePath) async {
    try {
      // Read the image first
      Uint8List? imageBytes = await File(imagePath).readAsBytes();
      
      // Convert to grayscale
      Uint8List? grayImage = await Cv2.cvtColor(
        pathString: imagePath,
        outputType: Cv2.COLOR_BGR2GRAY,
      );
      
      if (grayImage == null) {
        print("Failed to convert to grayscale");
        return;
      }

      // Save grayscale image temporarily
      final tempDir = await getTemporaryDirectory();
      final grayImagePath = '${tempDir.path}/gray_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(grayImagePath).writeAsBytes(grayImage);

      // Apply Gaussian blur
      Uint8List? blurredImage = await Cv2.gaussianBlur(
        pathString: grayImagePath,
        kernelSize: [7, 7],
        sigmaX: 2.0,
      );
      
      if (blurredImage == null) {
        print("Failed to apply Gaussian blur");
        return;
      }

      // Save blurred image temporarily
      final blurredImagePath = '${tempDir.path}/blurred_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(blurredImagePath).writeAsBytes(blurredImage);

      // Apply binary threshold
      Uint8List? thresholdImage = await Cv2.threshold(
        pathString: blurredImagePath,
        thresholdValue: 127,
        maxThresholdValue: 255,
        thresholdType: Cv2.THRESH_BINARY,
      );
      
      if (thresholdImage == null) {
        print("Failed to apply threshold");
        return;
      }

      // Update UI with processed image
      setState(() {
        _processedImage = thresholdImage;
      });

      print("Image processing completed successfully");
      
      // Clean up temporary files
      try {
        await File(grayImagePath).delete();
        await File(blurredImagePath).delete();
      } catch (e) {
        print("Error cleaning up temporary files: $e");
      }

    } catch (e) {
      print("Image processing error: $e");
    }
  }

  Future<void> _captureAndProcessFrame() async {
    if (!isCameraInitialized || _isProcessing) return;

    try {
      setState(() => _isProcessing = true);

      // Capture image
      final XFile image = await _cameraController!.takePicture();
      print("Image captured: ${image.path}");

      // Save captured image for display
      setState(() {
        _capturedImage = File(image.path);
      });

      // Process the image
      await _processImage(image.path);

    } catch (e) {
      print("Frame capture error: $e");
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Hand Pattern Detection'),
        ),
        body: Column(
          children: [
            // Camera Preview
            Expanded(
              child: isCameraInitialized
                  ? CameraPreview(_cameraController!)
                  : Center(child: CircularProgressIndicator()),
            ),
            // Processed Image Display
            if (_processedImage != null)
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          // Original Image
                          if (_capturedImage != null)
                            Expanded(
                              child: Image.file(_capturedImage!),
                            ),
                          // Processed Image
                          Expanded(
                            child: Image.memory(_processedImage!),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Original (Left) vs Processed (Right)',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _isProcessing ? null : _captureAndProcessFrame,
          child: _isProcessing 
              ? CircularProgressIndicator(color: Colors.white)
              : Icon(Icons.camera),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }
}