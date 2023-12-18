import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:lost_and_find_app/data/api/notifications/notification_controller.dart';

import '../../data/api/item/claim_controller.dart';
import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/big_text.dart';

class MyListNotifications extends StatefulWidget {
  const MyListNotifications({super.key});

  @override
  State<MyListNotifications> createState() => _MyListNotificationsState();
}

class _MyListNotificationsState extends State<MyListNotifications> {
  bool _isMounted = false;

  List<dynamic> notificationList = [];
  final NotificationController notificationController = Get.put(NotificationController());

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    Future.delayed(Duration(seconds: 2), () async {
      notificationController.getNotificationListByUserId().then((result) {
        if (_isMounted) {
          setState(() {
            notificationList = result;
          });
        }
      }).whenComplete(() {
        if (_isMounted) {
          setState(() {
            if (notificationList.isEmpty) {
              _isMounted = false;
            }
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
          padding: const EdgeInsets.all(12.0),
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
                    text: "List Notifications",
                    size: 20,
                    color: AppColors.secondPrimaryColor,
                    fontW: FontWeight.w500,
                  ),
                ],
              ),
              if (notificationList.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: notificationList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final notiList = notificationList[index];

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
                          Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              notiList['title'],
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                          ),
                          Gap(AppLayout.getHeight(20)),
                          Container(
                          alignment: Alignment.bottomLeft,
                            child: Text(
                              notiList['content'],
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                          ),
                          Gap(AppLayout.getHeight(20)),
                          Container(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              notiList['createdDate'] != null
                                  ? '${DateFormat('dd-MM-yyyy -- hh:mm:ss').format(DateTime.parse(notiList['createdDate']))}'
                                  : 'No Date',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                          ),

                        ],
                      ),
                    );
                  })
              else if (notificationList.isEmpty && !_isMounted)
                SizedBox(
                  width: AppLayout.getScreenWidth(),
                  height: AppLayout.getScreenHeight()-200,
                  child: Center(
                    child: Text("You don't have any notifications"),
                  ),
                )
              else
                SizedBox(
                  width: AppLayout.getWidth(100),
                  height: AppLayout.getHeight(300),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
