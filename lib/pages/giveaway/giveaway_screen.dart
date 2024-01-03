import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import '../../data/api/giveaway/giveaway_controller.dart';
import '../../data/api/notifications/notification_controller.dart';
import '../../test/time/time_widget.dart';
import '../../utils/app_assets.dart';
import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/big_text.dart';

class GiveawayScreen extends StatefulWidget {
  const GiveawayScreen({super.key});

  @override
  State<GiveawayScreen> createState() => _GiveawayScreenState();
}

class _GiveawayScreenState extends State<GiveawayScreen> {
  bool _isMounted = false;
  bool loadingFinished = false;

  List<dynamic> giveawayList = [];
  final GiveawayController giveawayController = Get.put(GiveawayController());

  String? getUrlFromItem(Map<String, dynamic> item) {
    if (item.containsKey('itemMedias')) {
      final itemMedias = item['itemMedias'] as List;
      if (itemMedias.isNotEmpty) {
        final media = itemMedias[0] as Map<String, dynamic>;
        if (media.containsKey('media')) {
          final mediaData = media['media'] as Map<String, dynamic>;
          if (mediaData.containsKey('url')) {
            return mediaData['url'] as String;
          }
        }
      }
    }
    return "https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg";
  }

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    Future.delayed(Duration(seconds: 1), () async {
      giveawayController.getGiveawayList().then((result) {
        if (_isMounted) {
          setState(() {
            giveawayList = result;
          });
        }
      });
      setState(() {
        loadingFinished = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:  Column(
            children: [
              Gap(AppLayout.getHeight(50)),
              Row(
                children: [
                  BigText(
                    text: "Giveaway",
                    size: 20,
                    color: AppColors.secondPrimaryColor,
                    fontW: FontWeight.w500,
                  ),
                ],
              ),
              if (loadingFinished! && giveawayList.isNotEmpty)
                   ListView.builder(
                  shrinkWrap: true,
                  reverse: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: giveawayList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final giveaway = giveawayList[index];

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
                              "Giveaway ${giveaway['item']['name']}",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium,
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              giveaway['createdDate'] != null
                                  ? 'Posted date: ${DateFormat('dd-MM-yyyy').format(DateTime.parse(giveaway['createdDate']))}'
                                  : 'No Date',
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey),
                            ),
                          ),
                          Gap(AppLayout.getHeight(10)),
                          Container(
                            height:
                            MediaQuery.of(context).size.height *
                                0.25,
                            // Set a fixed height or use any other value
                            child: ListView.builder(
                              padding: EdgeInsets.zero, // Add this line to set zero padding
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: giveaway['item']['itemMedias']
                                  .length,
                              itemBuilder: (context, indexs) {
                                return Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(
                                      left: AppLayout.getWidth(20)),
                                  height: AppLayout.getHeight(151),
                                  width: AppLayout.getWidth(180),
                                  child: Image.network(
                                      giveaway['item']['itemMedias']
                                      [indexs]['media']['url'] ?? Container(),
                                      fit: BoxFit.fill),
                                );
                              },
                            ),
                          ),
                          Gap(AppLayout.getHeight(10)),

                          Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              giveaway['item']['description'],
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                          ),
                          Gap(AppLayout.getHeight(20)),
                          Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              giveaway['startAt'] != null
                                  ? "Start Date: ${DateFormat('dd-MM-yyyy - HH:mm a').format(DateTime.parse(giveaway['startAt']))}"
                                  : 'No Date',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                          ),

                          Gap(AppLayout.getHeight(20)),
                          Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              giveaway['startAt'] != null
                                  ? 'End Date: ${DateFormat('dd-MM-yyyy - HH:mm a').format(DateTime.parse(giveaway['endAt']))}'
                                  : 'No Date',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                          ),

                          Gap(AppLayout.getHeight(20)),
                          Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Status: ${giveaway['giveawayStatus']}",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                          ),

                          Gap(AppLayout.getHeight(20)),
                          Container(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              "Participation: ${giveaway['participantsCount']}",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                          ),
                          Gap(AppLayout.getHeight(20)),

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColors.primaryColor,  // Set color to AppColors.primaryColor
                            ),
                            child: InkWell(
                              onTap: () {
                              },
                              child: Ink(
                                width: AppLayout.getWidth(250),
                                height: AppLayout.getHeight(50),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,  // Use the provided boxColor
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(AppLayout.getHeight(15)) ,
                                    topRight:  Radius.circular(AppLayout.getHeight(15)) ,
                                    bottomLeft: Radius.circular(AppLayout.getHeight(15)) ,
                                    bottomRight: Radius.circular(AppLayout.getHeight(15)) ,
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
                                  child: Text(
                                    "Join",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  })
              else if (loadingFinished! && giveawayList.isEmpty)
                SizedBox(
                  width: AppLayout.getScreenWidth(),
                  height: AppLayout.getScreenHeight()-200,
                  child: Center(
                    child: Text("It doesn't have any giveaway"),
                  ),
                )
                else
              SizedBox(
                width: AppLayout.getScreenWidth(),
                height: AppLayout.getScreenHeight()-200,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),

            ],
          )
        ),
      ),
    );
  }
}
