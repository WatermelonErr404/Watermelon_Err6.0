import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class SignLanguageApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const SignLanguageApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign Language Detector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomeScreen(cameras: cameras),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const HomeScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Language Detector'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SingleCaptureScreen(),
                  ),
                );
              },
              child: const Text('Single Capture Mode'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {},
              child: const Text('Continuous Detection Mode'),
            ),
          ],
        ),
      ),
    );
  }
}

// // Screen for single capture/upload functionality
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'dart:io';
// import 'package:flutter/services.dart';
// import 'package:image/image.dart' as img;

class SingleCaptureScreen extends StatefulWidget {
  @override
  _SingleCaptureScreenState createState() => _SingleCaptureScreenState();
}

class _SingleCaptureScreenState extends State<SingleCaptureScreen> {
  late Interpreter _interpreter;
  late List<String> _labels;
  File? _image;
  String _result = 'No sign detected yet.';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadModelAndLabels();
  }

  Future<void> _loadModelAndLabels() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/sign.tflite');
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData.split('\n');
    } catch (e) {
      print('Error loading model or labels: $e');
    }
  }

  Future<void> _getImage(ImageSource source) async {
    try {
      setState(() => _isLoading = true);
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        await _classifyImage(_image!);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _classifyImage(File image) async {
    try {
      final imageBytes = await image.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes)!;
      final resizedImage =
          img.copyResize(decodedImage, width: 400, height: 400);

      final input = List.generate(
        224,
        (i) => List.generate(
          224,
          (j) => List.generate(
            3,
            (k) => resizedImage.getPixel(j, i)[k] / 127.5 - 1.0,
          ),
        ),
      );

      final outputShape = _interpreter.getOutputTensor(0).shape;
      final output =
          List.filled(outputShape[0], List.filled(outputShape[1], 0.0));

      _interpreter.run([input], output);

      final results = output[0];
      double maxScore = results.reduce((a, b) => a > b ? a : b);
      int maxIndex = results.indexOf(maxScore);

      setState(() {
        _result = _labels.isNotEmpty && maxIndex != -1
            ? '${_labels[maxIndex]} (${(maxScore * 100).toStringAsFixed(1)}%)'
            : 'Unknown';
      });
    } catch (e) {
      setState(() {
        _result = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Single Capture Mode'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.black87, Colors.black]
                    : [Colors.blue.shade50, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 5,
                      color: isDarkMode ? Colors.grey[900] : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        height: 300,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _image != null
                              ? Image.file(_image!, fit: BoxFit.contain)
                              : const Center(
                                  child: Text('No image selected'),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 4,
                      color: isDarkMode ? Colors.grey[850] : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Text(
                              'Detected Sign:',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _result,
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.camera_alt),
                          label: Text(
                            'Capture',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          onPressed: () => _getImage(ImageSource.camera),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                theme.brightness == Brightness.light
                                    ? Colors.white
                                    : theme.secondaryHeaderColor,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 25,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.photo_library),
                          label: Text(
                            'Upload',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          onPressed: () => _getImage(ImageSource.gallery),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                theme.brightness == Brightness.light
                                    ? Colors.white
                                    : theme.secondaryHeaderColor,
                            // foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                              horizontal: 25,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ContinuousCaptureScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const ContinuousCaptureScreen({Key? key, required this.cameras})
      : super(key: key);

  @override
  _ContinuousCaptureScreenState createState() =>
      _ContinuousCaptureScreenState();
}

class _ContinuousCaptureScreenState extends State<ContinuousCaptureScreen>
    with WidgetsBindingObserver {
  late CameraController _cameraController;
  late Interpreter _interpreter;
  late List<String> _labels;
  String _result = '';
  bool _isProcessing = false;
  Timer? _captureTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Force portrait mode immediately
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _initializeCamera();
    _loadModelAndLabels();
  }

  Future<void> _initializeCamera() async {
    // Select back camera
    final backCamera = widget.cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => widget.cameras[0],
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _cameraController.initialize();

      // Force portrait orientation for camera
      await _cameraController
          .lockCaptureOrientation(DeviceOrientation.portraitUp);

      if (mounted) {
        setState(() {});
        _startContinuousCapture();
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Ensure portrait orientation when app resumes
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      if (_cameraController.value.isInitialized) {
        _cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp);
      }
    }
  }

  Future<void> _loadModelAndLabels() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/sign.tflite');
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData.split('\n');
    } catch (e) {
      print('Error loading model or labels: $e');
    }
  }

  void _startContinuousCapture() {
    _captureTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!_isProcessing) {
        _captureAndClassify();
      }
    });
  }

  Future<void> _captureAndClassify() async {
    if (!_cameraController.value.isInitialized || _isProcessing) return;

    try {
      _isProcessing = true;
      final image = await _cameraController.takePicture();

      // Process the image
      final imageFile = File(image.path);
      final imageBytes = await imageFile.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes)!;

      // Always rotate 90 degrees for portrait orientation
      var processedImage = img.copyRotate(decodedImage, angle: 90);
      final resizedImage =
          img.copyResize(processedImage, width: 224, height: 224);

      final input = List.generate(
        224,
        (i) => List.generate(
          224,
          (j) => List.generate(
            3,
            (k) => resizedImage.getPixel(j, i)[k] / 127.5 - 1.0,
          ),
        ),
      );

      final outputShape = _interpreter.getOutputTensor(0).shape;
      final output =
          List.filled(outputShape[0], List.filled(outputShape[1], 0.0));

      _interpreter.run([input], output);

      final results = output[0];
      double maxScore = results.reduce((a, b) => a > b ? a : b);
      int maxIndex = results.indexOf(maxScore);

      if (mounted) {
        setState(() {
          _result = _labels.isNotEmpty && maxIndex != -1
              ? '${_labels[maxIndex]} (${(maxScore * 100).toStringAsFixed(1)}%)'
              : 'Unknown';
        });
      }

      // Clean up the temporary image file
      await imageFile.delete();
    } catch (e) {
      print('Error during continuous capture: $e');
    } finally {
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Calculate the correct size for portrait mode
    final screenSize = MediaQuery.of(context).size;
    final scale =
        1 / (_cameraController.value.aspectRatio * screenSize.aspectRatio);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Continuous Detection Mode'),
      ),
      body: Column(
        children: [
          ClipRect(
            child: Container(
              width: screenSize.width,
              height: screenSize.height * 0.75,
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: screenSize.width,
                  height:
                      screenSize.width * _cameraController.value.aspectRatio,
                  child: Transform.rotate(
                    angle: 90 * 3.14159 / 180,
                    child: CameraPreview(_cameraController),
                  ),
                ),
              ),
            ),
          ),
          // Expanded(
          //   flex: 3,
          //   child: Container(
          //     width: double.infinity,
          //     decoration: BoxDecoration(
          //       border: Border.all(color: Colors.grey),
          //     ),
          //     child: Transform.scale(
          //       scale: scale,
          //       child: Center(
          //         child: CameraPreview(_cameraController),
          //       ),
          //     ),
          //   ),
          // ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Detected Sign:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _result,
                    style: const TextStyle(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _captureTimer?.cancel();
    _cameraController.dispose();
    _interpreter.close();
    // Keep portrait lock even when disposing
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }
}
