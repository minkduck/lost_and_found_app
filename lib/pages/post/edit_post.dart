import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:lost_and_find_app/data/api/post/post_controller.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

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

  List<String> selectedLocations = [];
  String? selectedLocationsString;
  List<String> selectedCategories = [];
  String? selectedCategoriesString;
  DateTime? lostDateFrom;
  DateTime? lostDateTo;

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
    selectedLocations = (widget.postData['postLocationIdList'] as List<dynamic>?)?.map((locationId) => locationId.toString()).toList() ?? [];

// Initialize selectedLocationsString
    selectedLocationsString = '|${selectedLocations.join("|")}|';

    selectedCategories = (widget.postData['postCategoryIdList'] as List<dynamic>?)?.map((categoryId) => categoryId.toString()).toList() ?? [];

// Initialize selectedLocationsString
    selectedCategoriesString = '|${selectedCategories.join("|")}|';

    lostDateFrom = widget.postData['lostDateFrom'] != null
        ? DateTime.parse(widget.postData['lostDateFrom'])
        : null;

    lostDateTo = widget.postData['lostDateTo'] != null
        ? DateTime.parse(widget.postData['lostDateTo'])
        : null;


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

                //categories
                AppDropdownMultiSelectFieldTitle(
                  hintText: "Select categories",
                  validator: "Please choose at least one category",
                  selectedValues: selectedCategories,
                  items: getMultiSelectCategories(),
                  onChanged: (values) {
                    setState(() {
                      selectedCategories = values;
                      // Update selectedCategoriesString with the correct format
                      selectedCategoriesString = '|${values.join("|")}|';
                    });
                  },
                  titleText: "Categories",
                ),
                Gap(AppLayout.getHeight(20)),

                //location
                Gap(AppLayout.getHeight(20)),
                AppDropdownMultiSelectFieldTitle(
                  hintText: "Select locations",
                  validator: "Please choose at least one location",
                  selectedValues: selectedLocations,
                  items: getMultiSelectLocations(),
                  onChanged: (values) {
                    setState(() {
                      selectedLocations = values;
                      // Update selectedLocationsString with the correct format
                      selectedLocationsString = '|${values.join("|")}|';
                    });
                  },
                  titleText: "Locations",
                ),
                Gap(AppLayout.getHeight(20)),

                //lostDateFrom
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
/*                Gap(AppLayout.getHeight(30)),

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
                ),*/
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
                              List<String> imagePaths =
                              imageFileList!.map((image) => image.path).toList();
                              print(selectedCategoriesString! + selectedLocationsString!);
                              await PostController().updatePostById(
                                widget.postData['postId'],
                                titleController.text,
                                postContentController.text,
                                selectedCategoriesString!,
                                selectedLocationsString!,
                                lostDateFrom != null ? lostDateFrom!.toLocal().toString() : null,
                                lostDateTo != null ? lostDateTo!.toLocal().toString() : null,
                              );
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
