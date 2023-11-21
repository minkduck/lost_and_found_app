import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/data/api/category/category_controller.dart';
import 'package:lost_and_find_app/data/api/item/item_controller.dart';
import 'package:lost_and_find_app/data/api/location/location_controller.dart';
import 'package:lost_and_find_app/widgets/app_button.dart';
import 'package:get/get.dart';

import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/app_drop_menu_filed_title.dart';
import '../../widgets/app_text_field_description.dart';
import '../../widgets/app_text_filed_title.dart';
import '../../widgets/big_text.dart';

class EditItem extends StatefulWidget {
  final int itemId;
  final String initialCategory; // Add these fields to receive initial data
  final String initialTitle;
  final String initialDescription;
  final String initialLocation;
  final String status;

  const EditItem({
    Key? key,
    required this.itemId,
    required this.initialCategory,
    required this.initialTitle,
    required this.initialDescription,
    required this.initialLocation,
    required this.status
  }) : super(key: key);

  @override
  State<EditItem> createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  var titleController = TextEditingController();
  var descriptionController = TextEditingController();
  bool isDescriptionFocused = false;
  bool _isMounted = false;
  final _formKey = GlobalKey<FormState>();

  String? selectedCategoryValue;
  String? selectedLocationValue;

  List<dynamic> categoryList = [];
  final CategoryController categoryController = Get.put(CategoryController());

  List<dynamic> locationList = [];
  final LocationController locationController = Get.put(LocationController());

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
  @override
  void initState() {
    super.initState();
    _isMounted = true;
    titleController.text = widget.initialTitle;
    descriptionController.text = widget.initialDescription;

    categoryController.getCategoryList().then((result) {
      if (_isMounted) {
        setState(() {
          categoryList = result;

          // Find initial category ID
          String initialCategoryId = findCategoryIdByName(widget.initialCategory);
          // Set the initial value for AppDropdownFieldTitle
          selectedCategoryValue = initialCategoryId.isNotEmpty ? initialCategoryId : null;
        });
      }
    });

    locationController.getAllLocationPages().then((result) {
      if (_isMounted) {
        setState(() {
          locationList = result;

          // Find initial location ID
          String initialLocationId = findLocationIdByName(widget.initialLocation);
          // Set the initial value for AppDropdownFieldTitle
          selectedLocationValue = initialLocationId.isNotEmpty ? initialLocationId : null;
        });
      }
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
                      text: "Items",
                      size: 20,
                      color: AppColors.secondPrimaryColor,
                      fontW: FontWeight.w500,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: AppLayout.getWidth(30),
                      top: AppLayout.getHeight(10)),
                  child: Text(
                    'Edit Item',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                Gap(AppLayout.getHeight(20)),

                // Category
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
                      selectedCategoryValue = val?.toString();
                    });
                  },
                  titleText: "Category",
                ),
                Gap(AppLayout.getHeight(45)),

                // Title
                AppTextFieldTitle(
                  textController: titleController,
                  titleText: "Title",
                  validator: 'Please input title', hintText: '',
                ),
                Gap(AppLayout.getHeight(45)),

                // Description
                AppTextFieldDescription(
                  textController: descriptionController,
                  titleText: "Description",
                  onFocusChange: (isFocused) {
                    setState(() {
                      isDescriptionFocused = isFocused;
                    });
                  }, hintText: '',
                ),
                Gap(AppLayout.getHeight(45)),

                // Location
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

                Gap(AppLayout.getHeight(100)),

                Center(
                  child: AppButton(
                    boxColor: AppColors.primaryColor,
                    textButton: "Save Changes",
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        await ItemController().updateItemById(widget.itemId,
                            titleController.text,
                            descriptionController.text,
                            selectedCategoryValue!,
                            selectedLocationValue!,
                            widget.status);
                      }
                    },
                  ),
                ),
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
    super.dispose();
  }
}
