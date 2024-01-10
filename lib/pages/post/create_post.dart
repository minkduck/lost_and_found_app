import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:lost_and_find_app/data/api/post/post_controller.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../../data/api/category/category_controller.dart';
import '../../data/api/location/location_controller.dart';
import '../../routes/route_helper.dart';
import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../utils/snackbar_utils.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_button_upload_image.dart';
import '../../widgets/app_drop_menu_filed_title.dart';
import '../../widgets/app_drop_multi_select_filed_title.dart';
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
  List<String> selectedCategories = [];
  String? selectedCategoriesString;
  bool isCreatingPost = false;

  List<dynamic> locationList = [];
  final LocationController locationController = Get.put(LocationController());
  List<String> selectedLocations = [];
  String? selectedLocationsString;
  DateTime? lostDateFrom;
  DateTime? lostDateTo;

  List<MultiSelectItem<String>> getMultiSelectLocations() {
    return locationList
        .map((location) => MultiSelectItem<String>(
      location['id']?.toString() ?? '',
      location['locationName']?.toString() ?? '',
    ))
        .toList();
  }

  List<MultiSelectItem<String>> getMultiSelectCategories() {
    return categoryList
        .map((location) => MultiSelectItem<String>(
      location['id']?.toString() ?? '',
      location['name']?.toString() ?? '',
    ))
        .toList();
  }

  Future<void> _selectLostDateFrom(BuildContext context) async {
    DateTime currentDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: lostDateFrom ?? currentDate,
      firstDate: DateTime(2022),
      lastDate: currentDate,
    );

    if (picked != null && picked != lostDateFrom) {
      setState(() {
        lostDateFrom = picked;
      });
    }
  }

