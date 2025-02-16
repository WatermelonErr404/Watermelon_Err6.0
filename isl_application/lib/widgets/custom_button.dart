// widgets/custom_button.dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isListening;
  final bool isEnabled;

  const CustomButton({super.key, 
    required this.onPressed,
    required this.isListening,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: !isEnabled 
              ? Colors.grey 
              : (isListening ? Colors.red : Colors.blue),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          isListening ? Icons.mic : Icons.mic_none,
          color: Colors.white,
          size: 40,
        ),
      ),
    );
  }
}