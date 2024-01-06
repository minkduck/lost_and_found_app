import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/data/api/user/user_controller.dart';

import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../utils/snackbar_utils.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_button_upload_image.dart';
import '../../widgets/app_text_filed_title.dart';
import '../../widgets/big_text.dart';

class VerifyAccount extends StatefulWidget {
  const VerifyAccount({super.key});

  @override
  State<VerifyAccount> createState() => _VerifyAccountState();
}

class _VerifyAccountState extends State<VerifyAccount> {
  var schoolIdController = TextEditingController();
  XFile? imageCCIDFront;
  XFile? imageCCIDBack;
  XFile? imageSchoolCard;
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  Future<void> pickImageCCIDFront() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageCCIDFront = pickedFile;
      });
      String imagePath = pickedFile.path;
      // await _sendImageMessage(imagePath);
    }
  }

  Future<void> takeImageCCIDFront() async {
    final XFile? picture = await _imagePicker.pickImage(source: ImageSource.camera);
    if (picture != null) {
      imageCCIDFront = picture;
      setState(() {});
    }
  }

  void removeImageCCIDFront() {
    setState(() {
      imageCCIDFront = null; // Clear the imageFile
    });
  }

  Future<void> pickImageCCIDBack() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageCCIDBack = pickedFile;
      });
      String imagePath = pickedFile.path;
      // await _sendImageMessage(imagePath);
    }
  }

  Future<void> takeImageCCIDBack() async {
    final XFile? picture = await _imagePicker.pickImage(source: ImageSource.camera);
    if (picture != null) {
      imageCCIDBack = picture;
      setState(() {});
    }
  }

  void removeImageCCIDBack() {
    setState(() {
      imageCCIDBack = null; // Clear the imageFile
    });
  }

  Future<void> pickImageSchoolCard() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imageSchoolCard = pickedFile;
      });
      String imagePath = pickedFile.path;
      // await _sendImageMessage(imagePath);
    }
  }

  Future<void> takeImageSchoolCard() async {
    final XFile? picture = await _imagePicker.pickImage(source: ImageSource.camera);
    if (picture != null) {
      imageSchoolCard = picture;
      setState(() {});
    }
  }

  void removeImageSchoolCard() {
    setState(() {
      imageSchoolCard = null; // Clear the imageFile
    });
  }

  Future<List<int>> compressImage(
      String imagePath, int targetWidth, int targetHeight, int quality) async {
    List<int> imageBytes = await File(imagePath).readAsBytes();
    img.Image image = img.decodeImage(Uint8List.fromList(imageBytes))!;
    img.Image resizedImage =
    img.copyResize(image, width: targetWidth, height: targetHeight);
    return img.encodeJpg(resizedImage, quality: quality);
  }

  Future<void> compressAndCreateVerify(
      XFile? imageCCIDFront, XFile? imageCCIDBack, XFile? imageSchoolCard) async {
    // Handle the case when any of the imageFiles is null (not selected or taken)
    if (imageCCIDFront == null || imageCCIDBack == null || imageSchoolCard == null) {
      return;
    }

    List<String> compressedImagePaths = [];

    // Convert XFile to List<XFile> for iteration
    List<XFile> imageFiles = [imageCCIDFront, imageCCIDBack, imageSchoolCard];

    for (var imageFile in imageFiles) {
      List<int> compressedImage = await compressImage(
          imageFile.path, 800, 600, 80); // Adjust parameters as needed
      String compressedImagePath =
      await saveToDisk(compressedImage, '${imageFile.name}_compressed.jpg');
      compressedImagePaths.add(compressedImagePath);
    }

    await UserController().verifyAccount(
      schoolIdController.text,
      compressedImagePaths[0],
      compressedImagePaths[1],
      compressedImagePaths[2],
    );

    // Use compressedImagePaths as needed
    print(compressedImagePaths);
  }

  Future<String> saveToDisk(List<int> data, String fileName) async {
    final File file = File('${(await getTemporaryDirectory()).path}/$fileName');
    await file.writeAsBytes(data);
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Gap(AppLayout.getHeight(50)),
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
                    text: "Verify Account",
                    size: 20,
                    color: AppColors.secondPrimaryColor,
                    fontW: FontWeight.w500,
                  ),
                ],
              ),
              Gap(AppLayout.getHeight(50)),

              // schoolId
              AppTextFieldTitle(
                textController: schoolIdController,
                hintText: "Input schoolID",
                titleText: "SchoolID",
                validator: 'Please input schoolId',
              ),
              Gap(AppLayout.getHeight(30)),

              // CCID Front Image
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "CCID Front Image",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          // Make the content size fit its children
                          children: [
                            AppButtonUpLoadImage(
                              boxColor: AppColors.primaryColor,
                              textButton: "Take a photo",
                              onTap: () {
                                takeImageCCIDFront();
                                Navigator.pop(
                                  context,
                                ); // Close the dialog after taking a photo
                              },
                            ),
                            Gap(AppLayout.getHeight(20)),
                            // Add a gap between the buttons
                            AppButtonUpLoadImage(
                              boxColor: AppColors.secondPrimaryColor,
                              textButton: "Upload photo",
                              onTap: () {
                                pickImageCCIDFront();
                                Navigator.pop(
                                  context,
                                ); // Close the dialog after selecting an image
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Text('Select'),
              ),
              Gap(AppLayout.getHeight(10)),
              Container(
                height: AppLayout.getScreenHeight() / 3,
                width: AppLayout.getScreenWidth() / 1.5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (imageCCIDFront != null)
                        Positioned.fill(
                          child: Image.file(
                            File(imageCCIDFront!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (imageCCIDFront != null)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.xmark,
                              color: AppColors.primaryColor,
                            ),
                            onPressed: () {
                              removeImageCCIDFront();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // CCID Back Image
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "CCID Back Image",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          // Make the content size fit its children
                          children: [
                            AppButtonUpLoadImage(
                              boxColor: AppColors.primaryColor,
                              textButton: "Take a photo",
                              onTap: () {
                                takeImageCCIDBack();
                                Navigator.pop(
                                  context,
                                ); // Close the dialog after taking a photo
                              },
                            ),
                            Gap(AppLayout.getHeight(20)),
                            // Add a gap between the buttons
                            AppButtonUpLoadImage(
                              boxColor: AppColors.secondPrimaryColor,
                              textButton: "Upload photo",
                              onTap: () {
                                pickImageCCIDBack();
                                Navigator.pop(
                                  context,
                                ); // Close the dialog after selecting an image
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Text('Select'),
              ),
              Gap(AppLayout.getHeight(10)),
              Container(
                height: AppLayout.getScreenHeight() / 3,
                width: AppLayout.getScreenWidth() / 1.5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (imageCCIDBack != null)
                        Positioned.fill(
                          child: Image.file(
                            File(imageCCIDBack!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (imageCCIDBack != null)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.xmark,
                              color: AppColors.primaryColor,
                            ),
                            onPressed: () {
                              removeImageCCIDBack();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // School Card Image
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 20),
                child: Text(
                  "School Card Image",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          // Make the content size fit its children
                          children: [
                            AppButtonUpLoadImage(
                              boxColor: AppColors.primaryColor,
                              textButton: "Take a photo",
                              onTap: () {
                                takeImageSchoolCard();
                                Navigator.pop(
                                  context,
                                ); // Close the dialog after taking a photo
                              },
                            ),
                            Gap(AppLayout.getHeight(20)),
                            // Add a gap between the buttons
                            AppButtonUpLoadImage(
                              boxColor: AppColors.secondPrimaryColor,
                              textButton: "Upload photo",
                              onTap: () {
                                pickImageSchoolCard();
                                Navigator.pop(
                                  context,
                                ); // Close the dialog after selecting an image
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Text('Select'),
              ),
              Gap(AppLayout.getHeight(10)),
              Container(
                height: AppLayout.getScreenHeight() / 3,
                width: AppLayout.getScreenWidth() / 1.5,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (imageSchoolCard != null)
                        Positioned.fill(
                          child: Image.file(
                            File(imageSchoolCard!.path),
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (imageSchoolCard != null)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: Icon(
                              FontAwesomeIcons.xmark,
                              color: AppColors.primaryColor,
                            ),
                            onPressed: () {
                              removeImageSchoolCard();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              Gap(AppLayout.getHeight(80)),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Center(
                  child: AppButton(
                      boxColor: AppColors.primaryColor,
                      textButton: "Verify",
                      onTap: () async {
                        try {
                          if (_formKey.currentState!.validate()) {
                            if (imageCCIDFront != null && imageCCIDBack != null && imageSchoolCard != null) {
                              // code here

                              print(imageCCIDFront!.path + '-' + imageCCIDBack!.path +
                                  '-' + imageSchoolCard!.path);
                              await UserController().verifyAccount(schoolIdController.text, imageCCIDFront!.path, imageCCIDBack!.path, imageSchoolCard!.path);
                            } else {
                              SnackbarUtils().showError(title: "Image", message: "You must add image");
                            }
                          } else {
                            SnackbarUtils().showError(title: "Error", message: "Please input schoolId");
                          }
                        } catch (e) {
                          SnackbarUtils().showError(title: "Error", message: e.toString());
                          print("Error creating the post: $e");
                          // You can also display an error snackbar here if needed.
                        }
                      }
                  ),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