// Add a new method for selecting LostDateTo
  Future<void> _selectLostDateTo(BuildContext context) async {
    DateTime currentDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: lostDateTo ?? currentDate,
      firstDate: lostDateFrom!,
      lastDate: currentDate,
    );

    if (picked != null && picked != lostDateTo) {
      setState(() {
        lostDateTo = picked;
      });
    }
  }

  Future<List<int>> compressImage(
      String imagePath, int targetWidth, int targetHeight, int quality) async {
    List<int> imageBytes = await File(imagePath).readAsBytes();
    img.Image image = img.decodeImage(Uint8List.fromList(imageBytes))!;
    img.Image resizedImage =
    img.copyResize(image, width: targetWidth, height: targetHeight);
    return img.encodeJpg(resizedImage, quality: quality);
  }

  Future<void> compressAndCreatePost() async {
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
            compressedImages[i], 'post_image_$i.jpg');
        compressedImagePaths.add(compressedImagePath);
      }

      // Now you can use compressedImagePaths to create the post
      await PostController().createPost(
        titleController.text,
        postContentController.text,
        selectedCategoriesString!,
        selectedLocationsString!,
        lostDateFrom != null ? lostDateFrom!.toLocal().toString() : null,
        lostDateTo != null ? lostDateTo!.toLocal().toString() : null,
        compressedImagePaths,
      );
    } catch (e) {
      // Handle any exceptions
      print("Error compressing and creating post: $e");
      SnackbarUtils().showError(title: "Error", message: e.toString());
    }
  }

  Future<String> saveToDisk(List<int> data, String fileName) async {
    final File file = File('${(await getTemporaryDirectory()).path}/$fileName');
    await file.writeAsBytes(data);
    return file.path;
  }

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
    locationController.getAllLocationPages().then((result) {
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

                //category
                AppDropdownMultiSelectFieldTitle(
                  hintText: "Select categories",
                  validator: "Please choose at least one category",
                  selectedValues: selectedCategories,
                  items: getMultiSelectCategories(),
                  onChanged: (values) {
                    if (values.length <= 10) {
                      setState(() {
                        selectedCategories = values;
                        // Update selectedCategoriesString with the correct format
                        selectedCategoriesString = '|${values.join("|")}|';
                      });
                    } else {
                      // Automatically remove excess categories
                      setState(() {
                        selectedCategories = values.take(10).toList();
                        // Update selectedCategoriesString with the correct format
                        selectedCategoriesString = '|${selectedCategories.join("|")}|';
                      });

                      // Show a dialog or a snackbar to inform the user about the limit.
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Limit Exceeded'),
                            content: Text('You can only choose up to 10 categories.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },


                  titleText: "Categories",
                ),
                Gap(AppLayout.getHeight(20)),
                AppDropdownMultiSelectFieldTitle(
                  hintText: "Select locations",
                  validator: "Please choose at least one location",
                  selectedValues: selectedLocations,
                  items: getMultiSelectLocations(),
                  onChanged: (values) {
                    if (values.length <= 10) {
                      setState(() {
                        selectedLocations = values;
                        // Update selectedLocationsString with the correct format
                        selectedLocationsString = '|${values.join("|")}|';
                      });
                    } else {
                      // Automatically remove excess locations
                      setState(() {
                        selectedLocations = values.take(10).toList();
                        // Update selectedLocationsString with the correct format
                        selectedLocationsString = '|${selectedLocations.join("|")}|';
                      });

                      // Show a dialog or a snackbar to inform the user about the limit.
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Limit Exceeded'),
                            content: Text('You can only choose up to 10 locations.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  titleText: "Locations",
                ),


                //location
/*                AppDropdownFieldTitle(
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
                ),*/
                Gap(AppLayout.getHeight(20)),

                //lostDatefrom
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "Lost Date From",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Gap(AppLayout.getHeight(15)),
                GestureDetector(
                  onTap: () => _selectLostDateFrom(context),
                  child: Container(
                    height: AppLayout.getHeight(55),
                    margin: EdgeInsets.only(
                      left: AppLayout.getHeight(20),
                      right: AppLayout.getHeight(20),
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppLayout.getHeight(20)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          spreadRadius: 4,
                          offset: Offset(0, 4),
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        lostDateFrom != null
                            ? "${lostDateFrom!.toLocal()}".split(' ')[0]
                            : "Tap to select date",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                Gap(AppLayout.getHeight(20)),

                //lostDateTo
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "Lost Date To",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Gap(AppLayout.getHeight(15)),
                GestureDetector(
                  onTap: () => _selectLostDateTo(context),
                  child: Container(
                    height: AppLayout.getHeight(55),
                    margin: EdgeInsets.only(
                      left: AppLayout.getHeight(20),
                      right: AppLayout.getHeight(20),
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(AppLayout.getHeight(20)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 4,
                          spreadRadius: 4,
                          offset: Offset(0, 4),
                          color: Colors.grey.withOpacity(0.2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        lostDateTo != null
                            ? "${lostDateTo!.toLocal()}".split(' ')[0]
                            : "Tap to select date",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
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

                            if (isCreatingPost) {
                              // If creation is already in progress, do nothing or show a message.
                              return;
                            }

                            isCreatingPost = true;

                            if (_formKey.currentState!.validate()) {
                              if (imageFileList != null && imageFileList!.isNotEmpty) {
                                // code here
                                List<String> imagePaths = imageFileList!.map((image) => image.path).toList();
                                print(titleController.text + '-' + postContentController.text + lostDateFrom.toString() + lostDateTo.toString() +
                                    '-' + selectedCategoriesString! + '-' + selectedLocationsString! + '-' + imagePaths.toString());
                                // await PostController().createPost(
                                //   titleController.text,
                                //   postContentController.text,
                                //   selectedCategoriesString!,
                                //   selectedLocationsString!,
                                //   lostDateFrom != null ? lostDateFrom!.toLocal().toString() : null,
                                //   lostDateTo != null ? lostDateTo!.toLocal().toString() : null,
                                //   imagePaths,
                                // );
                                await compressAndCreatePost();
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
