import 'package:flutter/material.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';

import '../utils/colors.dart';

class AppTextField extends StatelessWidget {
  late var textController;
  final String hintText;

  AppTextField(
      {Key? key,
      required this.textController,
      required this.hintText
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppLayout.getHeight(50),
      margin: EdgeInsets.only(
          left: AppLayout.getHeight(20), right: AppLayout.getHeight(20)),
      decoration: BoxDecoration(
          color: Colors.white,
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
        controller: textController,
        decoration: InputDecoration(
            hintText: hintText,
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
    );
  }
}
