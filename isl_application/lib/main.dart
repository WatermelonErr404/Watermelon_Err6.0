import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

void main() {
  runApp(SignLanguageDetectorApp());
}

class SignLanguageDetectorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sign Language Detector',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SignLanguageHomePage(),
    );
  }
}

class SignLanguageHomePage extends StatefulWidget {
  @override
  _SignLanguageHomePageState createState() => _SignLanguageHomePageState();
}

class _SignLanguageHomePageState extends State<SignLanguageHomePage> {
  late Interpreter _interpreter;
  late List<String> _labels;
  File? _image;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _loadModelAndLabels();
  }

  Future<void> _loadModelAndLabels() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/sign.tflite');
       _printModelDetails();
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData.split('\n');
    } catch (e) {
      print('Error loading model or labels: $e');
    }
  }

  Future<void> _getImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _classifyImage(_image!);
    }
  }
void _printModelDetails() {
  final inputTensor = _interpreter.getInputTensor(0);
  final outputTensor = _interpreter.getOutputTensor(0);
  
  print('''
  Model Details:
  Input Shape: ${inputTensor.shape}
  Input Type: ${inputTensor.type}
  Output Shape: ${outputTensor.shape}
  Output Type: ${outputTensor.type}
  ''');
}
Future<void> _classifyImage(File image) async {
  try {
    final outputTensor = _interpreter.getOutputTensor(0);
    final outputShape = outputTensor.shape;
    final outputType = outputTensor.type;

    // Load and preprocess image
    final imageBytes = await image.readAsBytes();
    final decodedImage = img.decodeImage(imageBytes)!;
    final resizedImage = img.copyResize(decodedImage, width: 224, height: 224);

    // Create properly sized input array
    final input = List.generate(
      224,
      (i) => List.generate(
        224,
        (j) => List.generate(
          3, 
          (k) => resizedImage.getPixel(j, i)[k] / 127.5 - 1.0
        )
      )
    );

    // Create output buffer based on ACTUAL model output shape
    final output = List.filled(outputShape[0], List.filled(outputShape[1], 0.0));

    // Run inference
    _interpreter.run([input], output);

    // Process results
    final results = output[0];
    double maxScore = results.reduce((a, b) => a > b ? a : b);
    int maxIndex = results.indexOf(maxScore);

    setState(() {
      _result = _labels.isNotEmpty && maxIndex != -1
          ? '${_labels[maxIndex]} (${(maxScore * 100).toStringAsFixed(1)}%)'
          : 'Unknown';
    });
  } catch (e) {
    print('Error during classification: $e');
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Language Detector'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _image == null
                  ? Text('No image selected.')
                  : Image.file(_image!, height: 200),
              SizedBox(height: 20),
              Text(
                'Detected Sign: $_result',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.camera_alt),
                    label: Text('Capture'),
                    onPressed: () => _getImage(ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                    ),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.photo_library),
                    label: Text('Upload'),
                    onPressed: () => _getImage(ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      padding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
