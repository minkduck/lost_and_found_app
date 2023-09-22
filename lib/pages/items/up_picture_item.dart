import 'package:flutter/material.dart';

class UpPictureItem extends StatefulWidget {
  const UpPictureItem({super.key});

  @override
  State<UpPictureItem> createState() => _UpPictureItemState();
}

class _UpPictureItemState extends State<UpPictureItem> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // Make the stack's children fill the screen
        children: [
          // Background image
          Image.asset(
            'assets/background.jpg', // Replace with your image path
            fit: BoxFit.cover, // Cover the entire screen
          ),
          // Your screen's content
          Center(
            child: Text(
              'Hello, Flutter!',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
