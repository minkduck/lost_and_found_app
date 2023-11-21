import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/widgets/app_button.dart';

import '../pages/claims/take_picture_claim.dart';
import '../utils/colors.dart';
import 'big_text.dart';

class PrintDataQrCode extends StatelessWidget {
  final String result;
  final String userId;
  const PrintDataQrCode({Key? key, required this.result, required this.userId}) : super(key: key);

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
                    Navigator.pop(context);
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
                BigText(
                  text: "Scan qrCode",
                  size: 20,
                  color: AppColors.secondPrimaryColor,
                  fontW: FontWeight.w500,
                ),
              ],
            ),
            Gap(AppLayout.getHeight(50)),
            Center(
              child: Text('Scanned QR Code: $result'),
            ),
            Spacer(),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              child: AppButton(boxColor: AppColors.primaryColor, textButton: "Take a photo", onTap: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TakePictureClaim(resultScanQrCode: result, userId: userId,),
                  ),
                );
              }),
            )
          ],
        ),
      ),
    );
  }
}
