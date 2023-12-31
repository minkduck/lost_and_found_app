import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lost_and_find_app/data/api/campus/campus_controller.dart';
import 'package:lost_and_find_app/utils/colors.dart';
import 'package:lost_and_find_app/widgets/app_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/api/auth/google_sign_in.dart';
import '../../data/api/category/category_controller.dart';
import '../../utils/app_assets.dart';
import '../../utils/app_layout.dart';
import '../../utils/snackbar_utils.dart';

class LoginGooglePage extends StatefulWidget {
  const LoginGooglePage({Key? key}) : super(key: key);

  @override
  State<LoginGooglePage> createState() => _LoginGooglePageState();
}

class _LoginGooglePageState extends State<LoginGooglePage> {
  String? selectedCampus;
  List<dynamic> campusList = [];
  List<DropdownMenuItem<String>> items = [];


  late ValueChanged<String?> onChanged;
  final CampusController campusController = Get.put(CampusController());


  @override
  void initState() {
    super.initState();
    onChanged = (String? newValue) {
      setState(() {
        selectedCampus = newValue;
      });
    };
    campusController.getAllCampus().then((result) {
        setState(() {
          campusList = result;
          items = campusList.map((campus) {
            return DropdownMenuItem(
              value: campus['id'].toString(),
              child: Text(campus['name']),
            );
          }).toList();
        });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Gap(AppLayout.getHeight(200)),
            Center(
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 80),
                child: Image.asset(
                  AppAssets.lostAndFound,
                  width: AppLayout.getScreenWidth() - 75,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Gap(AppLayout.getHeight(160)),

            Container(
              width: 300,
              child: DropdownButtonFormField<String>(
                value: selectedCampus,
                items: items,
                style: Theme.of(context).textTheme.headlineSmall,
                onChanged: onChanged,
                decoration: InputDecoration(
                  isDense: true,
                  // contentPadding: EdgeInsets.zero,
                  hintText: 'Select Campus',
                  hintStyle: Theme.of(context).textTheme.labelSmall,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppLayout.getHeight(20)),
                    borderSide: BorderSide(
                      width: 1.0,
                      color: Theme.of(context).highlightColor,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppLayout.getHeight(20)),
                    borderSide: BorderSide(
                      width: 1.0,
                      color: Theme.of(context).highlightColor,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please choose campus";
                  }
                  return null;
                },

              ),
            ),
            Gap(AppLayout.getHeight(50)),

            InkWell(
              onTap: () async {
                if (selectedCampus != null) {
                  final provider =
                  Provider.of<GoogleSignInProvider>(context, listen: false);
                  await provider.googleLogin(selectedCampus!);
                  final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  prefs.setString('firstLogin', 'firstLogin');
                }
              },
              child: Ink(
                width: AppLayout.getWidth(325),
                height: AppLayout.getHeight(50),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor, // Set the color here
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppLayout.getHeight(15)),
                    topRight: Radius.circular(AppLayout.getHeight(15)),
                    bottomLeft: Radius.circular(AppLayout.getHeight(15)),
                    bottomRight: Radius.circular(AppLayout.getHeight(15)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    )
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        AppAssets.googleLogo,
                        height: 24,
                        width: 24,
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Sign in with Google Account',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
