import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

import '../../data/api/giveaway/giveaway_controller.dart';
import '../../data/api/notifications/notification_controller.dart';
import '../../test/time/time_widget.dart';
import '../../utils/app_assets.dart';
import '../../utils/app_constraints.dart';
import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/big_text.dart';

class GiveawayScreen extends StatefulWidget {
  const GiveawayScreen({super.key});

  @override
  State<GiveawayScreen> createState() => _GiveawayScreenState();
}

class _GiveawayScreenState extends State<GiveawayScreen> {
  bool _isMounted = false;
  bool loadingFinished = false;
  bool isGiveawayParticipate = false;
  late String uid = "";

  List<dynamic> giveawayList = [];
  final GiveawayController giveawayController = Get.put(GiveawayController());

  List<Map<String, String>> giveawayStatusList = [
    {'name': 'ONGOING'},
    {'name': 'REWARD_DISTRIBUTION_IN_PROGRESS'},
    {'name': 'CLOSED'},
  ];

  List<String> selectedGiveawayStatus = ['ONGOING'];

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

  Future<void> participateGiveaway(int giveawayId) async {
    try {
      await giveawayController.postParticipateByGiveawayId(giveawayId);
      setState(() {
        isGiveawayParticipate = true;
      });
    } catch (e) {
      print('Error participate Giveaway : $e');
    }
  }

  // Function to unclaim an item
  Future<void> unParticipateGiveaway(int giveawayId) async {
    try {
      await giveawayController.postParticipateByGiveawayId(giveawayId);
      setState(() {
        isGiveawayParticipate = false;
      });
    } catch (e) {
      print('Error unParticipate Giveaway : $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    Future.delayed(Duration(seconds: 1), () async {
      uid = await AppConstrants.getUid();
      giveawayController.getGiveawayStatusList().then((result) {
        if (_isMounted) {
          setState(() {
            giveawayList = result;

            if (giveawayList.isNotEmpty) {
              giveawayList.removeWhere((giveaway) => giveaway['giveawayStatus'] == 'NOT_STARTED');
              giveawayList.removeWhere((giveaway) => giveaway['giveawayStatus'] == 'DELETED');
              giveawayList.forEach((giveaway) {
                final participants = giveaway['giveawayParticipants'] as List<dynamic>;
                if (participants.isNotEmpty) {
                  final currentUser = participants.firstWhere(
                          (participant) =>
                      participant['user']['id'] == uid,
                      orElse: () => null);

                  if (currentUser != null) {
                    isGiveawayParticipate = currentUser['isActive'];
                  }
                }
              });
            }
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
    List<dynamic> filteredGiveawayList = giveawayList
        .where((giveaway) =>
    selectedGiveawayStatus.isEmpty ||
        selectedGiveawayStatus.contains(giveaway['giveawayStatus']))
        .toList();

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
              Gap(AppLayout.getHeight(25)),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: giveawayStatusList
                        .map((status) => GestureDetector(
                      onTap: () {
                        setState(() {
                          if (selectedGiveawayStatus.contains(status['name'])) {
                            selectedGiveawayStatus.remove(status['name']);
                          } else {
                            selectedGiveawayStatus.add(status['name']!);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: BigText(
                          text: status['name'] != null ? status['name'].toString() : 'No Status',
                          color: selectedGiveawayStatus.contains(status['name'])
                              ? AppColors
                              .primaryColor // Selected text color
                              : AppColors.secondPrimaryColor,
                          fontW: FontWeight.w500,
                        ),
                      ),
                    ))
                        .toList(),
                  ),
                ),
              ),
              if (loadingFinished! && giveawayList.isNotEmpty)
                   ListView.builder(
                  shrinkWrap: true,
                  reverse: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: filteredGiveawayList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final giveaway = filteredGiveawayList[index];
                    final winnerUser = giveaway['winnerUser'];

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
                          Gap(AppLayout.getHeight(30)),
                          giveaway['giveawayStatus'] == "CLOSED" ? Column(
                            children: [
                              Container(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  "Winner: ",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.only(
                                        left: AppLayout.getWidth(16),
                                        top: AppLayout.getHeight(8)),
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey[500],
                                      radius: 25,
                                      child: CircleAvatar(
                                        radius: 25,
                                        backgroundImage: NetworkImage(winnerUser['avatar']??"https://upload.wikimedia.org/wikipedia/commons/d/d1/Image_not_available.png"),
                                      ),
                                    ),
                                  ),
                                  Gap(AppLayout.getHeight(20)),
                                  Flexible(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          winnerUser.isNotEmpty
                                              ? winnerUser['fullName'] :
                                          'No Name', style: TextStyle(fontSize: 12),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Gap(AppLayout.getHeight(5)),
                                        Text(
                                          winnerUser.isNotEmpty
                                              ? winnerUser['email'] :
                                          'No Name', style: TextStyle(fontSize: 12),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                      ],
                                    ),
                                  ),

                                ],
                              ),

                            ],
                          ) : Container(),
                          giveaway['giveawayStatus'] == 'ONGOING' ? AppButton1(
                            boxColor: isGiveawayParticipate ? AppColors.primaryColor : AppColors.secondPrimaryColor,
                            textButton: isGiveawayParticipate ? "Participated" : "Participate",
                            onTap: () async {
                              if (isGiveawayParticipate) {
                                await unParticipateGiveaway(giveaway['id']);
                                final updatedGiveaway = await giveawayController.getGiveawayById(giveaway['id']);
                                setState(() {
                                  giveaway['participantsCount'] = updatedGiveaway['participantsCount'];
                                });
                              } else {
                                await participateGiveaway(giveaway['id']);
                                final updatedGiveaway = await giveawayController.getGiveawayById(giveaway['id']);
                                setState(() {
                                  giveaway['participantsCount'] = updatedGiveaway['participantsCount'];
                                });
                              }
                            },
                          ) : Container()
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

class AppButton1 extends StatelessWidget {
  final Color boxColor;
  final String textButton;
  final VoidCallback onTap;
  double height;
  double width;
  double topLeft;
  double topRight;
  double bottomLeft;
  double bottomRight;
  double fontSize;

  AppButton1(
      {Key? key,
        required this.boxColor,
        required this.textButton,
        required this.onTap,
        this.height = 0,
        this.width = 0,
        this.bottomRight = 0,
        this.topRight = 0,
        this.topLeft = 0,
        this.bottomLeft = 0,
        this.fontSize = 20})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
    color: boxColor,),
    child: InkWell(
        onTap: () {
          onTap();
        },
        child: Ink(
          width: AppLayout.getWidth(250),
          height: AppLayout.getHeight(50),
          decoration: BoxDecoration(
            color: boxColor,  // Use the provided boxColor
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
              textButton,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
