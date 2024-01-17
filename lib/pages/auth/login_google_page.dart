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
  bool acceptedTerms = false; // Track the acceptance state


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
                  if (acceptedTerms) {
                    final provider =
                    Provider.of<GoogleSignInProvider>(context, listen: false);
                    await provider.googleLogin(selectedCampus!);
                    final SharedPreferences prefs =
                    await SharedPreferences.getInstance();
                    prefs.setString('firstLogin', 'firstLogin');
                  } else {
                    // Show error message if terms are not accepted
                    SnackbarUtils().showError(
                      title: "Term of Service",
                      message: "You must agree to our Term of Service",
                    );
                  }
                }
              },
              child: Ink(
                width: AppLayout.getWidth(325),
                height: AppLayout.getHeight(50),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
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
            ),
            Gap(AppLayout.getHeight(50)),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Checkbox(
                    value: acceptedTerms,
                    onChanged: (bool? value) {
                      setState(() {
                        acceptedTerms = value ?? false;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      // Show the terms of service dialog
                      _showTermsOfServiceDialog(context);
                    },
                    child: Text(
                      'By log in, you agree to our Terms of Service',
                      style: TextStyle(
                        color: Colors.blue, // You can customize the color
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showTermsOfServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Lost and Found Content Guidelines'),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome to Lost and Found, a community dedicated to helping people find their lost items and report found items. Our platform relies on the collaborative efforts of users like you to make it a valuable resource for reuniting people with their belongings.",
                  style: TextStyle(fontSize: 14),
                ),
                SizedBox(height: 15),
                Text(
                  "1. Purpose of Lost and Found:",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "- Lost and Found is a space for users to post, comment, and connect with others in the pursuit of finding lost items or reporting found items. Please use this platform for its intended purpose, promoting a sense of community and helpfulness.",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 15),
                Text(
                  "2. Respect and Consideration:",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "- Remember that Lost and Found is a community built on empathy and assistance. Be respectful and considerate in all interactions, focusing on helping others in their time of need.",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 15),
                Text(
                  "3. Authentic and Relevant Content:",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "- Post authentic content related to lost items or found items within communities where you have a personal interest in assisting. Avoid cheating, manipulation, or any actions that disrupt the primary purpose of this platform.",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 15),
                Text(
                  "4. Privacy and Sensitivity:",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "- Respect the privacy and sensitivity of individuals seeking help. Do not engage in any form of harassment or reveal personal information without consent. Never post or threaten to post intimate or inappropriate content.",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 15),
                Text(
                  "5. Protection of Minors:",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "- Strictly adhere to rules against sharing or encouraging the sharing of inappropriate content involving minors. Report any predatory or inappropriate behavior involving a minor immediately.",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 15),
                Text(
                  "6. Genuine Identity:",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "- While using a pseudonym is allowed, do not impersonate individuals or entities in a misleading or deceptive manner. Maintain transparency and honesty in your interactions.",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 15),
                Text(
                  "7. Content Labeling:",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "- Ensure a consistent and predictable experience for users by accurately labeling content. Clearly indicate the nature of lost or found items to streamline the search process.",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 15),
                Text(
                  "8. Legal Compliance:",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "- Keep all content legal and avoid posting any illegal material. Do not solicit or facilitate illegal or prohibited transactions on Lost and Found.",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 15),
                Text(
                  "9. Platform Integrity:",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "- Do not engage in any activities that may break the functionality of Lost and Found or interfere with the normal use of the platform.",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 15),
                Text(
                  "Our commitment to maintaining a helpful and respectful community is reinforced through various enforcement actions, including:",
                  style: TextStyle(fontSize: 14),
                ),
                Text(
                  "- Friendly requests to adhere to guidelines.",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                Text(
                  "- Stronger requests if necessary.",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                Text(
                  "- Temporary or permanent suspension of accounts.",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                Text(
                  "- Removal of privileges or restrictions on accounts.",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                Text(
                  "- Removal of content.",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 15),
                Text(
                  "Together We Build Lost and Found:",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 15),
                Text(
                  "Lost and Found is a collaborative effort, and its success depends on the shared commitment to our guidelines. By abiding not just by the letter but the spirit of these rules, you contribute to a positive and helpful community.",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
                SizedBox(height: 10),
                Text(
                  "Thank you for being an integral part of Lost and Found!",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  acceptedTerms = true; // Set the acceptance state to true
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Accept'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
