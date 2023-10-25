import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:lost_and_find_app/data/api/post/post_controller.dart';

import '../../data/api/category/category_controller.dart';
import '../../data/api/location/location_controller.dart';
import '../../routes/route_helper.dart';
import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../utils/snackbar_utils.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_button_upload_image.dart';
import '../../widgets/app_drop_menu_filed_title.dart';
import '../../widgets/big_text.dart';

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  bool _isMounted = false;
  final _formKey = GlobalKey<FormState>();
  var titleController =
      TextEditingController();
  var postContentController = TextEditingController();

  String? selectedCategoryValue;
  String? selectedLocationValue;

  List<dynamic> categoryList = [];
  final CategoryController categoryController = Get.put(CategoryController());

  List<dynamic> locationList = [];
  final LocationController locationController = Get.put(LocationController());

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    categoryController.getCategoryList().then((result) {
      if (_isMounted) {
        setState(() {
          categoryList = result;
        });
      }
    });
    locationController.getLocationList().then((result) {
      if (_isMounted) {
        setState(() {
          locationList = result;
        });
      }
    });
  }

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
                  child: Text(
                    'Create Post',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                Gap(AppLayout.getHeight(20)),

                //title
                LayoutBuilder(builder: (context, contraints) {
                  return SizedBox(
                    height: AppLayout.getHeight(40),
                    child: TextFormField(
                      expands: true,
                      controller: titleController,
                      maxLines: null,
                      onSaved: (value) => titleController.text = value!,
                      decoration: InputDecoration(
                        hintText: 'Title', // Add your hint text here
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

                //category
                AppDropdownFieldTitle(
                  hintText: "Select a category",
                  validator: "Please choose category",
                  selectedValue: selectedCategoryValue,
                  // selectedValue: categoryList.isNotEmpty ? selectedCategoryValue ?? categoryList.first['id']?.toString() ?? '': '',
                  items: categoryList.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['id']?.toString() ?? '',
                      // Ensure a valid value
                      child: Text(category['name']?.toString() ?? ''),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedCategoryValue = val;
                    });
                  },
                  titleText: "Category",
                ),
                Gap(AppLayout.getHeight(20)),

                //location
                AppDropdownFieldTitle(
                  hintText: "Select a location",
                  validator: "Please choose location",
                  selectedValue: selectedLocationValue,
                  // selectedValue: locationList.isNotEmpty ? selectedLocationValue ?? locationList.first['id']?.toString() ?? '' : '',
                  items: locationList.map((location) {
                    return DropdownMenuItem<String>(
                      value: location['id']?.toString() ?? '',
                      child: Text(location['locationName']?.toString() ?? ''),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedLocationValue = val?.toString();
                    });
                  },
                  titleText: "Location",
                ),
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
                                List<String> imagePaths = imageFileList!.map((image) => image.path).toList();
                                print(titleController.text + '-' + postContentController.text +
                                    '-' + selectedLocationValue! + '-' + selectedCategoryValue! + '-' + imagePaths.toString());
                                await PostController().createPost(
                                  titleController.text,
                                  postContentController.text,
                                  selectedLocationValue!,
                                  selectedCategoryValue!,
                                  imagePaths,
                                );
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
