import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:lost_and_find_app/widgets/app_button.dart';

import '../../widgets/app_button_upload_image.dart';

class TakePictureScreen extends StatefulWidget {
  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        // Set the background color to transparent
        elevation: 0, // Remove the shadow
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppAssets.upPictureScreen),
                // Replace with your image path
                fit:
                    BoxFit.cover, // You can change the BoxFit to fit your needs
              ),
            ),
          ),
          // Your Content on Top of the Background
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const FractionallySizedBox(
                  widthFactor: 0.8, // Adjust this value to control text width
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Select a picture by taking a photo or uploading an image",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                Gap(AppLayout.getHeight(300)),
                AppButtonUpLoadImage(
                    boxColor: AppColors.primaryColor,
                    textButton: "Take a photo",
                    onTap: () {}),
                Gap(AppLayout.getHeight(40)),
                AppButtonUpLoadImage(
                    boxColor: AppColors.secondPrimaryColor,
                    textButton: "Upload a photo",
                    onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
