import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:lost_and_find_app/data/api/auth/google_sign_in.dart';
import 'package:lost_and_find_app/data/api/category/category_controller.dart';
import 'package:lost_and_find_app/data/api/comment/comment_controller.dart';
import 'package:lost_and_find_app/data/api/item/item_controller.dart';
import 'package:lost_and_find_app/data/api/location/location_controller.dart';
import 'package:lost_and_find_app/data/api/post/post_controller.dart';
import 'package:lost_and_find_app/utils/app_constraints.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/app_styles.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:lost_and_find_app/widgets/app_drop_menu_filed_title.dart';
import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:lost_and_find_app/widgets/generator_qrcode.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../data/api/item/receipt_controller.dart';
import '../data/api/message/chat_controller.dart';
import '../utils/app_assets.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/app_button.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _HomePageState();
}

class _HomePageState extends State<TestPage> {
  List<String> _selectedItems = [];

  void _showMultiSelect() async {
    // a list of selectable items
    // these items can be hard-coded or dynamically fetched from a database/API
    final List<String> items = [
      'Flutter',
      'Node.js',
      'React Native',
      'Java',
      'Docker',
      'MySQL'
    ];

    final List<String>? results = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 300,
            child: MultiSelect(items: items));
      },
    );

    // Update UI
    if (results != null) {
      setState(() {
        _selectedItems = results;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('dbestech'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // use this button to open the multi-select dialog
            ElevatedButton(
              onPressed: _showMultiSelect,
              child: const Text('Select Your Favorite Topics'),
            ),
            const Divider(
              height: 30,
            ),
            // display selected items
            Wrap(
              children: _selectedItems
                  .map((e) => Chip(
                label: Text(e),
              ))
                  .toList(),
            )          ],
        ),
      ),
    );
  }
}

class MultiSelect extends StatefulWidget {
  final List<String> items;
  const MultiSelect({Key? key, required this.items}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MultiSelectState();
}

class _MultiSelectState extends State<MultiSelect> {
  // this variable holds the selected items
  final List<String> _selectedItems = [];

// This function is triggered when a checkbox is checked or unchecked
  void _itemChange(String itemValue, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedItems.add(itemValue);
      } else {
        _selectedItems.remove(itemValue);
      }
    });
  }

  // this function is called when the Cancel button is pressed
  void _cancel() {
    Navigator.pop(context);
  }

// this function is called when the Submit button is tapped
  void _submit() {
    Navigator.pop(context, _selectedItems);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Topics'),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.items
              .map((item) => CheckboxListTile(
            value: _selectedItems.contains(item),
            title: Text(item),
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (isChecked) => _itemChange(item, isChecked!),
          ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _cancel,
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
