import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';

import '../../routes/route_helper.dart';
import '../../utils/app_constraints.dart';
import '../../widgets/generator_qrcode.dart';

class MyQrCode extends StatefulWidget {
  const MyQrCode({super.key});

  @override
  State<MyQrCode> createState() => _MyQrCodeState();
}

class _MyQrCodeState extends State<MyQrCode> {
  late String uid = "";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 0), () async {
      uid = await AppConstrants.getUid();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Gap(AppLayout.getHeight(50)),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Get.toNamed(RouteHelper.getInitial(3));
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.grey,
                  size: 30,
                ),
              ),
            ],
          ),
          Gap(AppLayout.getHeight(150)),

          Center(
            child: GeneratorQrCode(data: uid),
          )
        ],
      ),
    );
  }
}
