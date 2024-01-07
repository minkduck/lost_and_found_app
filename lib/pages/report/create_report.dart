import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:lost_and_find_app/data/api/report/report_controller.dart';
import 'package:path_provider/path_provider.dart';

import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../utils/snackbar_utils.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_button_upload_image.dart';
import '../../widgets/big_text.dart';

class CreateReport extends StatefulWidget {
  final int itemId;
  const CreateReport({Key? key, required this.itemId}) : super(key: key);

  @override
  State<CreateReport> createState() => _CreateReportState();
}

class _CreateReportState extends State<CreateReport> {
  bool _isMounted = false;
  final _formKey = GlobalKey<FormState>();
  var titleController =
  TextEditingController();
  var postContentController = TextEditingController();

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
    final XFile? picture =
    await imagePicker.pickImage(source: ImageSource.camera);
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

  Future<List<int>> compressImage(
      String imagePath, int targetWidth, int targetHeight, int quality) async {
    List<int> imageBytes = await File(imagePath).readAsBytes();
    img.Image image = img.decodeImage(Uint8List.fromList(imageBytes))!;
    img.Image resizedImage =
    img.copyResize(image, width: targetWidth, height: targetHeight);
    return img.encodeJpg(resizedImage, quality: quality);
  }

  Future<void> compressAndCreateReport() async {
    try {
      List<List<int>> compressedImages = [];

      for (var imageFile in imageFileList!) {
        List<int> compressedImage = await compressImage(
            imageFile.path, 800, 600, 80); // Adjust parameters as needed
        compressedImages.add(compressedImage);
      }

      List<String> compressedImagePaths = [];
      for (var i = 0; i < compressedImages.length; i++) {
        String compressedImagePath = await saveToDisk(
            compressedImages[i], 'report_image_$i.jpg');
        compressedImagePaths.add(compressedImagePath);
      }

      // Now you can use compressedImagePaths to create the report
      await ReportController().createReport(
        titleController.text,
        postContentController.text,
        widget.itemId.toString(),
        compressedImagePaths,
      );
    } catch (e) {
      // Handle any exceptions
      print("Error compressing and creating report: $e");
      SnackbarUtils().showError(title: "Error", message: e.toString());
    }
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
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Form(
            key: _formKey,
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
                      text: "Item Detail",
                      size: 20,
                      color: AppColors.secondPrimaryColor,
                      fontW: FontWeight.w500,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: AppLayout.getWidth(30), top: AppLayout.getHeight(10)),
                  child: Text(
                    'Create Report',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                Gap(AppLayout.getHeight(20)),

                //title
                LayoutBuilder(builder: (context, constraints) {
                  return SizedBox(
                    height: AppLayout.getHeight(75),
                    child: TextFormField(
                      expands: true,
                      controller: titleController,
                      maxLines: null,
                      maxLength: 50, // Set the maximum length to 50 symbols
                      onSaved: (value) => titleController.text = value!,
                      decoration: InputDecoration(
                        hintText: 'Title',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please input Title";
                        }
                        return null;
                      },
                    ),
                  );
                }),

                //description
                LayoutBuilder(builder: (context, contraints) {
                  return SizedBox(
                    height: AppLayout.getScreenHeight() / 4,
                    child: TextFormField(
                      onSaved: (value) => postContentController.text = value!,
                      expands: true,
                      controller: postContentController,
                      maxLines: null,
                      maxLength: 250,
                      decoration: InputDecoration(
                        hintText: 'Description', // Add your hint text here
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please input description";
                        }
                        return null;
                      },
                    ),
                  );
                }),
                Gap(AppLayout.getHeight(20)),

                //image
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
                                  takePicture();
                                  Navigator.pop(
                                      context); // Close the dialog after taking a photo
                                },
                              ),
                              Gap(AppLayout.getHeight(20)),
                              // Add a gap between the buttons
                              AppButtonUpLoadImage(
                                boxColor: AppColors.secondPrimaryColor,
                                textButton: "Upload photo",
                                onTap: () {
                                  selectImagesFromGallery();
                                  Navigator.pop(
                                      context); // Close the dialog after selecting an image
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
                SizedBox(
                  height: AppLayout.getHeight(250),
                  // Set a fixed height or any desired value
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                      itemCount: imageFileList!.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.9,
                        crossAxisSpacing: AppLayout.getWidth(10),
                        mainAxisSpacing: AppLayout.getHeight(10),
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
                Gap(AppLayout.getHeight(80)),

                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Center(
                    child: AppButton(
                        boxColor: AppColors.primaryColor,
                        textButton: "Create",
                        onTap: () async {
                          try {
                            if (_formKey.currentState!.validate()) {
                              if (imageFileList != null && imageFileList!.isNotEmpty) {
                                // code here
                                List<String> imagePaths = imageFileList!.map((image) => image.path).toList();

                                await compressAndCreateReport();
                              } else {
                                SnackbarUtils().showError(title: "Image", message: "You must add image");
                              }
                            }
                          } catch (e) {
                            SnackbarUtils().showError(title: "Error", message: e.toString());
                            print("Error creating the post: $e");
                            // You can also display an error snackbar here if needed.
                          }
                        }),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
