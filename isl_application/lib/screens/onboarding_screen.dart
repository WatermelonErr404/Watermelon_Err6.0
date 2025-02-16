// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:isl_application/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.toggleTheme,
  });
  final VoidCallback toggleTheme;

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> slides = [
    OnboardingSlide(
      title: 'Audio-to-ISL Conversion',
      description:
          'Convert spoken language into Indian Sign Language in real time.',
      icon: Icons.mic,
    ),
    OnboardingSlide(
      title: 'Text-to-ISL Translation',
      description: 'Type text and see it translated into ISL gestures.',
      icon: Icons.keyboard,
    ),
    OnboardingSlide(
      title: 'Camera-based ISL Recognition',
      description: 'Use your camera to recognize and interpret ISL signs.',
      icon: Icons.camera_alt,
    )
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < slides.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return HomeScreen(
              onThemeToggle: widget.toggleTheme,
            );
          },
        ),
      );
    }
  }

  void _skip() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return HomeScreen(
            onThemeToggle: widget.toggleTheme,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Define a gradient that blends a blue tone with white.
    final List<Color> gradientColors = [
      Colors.blue[200]!,
      Colors.white,
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: slides.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final slide = slides[index];
                    return Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            slide.icon,
                            size: 120,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 40),
                          Text(
                            slide.title,
                            textAlign: TextAlign.center,
                            style: textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            slide.description,
                            textAlign: TextAlign.center,
                            style: textTheme.displayMedium?.copyWith(
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Page indicator dots.
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  slides.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              // Navigation buttons.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Skip button.
                    TextButton(
                      onPressed: _skip,
                      child: Text(
                        'Skip',
                        style: textTheme.displaySmall?.copyWith(color: Colors.blue),
                      ),
                    ),
                    // Next / Get Started button.
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                        shape: MaterialStateProperty.all(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      onPressed: _nextPage,
                      child: Text(
                        _currentPage == slides.length - 1 ? 'Get Started' : 'Next',
                        style: textTheme.displaySmall?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Model for each onboarding slide.
class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
  });
}

