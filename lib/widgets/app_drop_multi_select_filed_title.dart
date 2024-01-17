import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../utils/app_layout.dart';

class AppDropdownMultiSelectFieldTitle extends StatelessWidget {
  final List<String> selectedValues;
  final List<MultiSelectItem<String>> items;
  final Function(List<String>) onChanged;
  final String titleText;
  final String hintText;
  final String validator;

  AppDropdownMultiSelectFieldTitle({
    Key? key,
    required this.selectedValues,
    required this.items,
    required this.onChanged,
    required this.titleText,
    required this.hintText,
    required this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate the dynamic height based on the number of selected values
    double containerHeight = AppLayout.getHeight(55) +
        ((selectedValues.length / 2).ceil() * AppLayout.getHeight(60));

    return Form(
      child: Column(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 20),
            child: Text(
              titleText,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Gap(AppLayout.getHeight(15)),
          Container(
            height: containerHeight,
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
            child: MultiSelectDialogField<String>(
              title: Text(hintText),
              items: items,
              initialValue: selectedValues,
              listType: MultiSelectListType.CHIP,
              selectedColor: AppColors.primaryColor,
              selectedItemsTextStyle: TextStyle(color: Colors.white),
              buttonText: Text(
                hintText,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              onConfirm: (values) {
                onChanged(values);
              },
              chipDisplay: MultiSelectChipDisplay<String>(
                onTap: (value) {
                  onChanged([...selectedValues]..remove(value));
                },
                chipColor: AppColors.primaryColor,
                textStyle: TextStyle(color: Colors.white),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return validator;
                }
                return null;
              },
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppLayout.getHeight(20)),
                border: Border.all(
                  color: Colors.white,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
