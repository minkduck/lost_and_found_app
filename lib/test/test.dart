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

import '../utils/app_assets.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/app_button.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final _productSizeList = ["Small", "Medium", "Large", "XLarge"];
  String? _selectedValue = "";
  late String fcmToken = "";
  late String accessToken = "";
  TextEditingController textController = TextEditingController();

/*
  List<dynamic> filterMyItemsByCategories() {
    // Apply category filtering first
    final List<dynamic> filteredByCategories = myItemlist.where((item) {
      final category = item['categoryName'];
      return selectedCategories.isEmpty ||
          selectedCategories.contains(category);
    }).toList();

    // Apply text filter
    final filteredByText = filteredByCategories
        .where((item) =>
    filterText.isEmpty ||
        (item['name'] != null &&
            item['name'].toLowerCase().contains(filterText.toLowerCase())))
        .toList();

    return filteredByText;
  }
*/

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
                Get.find<LocationController>().getAllLocationPages();
                // Get.find<CommentController>().getCommentByPostId(1);

              },
              child: Text('button'),
            ),
            Gap(AppLayout.getHeight(20)),
            Column(
              children:[
                // QrImageView(
                //   data: "anh dung day tu chieu",
                //   padding: const EdgeInsets.all(0),
                //   foregroundColor: AppColors.primaryColor,
                //   embeddedImage: AssetImage('assets/images/app_icon_5.png'),
                //   embeddedImageStyle: QrEmbeddedImageStyle(
                //     size: const Size(100, 100),
                //   ),
                //   eyeStyle: const QrEyeStyle(
                //     eyeShape: QrEyeShape.circle,
                //
                //   ),
                // ),
                const GeneratorQrCode(data: "anh dung day tu chieu")
              ]
            )
          ],
        ),
      ),
    );
  }
}
