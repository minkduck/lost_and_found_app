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

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
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
    final XFile? picture = await imagePicker.pickImage(source: ImageSource.camera);
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
      body: SingleChildScrollView(
        child: Padding(
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
                    text: "Post",
                    size: 20,
                    color: AppColors.secondPrimaryColor,
                    fontW: FontWeight.w500,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: AppLayout.getWidth(30), top: AppLayout.getHeight(10)),
                child: Text('Create Post', style: Theme.of(context).textTheme.displayMedium,),
              ),
              Gap(AppLayout.getHeight(20)),
              LayoutBuilder(builder: (context, contraints) {
                return SizedBox(
                  height: AppLayout.getHeight(40),
                  child: TextField(
                    expands: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Title', // Add your hint text here
                    ),
                  ),

                );
              }),

              LayoutBuilder(builder: (context, contraints) {
                return SizedBox(
                  height: AppLayout.getScreenHeight() / 4,
                  child: TextField(
                    expands: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Description', // Add your hint text here
                    ),
                  ),
                );
              }),
              Gap(AppLayout.getHeight(20)),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min, // Make the content size fit its children
                          children: [
                            AppButtonUpLoadImage(
                              boxColor: AppColors.primaryColor,
                              textButton: "Take a photo",
                              onTap: () {
                                takePicture();
                                Navigator.pop(context); // Close the dialog after taking a photo
                              },
                            ),
                            Gap(AppLayout.getHeight(20)), // Add a gap between the buttons
                            AppButtonUpLoadImage(
                              boxColor: AppColors.secondPrimaryColor,
                              textButton: "Upload photo",
                              onTap: () {
                                selectImagesFromGallery();
                                Navigator.pop(context); // Close the dialog after selecting an image
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Text('Select'
                    ),
              ),
              SizedBox(
                height: AppLayout.getHeight(250), // Set a fixed height or any desired value
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
                              icon: Icon(FontAwesomeIcons.xmark, color: AppColors.primaryColor),
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
                  child: AppButton(boxColor: AppColors.primaryColor, textButton: "Create", onTap: (){

                  }),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
