import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:lost_and_find_app/data/api/report/report_controller.dart';

import '../../data/api/item/item_controller.dart';
import '../../data/api/message/Chat.dart';
import '../../data/api/message/chat_controller.dart';
import '../../utils/app_constraints.dart';
import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../utils/snackbar_utils.dart';
import '../../widgets/app_button.dart';
import '../../widgets/big_text.dart';
import '../../widgets/icon_and_text_widget.dart';
import '../../widgets/small_text.dart';
import '../message/chat_page.dart';
import '../report/create_report.dart';

class ItemDetailsReturn extends StatefulWidget {
  final int pageId;
  final String page;
  const ItemDetailsReturn({Key? key, required this.pageId, required this.page}) : super(key: key);

  @override
  State<ItemDetailsReturn> createState() => _ItemDetailsReturnState();
}

class _ItemDetailsReturnState extends State<ItemDetailsReturn> {

  late List<String> imageUrls = [
    // AppAssets.airpods,
    // AppAssets.airpods,
    // AppAssets.airpods,
    // AppAssets.airpods,
  ];
  final PageController _pageController = PageController();
  double currentPage = 0;

  bool _isMounted = false;
  late String uid = "";
  bool isItemClaimed = false;
  int itemId = 0;
  bool loadingAll = false;
  int? reportItemCount;
  int? reportTodayCount;
  List<dynamic> reportlist = [];

  Map<String, dynamic> itemlist = {};
  final ItemController itemController = Get.put(ItemController());
  final ReportController reportController = Get.put(ReportController());

  int countReportsToday(List<dynamic> reportItemList) {
    // Get today's date
    DateTime today = DateTime.now();

    // Format today's date in the same format as 'createdDate'
    String formattedToday = DateFormat("yyyy-MM-dd").format(today);

    // Initialize report count
    int reportCount = 0;

    // Iterate through reportItemList
    for (var report in reportItemList) {
      // Extract the date part from 'createdDate'
      String createdDate = report['createdDate'].split('T')[0];

      // Check if the 'createdDate' matches today's date
      if (createdDate == formattedToday) {
        reportCount++;
      }
    }

    return reportCount;
  }

