import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';

import '../utils/colors.dart';

class AppTextFieldDescription extends StatefulWidget {
  final TextEditingController textController;
  final String hintText;
  final String titleText;
  final ValueChanged<bool>? onFocusChange;
  final int limitSymbols;

  AppTextFieldDescription({
    Key? key,
    required this.textController,
    required this.hintText,
    required this.titleText,
    this.onFocusChange,
    required this.limitSymbols,
  }) : super(key: key);

  @override
  _AppTextFieldDescriptionState createState() => _AppTextFieldDescriptionState();
}

class _AppTextFieldDescriptionState extends State<AppTextFieldDescription> {
  double minHeight = 55.0;
  double maxHeight = 200.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.only(left: 20),
          child: Text(
            widget.titleText,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Gap(AppLayout.getHeight(15)),
        LayoutBuilder(
          builder: (context, constraints) {
            return Container(
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
              child: TextFormField(
                onSaved: (value) => widget.textController.text = value ?? '',
                style: Theme.of(context).textTheme.headlineSmall,
                controller: widget.textController,
                maxLines: null, // Allow unlimited lines
                maxLength: widget.limitSymbols,
                textInputAction: TextInputAction.done, // Change the keyboard action to "Done"
                decoration: InputDecoration(
                  isDense: true,
                  hintText: widget.hintText,
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
                    borderSide: BorderSide(width: 1.0, color: Colors.white),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please input description";
                  }
                  return null;
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

