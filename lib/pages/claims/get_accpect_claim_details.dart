import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lost_and_find_app/data/api/item/item_controller.dart';
import 'package:lost_and_find_app/widgets/app_button.dart';

import '../../data/api/item/receipt_controller.dart';
import '../../data/api/user/user_controller.dart';
import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/big_text.dart';

class GetAccepctClaimDetail extends StatefulWidget {
  final String resultScanQrCode;
  final String userId;
  final XFile? imageFile;
  final String itemUserId;
  final int itemId;
  const GetAccepctClaimDetail({
    Key? key,
    required this.imageFile,
    required this.userId,
    required this.resultScanQrCode,
    required this.itemUserId,
    required this.itemId,

  }) : super(key: key);

  @override
  State<GetAccepctClaimDetail> createState() => _GetAccepctClaimDetailState();
}

class _GetAccepctClaimDetailState extends State<GetAccepctClaimDetail> {
  Map<String, dynamic> userList = {};
  Map<String, dynamic> userItemList = {};
  Map<String, dynamic> itemList = {};

  final UserController userController= Get.put(UserController());
  bool _isMounted = false;
  final ItemController itemController = Get.put(ItemController());

  Future<List<int>> compressImage(
      String imagePath, int targetWidth, int targetHeight, int quality) async {
    List<int> imageBytes = await File(imagePath).readAsBytes();
    img.Image image = img.decodeImage(Uint8List.fromList(imageBytes))!;
    img.Image resizedImage =
    img.copyResize(image, width: targetWidth, height: targetHeight);
    return img.encodeJpg(resizedImage, quality: quality);
  }

  Future<void> compressAndCreateReceipt() async {
    List<String> compressedImagePaths = [];

    // Convert XFile to List<XFile> for iteration
    List<XFile> imageFiles = [widget.imageFile!];

    for (var imageFile in imageFiles) {
      List<int> compressedImage = await compressImage(
          imageFile.path, 800, 600, 80); // Adjust parameters as needed
      String compressedImagePath =
      await saveToDisk(compressedImage, 'receipt_image_item ${widget.itemId}.jpg');
      compressedImagePaths.add(compressedImagePath);
    }
    await ReceiptController().createReceipt(widget.userId, widget.itemUserId, widget.itemId, widget.imageFile!.path);

    // Use compressedImagePaths as needed
    print(compressedImagePaths);
  }


  Future<String> saveToDisk(List<int> data, String fileName) async {
    final File file = File('${(await getTemporaryDirectory()).path}/$fileName');
    await file.writeAsBytes(data);
    return file.path;
  }

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    Future.delayed(Duration(seconds: 1), () async {
      await userController.getUserByUserId(widget.userId).then((result) {
        if (_isMounted) {
          setState(() {
            userList = result;
          });
        }
      });
      await userController.getUserByUserId(widget.itemUserId).then((result) {
        if (_isMounted) {
          setState(() {
            userItemList = result;
          });
        }
      });
      await itemController.getItemListById(widget.itemId).then((result) {
        if (_isMounted) {
          setState(() {
            itemList = result;
          });
        }
      });

    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: userList.isNotEmpty & userItemList.isNotEmpty & itemList.isNotEmpty ? Column(
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
                    text: "Information",
                    size: 20,
                    color: AppColors.secondPrimaryColor,
                    fontW: FontWeight.w500,
                  ),
                ],
              ),
              Gap(AppLayout.getHeight(20)),
              Text(
                "Receiver: ",
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Gap(AppLayout.getHeight(5)),
              Row(children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(userList['avatar'] ?? 'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg'),
                ),
                Gap(AppLayout.getWidth(10)),
                Column(
                  children: [
                    Text(
                      userList['fullName'] ?? '-',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Gap(AppLayout.getHeight(5)),

                    Text(
                      userList['email'] ?? '-',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                  ],
                ),


              ],),
              Gap(AppLayout.getHeight(40)),
              Text(
                "Sender: ",
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Gap(AppLayout.getHeight(5)),
              Row(children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(userItemList['avatar'] ?? 'https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg'),
                ),
                Gap(AppLayout.getWidth(10)),
                Column(
                  children: [
                    Text(
                      userItemList['fullName'] ?? '-',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Gap(AppLayout.getHeight(5)),
                    Text(
                      userItemList['email'] ?? '-',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                  ],
                ),


              ],),
              Gap(AppLayout.getHeight(40)),
              Text("Item: " + itemList['name'],
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Gap(AppLayout.getHeight(40)),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: widget.imageFile != null
                    ? Image.file(
                  File(widget.imageFile!.path),
                  fit: BoxFit.cover,
                )
                    : Container(), // Placeholder for when imageFile is null
              ),
              Gap(AppLayout.getHeight(50)),
              AppButton(boxColor: AppColors.primaryColor, textButton: "Done", onTap: () async {
                await compressAndCreateReceipt();
              })
            ],
          ) : Center(child: CircularProgressIndicator(),),
        ),
      ),
    );
  }
}
