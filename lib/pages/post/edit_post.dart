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

class EditPost extends StatefulWidget {
  final Map<String, dynamic> postData;

  const EditPost({Key? key, required this.postData}) : super(key: key);

  @override
  State<EditPost> createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  bool _isMounted = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController titleController;
  late TextEditingController postContentController;

  String? selectedCategoryValue;
  String? selectedLocationValue;

  List<dynamic> categoryList = [];
  final CategoryController categoryController = Get.put(CategoryController());

  List<dynamic> locationList = [];
  final LocationController locationController = Get.put(LocationController());

  List<XFile>? imageFileList = [];

  String findCategoryIdByName(String categoryName) {
    var category = categoryList.firstWhere(
          (category) => category['name'].toString() == categoryName,
      orElse: () => {'id': 0}, // Assuming 'id' is an int, replace with the appropriate default value
    );
    return (category['id'] ?? 0).toString(); // Assuming 'id' is an int, convert to String
  }

  String findLocationIdByName(String locationName) {
    var location = locationList.firstWhere(
          (location) => location['locationName'].toString() == locationName,
      orElse: () => {'id': 0}, // Assuming 'id' is an int, replace with the appropriate default value
    );
    return (location['id'] ?? 0).toString(); // Assuming 'id' is an int, convert to String
  }

  @override
  void initState() {
    super.initState();
    _isMounted = true;

    titleController = TextEditingController(text: widget.postData['title']);
    postContentController =
        TextEditingController(text: widget.postData['description']);

    categoryController.getCategoryList().then((result) {
      if (_isMounted) {
        setState(() {
          categoryList = result;
          String initialCategoryId = findCategoryIdByName(widget.postData['postCategoryId'].toString());
          // Set the initial value for AppDropdownFieldTitle
          selectedCategoryValue = initialCategoryId.isNotEmpty ? initialCategoryId : null;
        });
      }
    });

    locationController.getAllLocationPages().then((result) {
      if (_isMounted) {
        setState(() {
          locationList = result;
          String initialLocationId = findLocationIdByName(widget.postData['postLocationId'].toString());
          // Set the initial value for AppDropdownFieldTitle
          selectedLocationValue = initialLocationId.isNotEmpty ? initialLocationId : null;
        });
      }
    });
  }

  final ImagePicker imagePicker = ImagePicker();

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
                      text: "Edit Post",
                      size: 20,
                      color: AppColors.secondPrimaryColor,
                      fontW: FontWeight.w500,
                    ),
                  ],
                ),
                Gap(AppLayout.getHeight(20)),

                //title
                LayoutBuilder(builder: (context, contraints) {
                  return SizedBox(
                    height: AppLayout.getHeight(50),
                    child: TextFormField(
                      expands: true,
                      controller: titleController,
                      maxLines: null,
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
                      decoration: InputDecoration(
                        hintText: 'Description',
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
                  items: categoryList.map((category) {
                    return DropdownMenuItem<String>(
                      value: category['id']?.toString() ?? '',
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
                            children: [
                              AppButtonUpLoadImage(
                                boxColor: AppColors.primaryColor,
                                textButton: "Take a photo",
                                onTap: () {
                                  takePicture();
                                  Navigator.pop(context);
                                },
                              ),
                              Gap(AppLayout.getHeight(20)),
                              AppButtonUpLoadImage(
                                boxColor: AppColors.secondPrimaryColor,
                                textButton: "Upload photo",
                                onTap: () {
                                  selectImagesFromGallery();
                                  Navigator.pop(context);
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
                      textButton: "Save Changes",
                      onTap: () async {
                        try {
                          if (_formKey.currentState!.validate()) {
                            if (imageFileList != null &&
                                imageFileList!.isNotEmpty) {
                              List<String> imagePaths =
                              imageFileList!.map((image) => image.path).toList();
                              await PostController().updatePostById(
                                widget.postData['postId'],
                                titleController.text,
                                postContentController.text,
                                selectedLocationValue!,
                                selectedCategoryValue!,
                              );
                            } else {
                              SnackbarUtils().showError(
                                  title: "Image", message: "You must add image");
                            }
                          }
                        } catch (e) {
                          SnackbarUtils().showError(
                              title: "Error", message: e.toString());
                          print("Error updating the post: $e");
                        }
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _isMounted = false;
    titleController.dispose();
    postContentController.dispose();
    super.dispose();
  }
}
