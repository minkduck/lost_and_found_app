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
import 'package:lost_and_find_app/data/api/notifications/notification_controller.dart';
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
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  Stream? member;
  final _productSizeList = ["Small", "Medium", "Large", "XLarge"];
  String? _selectedValue = "";
  late String fcmToken = "";
  late String accessToken = "";
  TextEditingController textController = TextEditingController();
  List<Map<String, dynamic>> userAndChatList = [];

  Future<void> fetchAndPrintUserChats() async {
    ChatController(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupChats("FzEZGbNisxb96Y8IaFC0nQ2S7Zr1FLtIEJvuMgfg58u4sXhzxPn9qr73")
        .then((val) {
      setState(() {
        member = val;
      });
      print("chats:" + member.toString());
    });
  }


  @override
  void initState() {
    super.initState();
    _selectedValue = _productSizeList[0];

    // Future<void> fetchAndPrintUserChats() async {
    ChatController(uid: FirebaseAuth.instance.currentUser!.uid)
        .getGroupChats("FzEZGbNisxb96Y8IaFC0nQ2S7Zr1FLtIEJvuMgfg58u4sXhzxPn9qr73")
        .then((val) {
      setState(() {
        member = val;
      });
      print("chats:" + member.toString());
    });
    // }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('hello'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                // fcmToken = await AppConstrants.getFcmToken();
                // accessToken = await AppConstrants.getToken();
                // SnackbarUtils().showSuccess(title: "Success", message: "Login google successfully");
                // SnackbarUtils().showError(title: "Error", message: "Some thing wrong");
                // SnackbarUtils().showInfo(title: "Info", message: "Info");
                // SnackbarUtils().showLoading(message: "loading");
                // Get.find<ItemController>().getItemByUidList();
                // Get.find<CategoryController>().getCategoryGroupList();
                // Get.find<PostController>().getPostByUidList();
                // Get.find<LocationController>().getAllLocationPages();
                // Get.find<NotificationController>().getNotificationListByUserId();
                // fcmToken = await AppConstrants.getFcmToken();
                // print("fcmToken" + fcmToken);
              },
              child: Text('button'),
            ),
            Gap(AppLayout.getHeight(20)),
            Column(
                children:[

                ]
            )
          ],
        ),
      ),
    );
  }
}
