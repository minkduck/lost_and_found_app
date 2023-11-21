import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';

import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/big_text.dart';

class GetAccepctClaimDetail extends StatefulWidget {
  final String resultScanQrCode;
  final String userId;
  final List<XFile>? imageFileList;
  const GetAccepctClaimDetail({Key? key, required this.imageFileList, required this.userId, required this.resultScanQrCode}) : super(key: key);

  @override
  State<GetAccepctClaimDetail> createState() => _GetAccepctClaimDetailState();
}

class _GetAccepctClaimDetailState extends State<GetAccepctClaimDetail> {
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
                  text: "Take a photo",
                  size: 20,
                  color: AppColors.secondPrimaryColor,
                  fontW: FontWeight.w500,
                ),
              ],
            ),
            Gap(AppLayout.getHeight(20)),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.blue,
                    width: 1.0,
                  ),
                ),
              ),
              child: Text(
                "User ID: ${widget.userId}" ?? 'No Id',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            Gap(AppLayout.getHeight(40)),
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.blue,
                    width: 1.0,
                  ),
                ),
              ),
              child: Text(
                "Scan Qr: ${widget.resultScanQrCode}" ?? 'No result',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: widget.imageFileList!.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.9,
                      crossAxisSpacing: AppLayout.getWidth(10),
                      mainAxisSpacing: AppLayout.getHeight(10)
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return Stack(
                      children: [
                        Image.file(
                          File(widget.imageFileList![index].path),
                          fit: BoxFit.cover,
                        ),
                      ],
                    );
                  },
                ),

              ),
            ),

          ],
        ),
      ),
    );
  }
}
