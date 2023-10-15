import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';

import '../utils/colors.dart';

class AppDropdownFieldTitle extends StatelessWidget {
  final String? selectedValue;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;
  final String titleText;
  final String hintText;

  AppDropdownFieldTitle({
    Key? key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    required this.titleText,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
          height: AppLayout.getHeight(55),
          margin: EdgeInsets.only(
              left: AppLayout.getHeight(20),
              right: AppLayout.getHeight(20)),
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
          child: DropdownButtonFormField<String>(
            value: selectedValue,
            items: items,
            style: Theme.of(context).textTheme.headlineSmall,
            onChanged: onChanged,
            decoration: InputDecoration(
              isDense: true,
              // contentPadding: EdgeInsets.zero,
              hintText: hintText,
              hintStyle: Theme.of(context).textTheme.labelSmall,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppLayout.getHeight(20)),
                borderSide: BorderSide(
                  width: 1.0,
                  color: Colors.white,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppLayout.getHeight(20)),
                borderSide: BorderSide(
                  width: 1.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
