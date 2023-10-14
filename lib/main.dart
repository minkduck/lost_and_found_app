import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lost_and_find_app/data/api/firebase/firebase_notification.dart';
import 'package:lost_and_find_app/pages/account/profile_page.dart';
import 'package:lost_and_find_app/pages/auth/login_google_page.dart';
import 'package:lost_and_find_app/pages/auth/login_page.dart';
import 'package:lost_and_find_app/pages/auth/sign_up_page.dart';
import 'package:lost_and_find_app/pages/home/home_page.dart';
import 'package:lost_and_find_app/pages/home/home_screen.dart';
import 'package:lost_and_find_app/pages/home_login_page.dart';
import 'package:lost_and_find_app/pages/items/create_item.dart';
import 'package:lost_and_find_app/pages/items/items_detail.dart';
import 'package:lost_and_find_app/pages/items/take_picture.dart';
import 'package:lost_and_find_app/pages/message/message_page.dart';
import 'package:lost_and_find_app/pages/post/post_detail.dart';
import 'package:lost_and_find_app/pages/post/post_screen.dart';
import 'package:lost_and_find_app/pages/splash/login_signup_page.dart';
import 'package:lost_and_find_app/routes/route_helper.dart';
import 'package:lost_and_find_app/test/filter/product_list.dart';
import 'package:lost_and_find_app/test/test.dart';
import 'package:lost_and_find_app/test/upload%20file%20and%20picture/upload-file.dart';
import 'package:lost_and_find_app/utils/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:lost_and_find_app/data/api/auth/google_sign_in.dart';


Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseNotification().initNotifications();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),

      child: GetMaterialApp(

        title: 'Find and Lost App',
        debugShowCheckedModeBanner: false,

        theme: TAppTheme.lightTheme,
        darkTheme: TAppTheme.darkTheme,
        themeMode: ThemeMode.system,

        // initialRoute: RouteHelper.initial,
        // getPages: RouteHelper.routes,
        home: HomeLoginPage(),
      ),
    );
  }
}