  Future<void> _refreshData() async {
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page ?? 0;
      });
    });
    itemId = widget.pageId;
    _isMounted = true;
    Future.delayed(Duration(seconds: 1), () async {
      uid = await AppConstrants.getUid();
      reportTodayCount = await AppConstrants.getReportCount();
      await reportController.getReportByItemIdAndUserId(widget.pageId).then((result) {
        if (_isMounted) {
          setState(() {
            reportItemCount = result.length;
          });
        }
      });
      await itemController.getItemListById(widget.pageId).then((result) {
        if (_isMounted) {
          setState(() {
            itemlist = result;
            if (itemlist != null) {
              var itemMedias = itemlist['itemMedias'];

              if (itemMedias != null && itemMedias is List) {
                List mediaList = itemMedias;

                for (var media in mediaList) {
                  String imageUrl = media['media']['url'];
                  imageUrls.add(imageUrl);
                }
              }
              if (itemlist['foundDate'] != null) {
                String foundDate = itemlist['foundDate'];
                if (foundDate.contains('|')) {
                  List<String> dateParts = foundDate.split('|');
                  if (dateParts.length == 2) {
                    String date = dateParts[0].trim();
                    String slot = dateParts[1].trim();

                    // Check if the date format needs to be modified
                    if (date.contains(' ')) {
                      // If it contains time, remove the time part
                      date = date.split(' ')[0];
                    }

                    // Parse the original date
                    DateFormat originalDateFormat = DateFormat("yyyy-MM-dd");
                    DateTime originalDate = originalDateFormat.parse(date);

                    // Format the date in the desired format
                    DateFormat desiredDateFormat = DateFormat("dd-MM-yyyy");
                    String formattedDate = desiredDateFormat.format(originalDate);

                    // Update the foundDate in the itemlist
                    itemlist['foundDate'] = '$formattedDate $slot';
                  }
                }
              }
            }
          });
        }
      });
      setState(() {
        loadingAll = true;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page ?? 0;
      });
    });
    itemId = widget.pageId;
    _isMounted = true;
    Future.delayed(Duration(seconds: 1), () async {
      uid = await AppConstrants.getUid();
      await reportController.getReportById().then((result) {
        if (_isMounted) {
          setState(() {
            reportlist = result;
            reportTodayCount = countReportsToday(reportlist);
            print("reportTodayCount: $reportTodayCount");
          });
        }
      });
      await reportController.getReportByItemIdAndUserId(widget.pageId).then((result) {
        if (_isMounted) {
          setState(() {
            reportItemCount = result.length;
            print("reportItemCount: $reportItemCount");
          });
        }
      });
      await itemController.getItemListById(widget.pageId).then((result) {
        if (_isMounted) {
          setState(() {
            itemlist = result;
            if (itemlist != null) {
              var itemMedias = itemlist['itemMedias'];

              if (itemMedias != null && itemMedias is List) {
                List mediaList = itemMedias;

                for (var media in mediaList) {
                  String imageUrl = media['media']['url'];
                  imageUrls.add(imageUrl);
                }
              }
              if (itemlist['foundDate'] != null) {
                String foundDate = itemlist['foundDate'];
                if (foundDate.contains('|')) {
                  List<String> dateParts = foundDate.split('|');
                  if (dateParts.length == 2) {
                    String date = dateParts[0].trim();
                    String slot = dateParts[1].trim();

                    // Check if the date format needs to be modified
                    if (date.contains(' ')) {
                      // If it contains time, remove the time part
                      date = date.split(' ')[0];
                    }

                    // Parse the original date
                    DateFormat originalDateFormat = DateFormat("yyyy-MM-dd");
                    DateTime originalDate = originalDateFormat.parse(date);

                    // Format the date in the desired format
                    DateFormat desiredDateFormat = DateFormat("dd-MM-yyyy");
                    String formattedDate = desiredDateFormat.format(originalDate);

                    // Update the foundDate in the itemlist
                    itemlist['foundDate'] = '$formattedDate $slot';
                  }
                }
              }
            }
          });
        }
      });
      setState(() {
        loadingAll = true;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: loadingAll ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // Align children to the left
              children: [
                Gap(AppLayout.getHeight(30)),
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
                          text: "Item Detail",
                          size: 20,
                          color: AppColors.secondPrimaryColor,
                          fontW: FontWeight.w500,
                        ),
                      ],
                    ),
                  ],
                ),
                Gap(AppLayout.getHeight(20)),

                Container(
                  margin: EdgeInsets.only(left: 20),
                  height: AppLayout.getHeight(350),
                  width: AppLayout.getWidth(350),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: imageUrls.length,
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(imageUrls[index]??"https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg",fit: BoxFit.fill,));
                      // child: Image.network(imageUrls[index],fit: BoxFit.fill,));               );
                    },
                  ),
                ),
                Center(
                  child: DotsIndicator(
                    dotsCount: imageUrls.isEmpty ? 1 : imageUrls.length,
                    position: currentPage,
                    decorator: const DotsDecorator(
                      size: Size.square(10.0),
                      activeSize: Size(20.0, 10.0),
                      activeColor: Colors.blue,
                      spacing: EdgeInsets.all(3.0),
                    ),
                  ),
                ),
                Gap(AppLayout.getHeight(20)),
                Padding(
                  padding: EdgeInsets.only(
                      left: AppLayout.getWidth(16), top: AppLayout.getHeight(16)),
                  child: Text(
                    itemlist.isNotEmpty
                        ? itemlist['name']
                        : 'No Name',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),

                ),
                Gap(AppLayout.getHeight(10)),

                Container(
                    padding: EdgeInsets.only(
                        left: AppLayout.getWidth(16),
                        top: AppLayout.getHeight(8)),
                    child: IconAndTextWidget(
                        icon: Icons.timer_sharp,
                        text: itemlist['foundDate'],
                        iconColor: Colors.grey)),
                Gap(AppLayout.getHeight(5)),

                //category
                Container(
                    padding: EdgeInsets.only(
                        left: AppLayout.getWidth(16),
                        top: AppLayout.getHeight(8)),
                    child: IconAndTextWidget(
                        icon: Icons.category,
                        text: itemlist.isNotEmpty
                            ? itemlist['categoryName']
                            : 'No Location',
                        iconColor: Colors.black)),
                Gap(AppLayout.getHeight(5)),

                //location
                Container(
                    padding: EdgeInsets.only(
                        left: AppLayout.getWidth(16),
                        top: AppLayout.getHeight(8)),
                    child: IconAndTextWidget(
                        icon: Icons.location_on,
                        text: itemlist.isNotEmpty
                            ? itemlist['locationName']
                            : 'No Location',
                        iconColor: Colors.black)),

                //description
                Gap(AppLayout.getHeight(10)),
                Container(
                    padding: EdgeInsets.only(
                        left: AppLayout.getWidth(18),
                        top: AppLayout.getHeight(8)),
                    child: SmallText(
                      text: itemlist.isNotEmpty
                          ? itemlist['description']
                          : 'No Description',
                      size: 15,
                    )),
                //profile user
                Gap(AppLayout.getHeight(10)),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: AppLayout.getWidth(16),
                          top: AppLayout.getHeight(8)),
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[500],
                        radius: 50,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(itemlist['user']['avatar']??"https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg"),
                        ),
                      ),
                    ),
                    Gap(AppLayout.getHeight(50)),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                        },

                        child: Text(
                          itemlist.isNotEmpty
                              ? itemlist['user']['fullName'] :
                          'No Name', style: TextStyle(fontSize: 20),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),

                      ),
                    )
                  ],
                ),
                Gap(AppLayout.getHeight(40)),
                itemlist['user']['id'] == uid ? Container() : Center(
                    child: AppButton(boxColor: AppColors.secondPrimaryColor, textButton: "Send Message", onTap: () async {
                      String otherUserId = itemlist['user']['id'];

                      await ChatController().createUserChats(uid, otherUserId);
                      // Get.toNamed(RouteHelper.getInitial(2));
                      String chatId = uid.compareTo(otherUserId) > 0 ? uid + otherUserId : otherUserId + uid;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            chat: Chat(
                              uid: otherUserId,
                              name: itemlist['user']['fullName'] ?? 'No Name',
                              image: itemlist['user']['avatar'] ?? '',
                              lastMessage: '', // You may want to pass initial message if needed
                              time: '',
                              chatId:chatId, // You may want to pass the chatId if needed
                              formattedDate: '',
                              otherId: otherUserId,
                              date: DateTime.now(),
                            ),
                          ),
                        ),
                      );
