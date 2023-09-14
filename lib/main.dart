import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lost_and_find_app/pages/auth/login_page.dart';
import 'package:lost_and_find_app/pages/home/home_page.dart';
import 'package:lost_and_find_app/pages/home/home_screen.dart';
import 'package:lost_and_find_app/pages/items/create_item.dart';
import 'package:lost_and_find_app/pages/items/items_detail.dart';
import 'package:lost_and_find_app/pages/splash/login_signup_page.dart';
import 'package:lost_and_find_app/test/category_screen.dart';
import 'package:lost_and_find_app/test/test.dart';
import 'package:lost_and_find_app/utils/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,

      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      home: CreateItem(),
    );
  }
}

