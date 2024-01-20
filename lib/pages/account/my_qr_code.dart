import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lost_and_find_app/data/api/user/user_controller.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';

import '../../routes/route_helper.dart';
import '../../utils/app_constraints.dart';
import '../../utils/colors.dart';
import '../../widgets/big_text.dart';
import '../../widgets/generator_qrcode.dart';

class MyQrCode extends StatefulWidget {
  const MyQrCode({super.key});

  @override
  State<MyQrCode> createState() => _MyQrCodeState();
}

class _MyQrCodeState extends State<MyQrCode> {
  late String uid = "";
  bool isLoading = false;
  bool _isMounted = false;
  final UserController userController = Get.put(UserController());
  Uint8List? qrCodeBytes;

  @override
  void initState() {
    super.initState();
    _isMounted = true;

    Future.delayed(Duration(seconds: 1), () async {
      uid = await AppConstrants.getUid();
      await userController.getQrCode().then((result) {
        if (_isMounted) {
          setState(() {
            qrCodeBytes  = result;
          });
        }
      });

      setState(() {
        isLoading = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Gap(AppLayout.getHeight(50)),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.toNamed(RouteHelper.getInitial(4));
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
                BigText(
                  text: "My QrCode",
                  size: 20,
                  color: AppColors.secondPrimaryColor,
                  fontW: FontWeight.w500,
                ),

              ],
            ),
            Gap(AppLayout.getHeight(150)),

/*          isLoading ? Center(
              child: GeneratorQrCode(data: uid),
            ) : Center(child: CircularProgressIndicator(),)*/
            isLoading ? Image.memory(qrCodeBytes!) : Center(child: CircularProgressIndicator(),)
    ],
        ),
      ),
    );
  }
}
