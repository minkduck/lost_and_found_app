import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:lost_and_find_app/data/api/item/item_controller.dart';
import 'package:lost_and_find_app/data/api/item/receipt_controller.dart';

import '../../data/api/user/user_controller.dart';
import '../../test/time/time_widget.dart';
import '../../utils/app_constraints.dart';
import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/big_text.dart';


class MyReceipt extends StatefulWidget {
  const MyReceipt({super.key});

  @override
  State<MyReceipt> createState() => _MyReceiptState();
}

class _MyReceiptState extends State<MyReceipt> {
  List<dynamic> receiptReceiverList = [];
  List<dynamic> receiptSenderList = [];
  bool loadingReceiptReceiverList = false;
  bool loadingReceiptSenderList = false;

  late String uid = "";
  final ReceiptController receiptController = Get.put(ReceiptController());
  final UserController userController= Get.put(UserController());
  final ItemController itemController= Get.put(ItemController());
  bool _isMounted = false;
  bool receiverSelected = true;
  bool senderSelected = false;
  
  Color _getStatusColor(String? status) {
    switch (status) {
      case 'RETURN_USER_TO_USER':
        return AppColors.primaryColor;
      case 'RETURNED':
        return AppColors.secondPrimaryColor;
      case 'CLOSED':
        return Colors.red;
      default:
        return Colors.white; // Default color, you can change it to your preference
    }
  }


  @override
  void initState() {
    super.initState();
    _isMounted = true;
    loadingReceiptReceiverList = true;
    loadingReceiptSenderList = true;

    Future.delayed(Duration(seconds: 1), () async {
      uid = await AppConstrants.getUid();

      var senderResult = await receiptController.getReceiptBySenderId(uid);
      var receiverResult = await receiptController.getReceiptByReceiverId(uid);

      if (_isMounted) {
        setState(() {
          processReceipt(senderResult, true);
          processReceipt(receiverResult, false);
        });
      }

    });
  }

