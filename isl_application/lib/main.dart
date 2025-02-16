import 'dart:async';
import 'dart:io';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:isl_application/screens/signLanguage.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(SignLanguageApp(cameras: cameras));
}
