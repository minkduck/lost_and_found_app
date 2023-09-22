import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';

import '../utils/colors.dart';

class AppTextFieldTitle extends StatelessWidget {
  late var textController;
  final String hintText;
  final String titleText;


  AppTextFieldTitle(
      {Key? key,
        required this.textController,
        required this.hintText,
        required this.titleText
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 20),
          child: Text(
              titleText,
              style: Theme.of(context).textTheme.titleMedium,)
        ),
        Gap(AppLayout.getHeight(15)),
        Container(
          height: AppLayout.getHeight(55),
          margin: EdgeInsets.only(
              left: AppLayout.getHeight(20), right: AppLayout.getHeight(20)),
          decoration: BoxDecoration(
              color: Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(AppLayout.getHeight(20)),
              boxShadow: [
                BoxShadow(
                    blurRadius: 4,
                    spreadRadius: 4,
                    offset: Offset(0, 4),
                    color: Colors.grey.withOpacity(0.2))
              ]),
          child: TextFormField(
            onSaved: (value) => textController = value,
            style: Theme.of(context).textTheme.headlineSmall,
            controller: textController,
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
                    )),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppLayout.getHeight(20)),
                    borderSide: BorderSide(width: 1.0, color: Colors.white))),
          ),
        ),
      ],
    );
  }
}
