import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/pages/auth/sign_up_page.dart';
import 'package:lost_and_find_app/pages/home/home_page.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:lost_and_find_app/widgets/app_text_field.dart';
import 'package:lost_and_find_app/widgets/app_text_filed_title.dart';

import '../../widgets/app_button.dart';
import '../../widgets/app_button_upload_image.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var emailController = TextEditingController();
  var passwordController = TextEditingController();


  Future<void> loginEmailPassword() async {
    const String apiUrl = 'https://lostandfound.io.vn/auth/login';

    final Map<String, dynamic> data = {
      'email': emailController.text,
      'password': passwordController.text,
    };
    final response = await http.post(Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data));
    print(response.toString());
    if (response.statusCode == 200) {
      print("login success");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      // Failed login
      print(response.statusCode);

      Fluttertoast.showToast(
          msg: "Login failed. Please check your credentials.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Gap(AppLayout.getHeight(100)),
            Container(
              alignment: Alignment.center,
              child: Text(
                "Log In.",
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            Gap(AppLayout.getHeight(40)),
/*          Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.only(left: 20),
              child: Text("NAME",
                  style: TextStyle(
                      fontSize: 20,
                      color: AppColors.titleColor,
                      fontWeight: FontWeight.bold)),
            ),
            Gap(AppLayout.getHeight(20)),
            AppTextField(textController: emailController, hintText: "")*/
            AppTextFieldTitle(
                textController: emailController,
                hintText: "",
                titleText: "EMAIL"),
            Gap(AppLayout.getHeight(40)),
            AppTextFieldTitle(
                textController: passwordController,
                hintText: "",
                titleText: "PASSWORD"),
            Gap(AppLayout.getHeight(40)),
            Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 15),
              child: Text(
                "Forgot password?",
                style: TextStyle(
                    fontSize: 20,
                    color: AppColors.secondPrimaryColor),
              ),
            ),
            Gap(AppLayout.getHeight(40)),
            AppButtonUpLoadImage(
                boxColor: AppColors.primaryColor,
                textButton: "Log In",
                onTap: () {
                  loginEmailPassword();
                }),
            Gap(AppLayout.getHeight(40)),
            Container(
              padding: EdgeInsets.only(right: AppLayout.getHeight(15)),
              child: Text(
                "OR SIGN IN WITH",
                style: TextStyle(
                    fontSize: 18,
                    color: AppColors.secondPrimaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Gap(AppLayout.getHeight(40)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {

                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[500],
                    radius: 30,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage:
                      AssetImage(AppAssets.facebookLogo!),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {

                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[500],
                    radius: 30,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage:
                      AssetImage(AppAssets.twitterLogo!),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {

                  },
                  child: CircleAvatar(
                    backgroundColor: Colors.grey[500],
                    radius: 30,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundImage:
                      AssetImage(AppAssets.googleLogo!),
                    ),
                  ),
                ),

              ],
            ),
            Gap(AppLayout.getHeight(60)),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => SignUpPage()));
              },
              child: RichText(
                text: TextSpan(
                    text: "Don’t have an account?",
                    style: TextStyle(
                        fontSize: 20,
                        color: AppColors.titleLSColor),
                    children: [
                      TextSpan(
                          text: " Sign up",
                          style: TextStyle(
                              fontSize: 20,
                              color: AppColors.secondPrimaryColor,
                              fontWeight: FontWeight.bold
                          )
                      )
                    ]),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
