import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_button_upload_image.dart';
import '../../widgets/big_text.dart';
import 'get_accpect_claim_details.dart';

class TakePictureClaim extends StatefulWidget {
  final String resultScanQrCode;
  final String userId;
  final String itemUserId;
  final int itemId;

  const TakePictureClaim({Key? key, required this.resultScanQrCode, required this.userId, required this.itemUserId, required this.itemId}) : super(key: key);

  @override
  State<TakePictureClaim> createState() => _TakePictureClaimState();
}

class _TakePictureClaimState extends State<TakePictureClaim> {
  final ImagePicker imagePicker = ImagePicker();

  XFile? imageFile;

  Future<void> takePicture() async {
    final XFile? picture = await imagePicker.pickImage(source: ImageSource.camera);
    if (picture != null) {
      imageFile = picture; // Assign the new picture directly
      setState(() {});
    }
  }

  void removeImage() {
    setState(() {
      imageFile = null; // Clear the imageFile
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Gap(AppLayout.getHeight(20)),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
              ],
            ),
            Gap(AppLayout.getHeight(20)),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AppButtonUpLoadImage(
                    boxColor: AppColors.primaryColor,
                    textButton: "Take photo",
                    onTap: () {
                      takePicture();
                    }),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (imageFile != null)
                      Positioned.fill(
                        child: Image.file(
                          File(imageFile!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    if (imageFile != null)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: Icon(
                            FontAwesomeIcons.xmark,
                            color: AppColors.primaryColor,
                          ),
                          onPressed: () {
                            removeImage();
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Center(
                child: AppButton(
                  boxColor: AppColors.primaryColor,
                  textButton: "Continue",
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GetAccepctClaimDetail(
                          imageFile: imageFile,
                          userId: widget.userId,
                          resultScanQrCode: widget.resultScanQrCode,
                          itemId: widget.itemId,
                          itemUserId: widget.itemUserId,
                        ),
                      ),
                    );

                  }
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