/*                      BuildContext contextReference = context;

                      // Find the chatId based on user IDs
                      String myUid = await AppConstrants.getUid(); // Get current user ID
                      String chatId = myUid.compareTo(otherUserId) > 0 ? myUid + otherUserId : otherUserId + myUid;

                      // Navigate to ChatPage with the relevant chat information
                      Navigator.push(
                        contextReference, // Use the context reference
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            chat: Chat(
                              chatId: chatId,
                              uid: myUid,
                              otherId: otherUserId,
                            ),
                          ),
                        ),
                      );*/
                    })),
                Gap(AppLayout.getHeight(20)),
                itemlist['user']['id'] == uid ? Container() : Center(
                    child: AppButton(boxColor: AppColors.secondPrimaryColor, textButton: "Send Report", onTap: () async {
                      if(reportTodayCount! < 3) {
                        if (reportItemCount! < 3) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CreateReport(itemId: itemId,),
                            ),
                          );

                        } else {
                          SnackbarUtils().showError(title: "Report", message: "You have already created 3 reports for this item");
                        }
                      } else {
                        SnackbarUtils().showError(title: "Report", message: "You can only created 3 reports per day!");
                      }
                    })),
              ],
            )
                : SizedBox(
              width: AppLayout.getScreenWidth(),
              height: AppLayout.getScreenHeight()-200,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
