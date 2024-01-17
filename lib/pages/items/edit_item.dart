import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
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
  final String slot;
  final DateTime date;
  final String status;

  const EditItem({
    Key? key,
    required this.itemId,
    required this.initialCategory,
    required this.initialTitle,
    required this.initialDescription,
    required this.initialLocation,
    required this.slot,
    required this.date,
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
  DateTime? selectedDate;

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

  String? selectedSlot;

  List<DropdownMenuItem<String>> getSlotItems() {
    return [
      'Before Class',
      'Slot 1',
      'Slot 2',
      'Lunch Break',
      'Slot 3',
      'Slot 4',
      'Slot 5',
      'Slot 6',
      'All day',
    ].map((String slot) {
      return DropdownMenuItem<String>(
        value: slot,
        child: Text(slot),
      );
    }).toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? currentDate,
      firstDate: DateTime(2022),
      lastDate: currentDate,
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    titleController.text = widget.initialTitle;
    descriptionController.text = widget.initialDescription;
    selectedDate = widget.date;
    selectedSlot = widget.slot;
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
                  limitSymbols: 100,
                  onFocusChange: (isFocused) {
                    setState(() {
                      isDescriptionFocused = isFocused;
                    });
                  }, hintText: '',
                ),
                Gap(AppLayout.getHeight(45)),

                //found date
                Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    "Found Date",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Gap(AppLayout.getHeight(15)),
                GestureDetector(
                  onTap: () => _selectDate(context),
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
                        selectedDate != null
                            ? "${selectedDate!.toLocal()}".split(' ')[0]
                            : "Tap to select date",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
                Gap(AppLayout.getHeight(45)),

                // slot
                AppDropdownFieldTitle(
                  hintText: "Select a slot",
                  validator: "Please choose slot",
                  selectedValue: selectedSlot,
                  items: getSlotItems(),
                  onChanged: (val) {
                    setState(() {
                      selectedSlot = val;
                    });
                  },
                  titleText: "Slot",
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

                Gap(AppLayout.getHeight(45)),
                Center(
                  child: AppButton(
                    boxColor: AppColors.primaryColor,
                    textButton: "Save Changes",
                    onTap: () async {
                      if (_formKey.currentState!.validate()) {
                        String foundDate = "$selectedDate|${selectedSlot!}";
                        print("foundDate: "+ foundDate);
                        await ItemController().updateItemById(widget.itemId,
                            titleController.text,
                            descriptionController.text,
                            selectedCategoryValue!,
                            selectedLocationValue!,
                            // widget.status,
                            foundDate
                        );
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
