import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/data/api/location/location_controller.dart';
import 'package:lost_and_find_app/pages/items/take_picture.dart';
import 'package:lost_and_find_app/widgets/app_button.dart';
import 'package:get/get.dart';

import '../../data/api/category/category_controller.dart';
import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/app_drop_menu_filed_title.dart';
import '../../widgets/app_text_field_description.dart';
import '../../widgets/app_text_field_title_limit.dart';
import '../../widgets/app_text_filed_title.dart';
import '../../widgets/big_text.dart';

class CreateItem extends StatefulWidget {
  const CreateItem({super.key});

  @override
  State<CreateItem> createState() => _CreateItemState();
}

class _CreateItemState extends State<CreateItem> {
  var titleController =
      TextEditingController();
  var descriptionController =
      TextEditingController();
  bool isDescriptionFocused = false;
  bool _isMounted = false;
  final _formKey = GlobalKey<FormState>();

  String? selectedCategoryValue;
  String? selectedLocationValue;
  String? selectedSlot;
  DateTime? selectedDate;

  List<dynamic> categoryList = [];
  final CategoryController categoryController = Get.put(CategoryController());

  List<dynamic> locationList = [];
  final LocationController locationController = Get.put(LocationController());

  String? validateFoundDate() {
    if (selectedDate == null) {
      return 'Please select a date';
    }
    return null;
  }

  List<DropdownMenuItem<String>> getSlotItems() {
    return [
      'Before class',
      'Slot 1',
      'Slot 2',
      'Slot 3',
      'Slot 4',
      'Slot 5',
      'Slot 6',
      'After class',
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
          print("locationList" + locationList.toString());
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
                    'Create Items',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                Gap(AppLayout.getHeight(20)),

                //title
                AppTextFieldTitleLimit(
                  textController: titleController,
                  hintText: "A title needs at least 10 characters",
                  titleText: "Title",
                  validator: 'Please input title',
                  limitSymbols: 50,
                ),
                Gap(AppLayout.getHeight(45)),

                //description
                AppTextFieldDescription(
                  textController: descriptionController,
                  hintText: "Describe important information",
                  titleText: "Description",
                  limitSymbols: 100,
                  onFocusChange: (isFocused) {
                    setState(() {
                      isDescriptionFocused = isFocused;
                    });
                  },
                ),
                Gap(AppLayout.getHeight(45)),

                //foundDate
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
                if (_formKey.currentState != null && _formKey.currentState!.validate())
                  Text(
                    validateFoundDate() ?? '',
                    style: TextStyle(color: Colors.red),
                  ),
                Gap(AppLayout.getHeight(45)),


                //slot
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

                Gap(AppLayout.getHeight(45)),
                //Location
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
                  titleText: "Found Location",
                ),

                Gap(AppLayout.getHeight(100)),

                Center(
                  child: AppButton(
                    boxColor: AppColors.primaryColor,
                    textButton: "Continue",
                    onTap: () {
                      if (_formKey.currentState != null &&
                          _formKey.currentState!.validate() &&
                          validateFoundDate() == null) {
                        String foundDate = "$selectedDate|${selectedSlot!}";
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TakePictureScreen(
                              title: titleController.text,
                              description: descriptionController.text,
                              category: selectedCategoryValue!,
                              location: selectedLocationValue!,
                              foundDate: foundDate,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),              ],
            ),
          ),
        ),
      ),
    );
  }
}
