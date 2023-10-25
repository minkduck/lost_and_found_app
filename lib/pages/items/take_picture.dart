import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lost_and_find_app/data/api/item/item_controller.dart';
import 'package:lost_and_find_app/test/upload%20file%20and%20picture/upload-file.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:lost_and_find_app/widgets/app_button.dart';

import '../../routes/route_helper.dart';
import '../../utils/snackbar_utils.dart';
import '../../widgets/app_button_upload_image.dart';
import '../../widgets/big_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

class TakePictureScreen extends StatefulWidget {
  final String category;
  final String title;
  final String description;
  final String location;

  const TakePictureScreen({
    Key? key,
    required this.title,
    required this.description,
    required this.category,
    required this.location
  }) : super(key: key);

  @override
  State<TakePictureScreen> createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
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
                BigText(
                  text: "Create Items",
                  size: 20,
                  color: AppColors.secondPrimaryColor,
                  fontW: FontWeight.w500,
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: AppLayout.getWidth(30), top: AppLayout.getHeight(10)),
              child: Text('Create Items', style: Theme
                  .of(context)
                  .textTheme
                  .displayMedium,),
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
                AppButtonUpLoadImage(
                    boxColor: AppColors.secondPrimaryColor,
                    textButton: "Upload a photo",
                    onTap: () {
                      selectImagesFromGallery();
                    }),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: imageFileList!.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
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
                  textButton: "Create",
                  onTap: () async {
                    if (imageFileList!.isNotEmpty) {
                      List<String> imagePaths = imageFileList!.map((image) => image.path).toList();
                      await ItemController().createItem(
                        widget.title,
                        widget.description,
                        widget.category,
                        widget.location,
                        imagePaths,
                      );
                    } else {
                      SnackbarUtils().showError(title: "Image", message: "You must add image");
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
