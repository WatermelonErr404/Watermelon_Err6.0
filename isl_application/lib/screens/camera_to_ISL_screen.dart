// ignore_for_file: file_names

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:isl_application/screens/signLanguage.dart';

class CameraToISLScreen extends StatefulWidget {
  const CameraToISLScreen({super.key});

  @override
  State<CameraToISLScreen> createState() => _CameraToISLScreenState();
}

class _CameraToISLScreenState extends State<CameraToISLScreen> {
  late final List<CameraDescription> cameras;
  @override
  void initState() {
    super.initState();
    camerainiailize();
  }

  void camerainiailize() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  }

  @override
  Widget build(BuildContext context) {
    // Determine if dark mode is active.
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    // Define gradient colors with good contrast.
    final List<Color> gradientColors = isDarkMode
        ? [Colors.black87, Colors.black]
        : [Colors.blue.shade100, Colors.white];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera to ISL'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 1,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                // First grid item: Navigates to the Single Capture Model screen.
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SingleCaptureScreen(),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    color: isDarkMode ? Colors.grey[800] : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      // side: BorderSide(
                      //   color:
                      //       isDarkMode ? Colors.white70 : Colors.blue.shade300,
                      //   width: 1.5,
                      // ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 60,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Single Capture Model',
                            style: theme.textTheme.displaySmall?.copyWith(
                              // color: isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Second grid item: Opens the real-time camera detection screen.
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ContinuousCaptureScreen(cameras: cameras),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    color: isDarkMode ? Colors.grey[800] : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      // side: BorderSide(
                      //   color:
                      //       isDarkMode ? Colors.white70 : Colors.blue.shade300,
                      //   width: 1.5,
                      // ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera,
                            size: 60,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Real-Time Sign Detection',
                            style: theme.textTheme.displaySmall?.copyWith(
                              // color: isDarkMode ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
