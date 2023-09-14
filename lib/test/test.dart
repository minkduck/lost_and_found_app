import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/app_styles.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('hello'),
      ),
      body:  Column(
        children: [
          Center(
            child: Text('Hello',style: AppStyles.h1.copyWith()),
          ),

          Gap(AppLayout.getHeight(20)),
          Center(
            child: Text('hêllo'),
          ),
        ],
      ),
    );
  }
}
