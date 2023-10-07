import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/widgets/app_button.dart';

import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/app_drop_menu_filed_title.dart';
import '../../widgets/app_text_filed_title.dart';
import '../../widgets/big_text.dart';

class CreateItem extends StatefulWidget {
  const CreateItem({super.key});

  @override
  State<CreateItem> createState() => _CreateItemState();
}

class _CreateItemState extends State<CreateItem> {
  var categoryController = TextEditingController();
  var titleController = TextEditingController(); // Separate controller for title
  var descriptionController = TextEditingController(); // Separate controller for description
  var locationController = TextEditingController(); // Separate controller for location

  final _productSizeList =["Small", "Medium", "Large", "XLarge"];
  String? _selectedValue = "";

  @override
  void initState() {
    super.initState();
    _selectedValue = _productSizeList[0];
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
                    text: "Items",
                    size: 20,
                    color: AppColors.secondPrimaryColor,
                    fontW: FontWeight.w500,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: AppLayout.getWidth(30), top: AppLayout.getHeight(10)),
                child: Text('Create ad', style: Theme.of(context).textTheme.displayMedium,),
              ),
              Gap(AppLayout.getHeight(20)),

              //category
              AppDropdownFieldTitle(
                  hintText: "Select a category",
                  selectedValue: _selectedValue,
                  items: _productSizeList.map((e) {
                    return DropdownMenuItem(child: Text(e), value: e,);
                  }).toList(),
                  onChanged: (val){
                    setState(() {
                      _selectedValue = val as String;
                    });
                  },
                  titleText: "Category"),
              Gap(AppLayout.getHeight(45)),

              //title
              AppTextFieldTitle(
                  textController: titleController,
                  hintText: "A title needs at least 10 characters",
                  titleText: "Title"),
              Gap(AppLayout.getHeight(45)),

              //description
              AppTextFieldTitle(
                  textController: descriptionController,
                  hintText: "Describe important information",
                  titleText: "Description"),
              Gap(AppLayout.getHeight(45)),

              //Location
              AppDropdownFieldTitle(
                  hintText: "Where item was found",
                  selectedValue: _selectedValue,
                  items: _productSizeList.map((e) {
                    return DropdownMenuItem(child: Text(e), value: e,);
                  }).toList(),
                  onChanged: (val){
                    setState(() {
                      _selectedValue = val as String;
                    });
                  },
                  titleText: "Location"),
              Gap(AppLayout.getHeight(100)),
              
              Center(
                child: AppButton(boxColor: AppColors.primaryColor, textButton: "Continue", onTap: (){

                }),
              ),


            ],
          ),
        ),
      ),
    );
  }
}
