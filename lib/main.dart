import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lost_and_find_app/pages/auth/login_page.dart';
import 'package:lost_and_find_app/pages/auth/sign_up_page.dart';
import 'package:lost_and_find_app/pages/home/home_page.dart';
import 'package:lost_and_find_app/pages/home/home_screen.dart';
import 'package:lost_and_find_app/pages/items/create_item.dart';
import 'package:lost_and_find_app/pages/items/items_detail.dart';
import 'package:lost_and_find_app/pages/items/take_picture.dart';
import 'package:lost_and_find_app/pages/post/post_detail.dart';
import 'package:lost_and_find_app/pages/post/post_screen.dart';
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
      title: 'Find and Lost App',
      debugShowCheckedModeBanner: false,

      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      home: LoginPage(),
    );
  }
}