  void processReceipt(List<dynamic> result, bool isSender) async {
    final userReceipt = result as List<dynamic>;

    for (var receipt in userReceipt) {
      final receiverId = receipt['receiverId'];
      final senderId = receipt['senderId'];
      final itemId = receipt['itemId'];
      final receiver = await userController.getUserByUserId(receiverId);
      final sender = await userController.getUserByUserId(senderId);
      final item = await itemController.getItemListById(itemId);

      final Map<String, dynamic> receiptInfo = {
        'receipt': receipt,
        'receiver': receiver != null ? receiver : null,
        'sender': sender != null ? sender : null,
        'item': item != null ? item : null,
      };

      print(isSender ? "receiptSenderInfo:" : "receiptReceiverInfo:" + receiptInfo.toString());

      setState(() {
        if (isSender) {
          receiptSenderList.add(receiptInfo);
          loadingReceiptSenderList = false;
        } else {
          receiptReceiverList.add(receiptInfo);
          loadingReceiptReceiverList = false;
        }
      });
    }
  }


  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Gap(AppLayout.getHeight(70)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                      text: "List Receipt",
                      size: 20,
                      color: AppColors.secondPrimaryColor,
                      fontW: FontWeight.w500,
                    ),
                  ],
                ),
              ],
            ),
            Gap(AppLayout.getHeight(30)),
            Gap(AppLayout.getHeight(15)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AppButton(
                    boxColor: receiverSelected
                        ? AppColors.primaryColor
                        : AppColors.secondPrimaryColor,
                    textButton: "Items You Receive",
                    width: AppLayout.getWidth(170),
                    height: AppLayout.getHeight(35),
                    fontSize: 15,
                    onTap: () {
                      setState(() {
                        receiverSelected = true;
                        senderSelected = false;
                      });
                    }),
                AppButton(
                    boxColor: senderSelected
                        ? AppColors.primaryColor
                        : AppColors.secondPrimaryColor,
                    textButton: "Items You Send",
                    fontSize: 15,
                    width: AppLayout.getWidth(170),
                    height: AppLayout.getHeight(35),
                    onTap: () {
                      setState(() {
                        receiverSelected = false;
                        senderSelected = true;
                      });
                    })
              ],
            ),
            receiverSelected ?             loadingReceiptReceiverList
                ? Container(height: 200,width: 200,child: Center(child: CircularProgressIndicator()))
                : receiptReceiverList.isNotEmpty
                ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: receiptReceiverList.length,
                itemBuilder: (BuildContext context, int index) {
                  final receiverList = receiptReceiverList[index];
                  final receipt = receiverList['receipt'];
                  final receiver = receiverList['receiver'];
                  final sender = receiverList['sender'];
                  final item = receiverList['item'];

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).cardColor,
                    ),
                    margin: EdgeInsets.only(
                        bottom: AppLayout.getHeight(20)),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Receiver: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                            Gap(AppLayout.getWidth(5)),
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(
                                  receiver['avatar']!),
                            ),
                            Gap(AppLayout.getHeight(15)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  receiver['fullName'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                                Gap(AppLayout.getHeight(5)),
                                Text(
                                  receiver['email'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),

                              ],
                            )
                          ],
                        ),
                        Gap(AppLayout.getHeight(20)),
                        Row(
                          children: [
                            Text(
                              'Sender: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                            Gap(AppLayout.getWidth(5)),
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(
                                  sender['avatar']!),
                            ),
                            Gap(AppLayout.getHeight(15)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sender['fullName'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                                Gap(AppLayout.getHeight(5)),
                                Text(
                                  sender['email'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),

                              ],
                            )
                          ],
                        ),
                        Gap(AppLayout.getHeight(20)),
                        Row(
                          children: [
                            Text(
                              'Item: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                            Gap(AppLayout.getWidth(5)),
                            Text(
                              item['name'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),

                          ],
                        ),
                        Gap(AppLayout.getHeight(10)),
                        Row(
                          children: [
                            Text(
                              'Image: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                            Gap(AppLayout.getWidth(10)),
                            Container(
                              height: 200,
                              width: 225,
                              child: Image.network(
                                receipt['media']['url'],
                                fit: BoxFit.fill,
                              ),
                            ),

                          ],
                        ),
                        Gap(AppLayout.getHeight(10)),
                        Row(
                          children: [
                            Text(
                              'Create Date: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                            Gap(AppLayout.getWidth(5)),
                            Text(
                              receipt['createdDate'] != null
                                  ? '${DateFormat('dd-MM-yyyy -- hh:mm:ss').format(DateTime.parse(receipt['createdDate']))}'
                                  : 'No Date',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),

                          ],
                        ),
                        Gap(AppLayout.getHeight(10)),
                        Row(
                          children: [
                            Text(
                              'Receipt Type: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                            Gap(AppLayout.getWidth(5)),
                            Text(
                              receipt['receiptType'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall?.copyWith(color: _getStatusColor(receipt['receiptType'])),
                            ),

                          ],
                        ),

                      ],
                    ),
                  );
                })
                : Container(height: 200,width: 200,child: Center(child: Text(''),)) :             loadingReceiptSenderList
                ? Container(height: 200,width: 200,child: Center(child: CircularProgressIndicator()))
                : receiptSenderList.isNotEmpty
                ? ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: receiptSenderList.length,
                itemBuilder: (BuildContext context, int index) {
                  final senderList = receiptSenderList[index];
                  final receipt = senderList['receipt'];
                  final receiver = senderList['receiver'];
                  final sender = senderList['sender'];
                  final item = senderList['item'];

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).cardColor,
                    ),
                    margin: EdgeInsets.only(
                        bottom: AppLayout.getHeight(20)),
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              'Receiver: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                            Gap(AppLayout.getWidth(5)),
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(
                                  receiver['avatar']!),
                            ),
                            Gap(AppLayout.getHeight(15)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  receiver['fullName'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                                Gap(AppLayout.getHeight(5)),
                                Text(
                                  receiver['email'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),

                              ],
                            )
                          ],
                        ),
                        Gap(AppLayout.getHeight(20)),
                        Row(
                          children: [
                            Text(
                              'Sender: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                            Gap(AppLayout.getWidth(5)),
                            CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(
                                  sender['avatar']!),
                            ),
                            Gap(AppLayout.getHeight(15)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sender['fullName'],
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                                Gap(AppLayout.getHeight(5)),
                                Text(
                                  sender['email'],
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),

                              ],
                            )
                          ],
                        ),
                        Gap(AppLayout.getHeight(20)),
                        Row(
                          children: [
                            Text(
                              'Item: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                            Gap(AppLayout.getWidth(5)),
                            Text(
                              item['name'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),

                          ],
                        ),
                        Gap(AppLayout.getHeight(10)),
                        Row(
                          children: [
                            Text(
                              'Image: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                            Gap(AppLayout.getWidth(10)),
                            Container(
                              height: 200,
                              width: 225,
                              child: Image.network(
                                receipt['media']['url'],
                                fit: BoxFit.fill,
                              ),
                            ),

                          ],
                        ),
                        Gap(AppLayout.getHeight(10)),
                        Row(
                          children: [
                            Text(
                              'Create Date: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                            Gap(AppLayout.getWidth(5)),
                            Text(
                              receipt['createdDate'] != null
                                  ? '${DateFormat('dd-MM-yyyy -- hh:mm:ss').format(DateTime.parse(receipt['createdDate']))}'
                                  : 'No Date',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),

                          ],
                        ),
                        Gap(AppLayout.getHeight(10)),
                        Row(
                          children: [
                            Text(
                              'Receipt Type: ',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                            Gap(AppLayout.getWidth(5)),
                            Text(
                              receipt['receiptType'],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall?.copyWith(color: _getStatusColor(receipt['receiptType'])),
                            ),

                          ],
                        ),

                      ],
                    ),
                  );
                })
                : Container(height: 200,width: 200,child: Center(child: Text(''),)),

          ],
        ),
      ),
    );
  }
}
