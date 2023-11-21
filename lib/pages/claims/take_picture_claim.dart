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
  const TakePictureClaim({Key? key, required this.resultScanQrCode, required this.userId}) : super(key: key);

  @override
  State<TakePictureClaim> createState() => _TakePictureClaimState();
}

class _TakePictureClaimState extends State<TakePictureClaim> {
  final ImagePicker imagePicker = ImagePicker();

  List<XFile>? imageFileList = [];

  Future<void> selectImagesFromGallery() async {
    final List<XFile> selectedImages = await imagePicker.pickMultiImage();
    if (selectedImages.isNotEmpty) {
      imageFileList!.addAll(selectedImages);
      setState(() {});
    }
  }

  Future<void> takePicture() async {
    final XFile? picture = await imagePicker.pickImage(
        source: ImageSource.camera);
    if (picture != null) {
      imageFileList!.add(picture);
      setState(() {});
    }
  }

  void removeImage(int index) {
    setState(() {
      imageFileList!.removeAt(index);
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
                child: GridView.builder(
                  itemCount: imageFileList!.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: AppLayout.getWidth(10),
                      mainAxisSpacing: AppLayout.getHeight(10)
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: Image.file(
                            File(imageFileList![index].path),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(FontAwesomeIcons.xmark,
                                color: AppColors.primaryColor),
                            onPressed: () {
                              removeImage(index);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),

              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Center(
                child: AppButton(
                  boxColor: AppColors.primaryColor,
                  textButton: "Done",
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GetAccepctClaimDetail(imageFileList: imageFileList, userId: widget.userId, resultScanQrCode: widget.resultScanQrCode,),
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
