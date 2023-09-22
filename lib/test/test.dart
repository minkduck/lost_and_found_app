import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/app_styles.dart';
import 'package:lost_and_find_app/widgets/app_drop_menu_filed_title.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
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
      appBar: AppBar(
        title: Text('hello'),
      ),
      body: Column(
        children: [
          Center(
            child: Text('Hello', style: AppStyles.h1.copyWith()),
          ),
          Gap(AppLayout.getHeight(20)),
          Center(
            child: AppDropdownFieldTitle(
              hintText: "sdfsdfsdfsdf",
                selectedValue: _selectedValue,
                items: _productSizeList.map((e) {
                  return DropdownMenuItem(child: Text(e), value: e,);
                }).toList(),
                onChanged: (val){
                  setState(() {
                    _selectedValue = val as String;
                  });
                },
                titleText: "titleText"),
          ),
        ],
      ),
    );
  }
}
