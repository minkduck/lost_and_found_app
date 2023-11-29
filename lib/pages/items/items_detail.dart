import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lost_and_find_app/data/api/item/receipt_controller.dart';
import 'package:lost_and_find_app/pages/account/another_profile_user.dart';
import 'package:lost_and_find_app/pages/claims/claim_items.dart';
import 'package:lost_and_find_app/pages/items/edit_item.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/widgets/app_button.dart';
import 'package:lost_and_find_app/widgets/icon_and_text_widget.dart';
import 'package:lost_and_find_app/widgets/small_text.dart';
import 'package:lost_and_find_app/widgets/status_widget.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:get/get.dart';

import '../../data/api/item/claim_controller.dart';
import '../../data/api/item/item_controller.dart';
import '../../data/api/user/user_controller.dart';
import '../../routes/route_helper.dart';
import '../../test/time/time_widget.dart';
import '../../utils/app_constraints.dart';
import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/big_text.dart';

class ItemsDetails extends StatefulWidget {
  final int pageId;
  final String page;
  const ItemsDetails({Key? key, required this.pageId, required this.page}) : super(key: key);

  @override
  State<ItemsDetails> createState() => _ItemsDetailsState();
}


class _ItemsDetailsState extends State<ItemsDetails> {

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

  Map<String, dynamic> itemlist = {};
  final ItemController itemController = Get.put(ItemController());
  final ClaimController claimController = Get.put(ClaimController());
  final ReceiptController receiptController = Get.put(ReceiptController());
  final UserController userController = Get.put(UserController());
  List<Map<String, dynamic>> userReceiptList = [];

  List<dynamic> recepitList = [];
  Future<void> claimItem() async {
    try {
      await claimController.postClaimByItemId(itemId);
      setState(() {
        isItemClaimed = true;
      });
    } catch (e) {
      print('Error claiming item: $e');
    }
  }

  // Function to unclaim an item
  Future<void> unclaimItem() async {
    try {
      await claimController.postUnClaimByItemId(itemId);
      setState(() {
        isItemClaimed = false;
      });
    } catch (e) {
      print('Error unclaiming item: $e');
    }
  }
  Future<void> _refreshData() async {
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
              isItemClaimed = itemlist['itemClaims']['claimStatus']  ?? false;

            }
          }
        });
      }
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
      // uid = "FLtIEJvuMgfg58u4sXhzxPn9qr73";
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
              if (itemlist['itemClaims'] != null && itemlist['itemClaims'] is List) {
                var claimsList = itemlist['itemClaims'];
                var matchingClaim = claimsList.firstWhere(
                      (claim) => claim['userId'] == uid,
                  orElse: () => null,
                );

                if (matchingClaim != null) {
                  isItemClaimed = matchingClaim['claimStatus'] == true ? true : false;
                }
              }
            }
          });
        }
      });
      await receiptController.getReceiptByItemId(widget.pageId).then((result) async {
        if (_isMounted) {
            recepitList = result;
            for (var receipt in recepitList) {
              final userId = receipt['receiverId'];
              final userMap = await userController.getUserByUserId(userId);
              final Map<String, dynamic> claimInfo = {
                'receipt': receipt,
                'user': userMap != null ? userMap : null, // Check if user is null
              };
              print("claimInfo:" + claimInfo.toString());
              setState(() {
                userReceiptList.add(claimInfo);
              });
            }
        }

      });
    });


  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: itemlist.isNotEmpty ? Column(
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
                          text: "Home",
                          size: 20,
                          color: AppColors.secondPrimaryColor,
                          fontW: FontWeight.w500,
                        ),
                      ],
                    ),
                    itemlist['user']['id'] == uid ? itemlist['itemStatus'] != 'RETURNED' ? Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditItem(
                                  itemId: itemId,
                                  initialCategory: itemlist['categoryName'], // Pass the initial data
                                  initialTitle: itemlist['name'], // Pass the initial data
                                  initialDescription: itemlist['description'], // Pass the initial data
                                  initialLocation: itemlist['locationName'],
                                  status: itemlist['itemStatus'],
                                ),
                              ),
                            );
                          },
                          child: Text("Edit", style: TextStyle(color: AppColors.primaryColor, fontSize: 20),),
                        ),
                        Gap(AppLayout.getWidth(15)),
                        GestureDetector(
                          onTap: () async {
                            await itemController.deleteItemById(itemId);
                          },
                          child: Text("Delete", style: TextStyle(color: Colors.redAccent, fontSize: 20),),
                        ),

                      ],
                    ) : Container() : Container()
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: AppLayout.getWidth(30), top: AppLayout.getHeight(10)),
                  child: Text('Item Detail', style: Theme.of(context).textTheme.displayMedium,),
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
                // Container(
                //     padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
                //     child: StatusWidget(text: "Found", color: Colors.grey)),
                Padding(
                  padding: EdgeInsets.only(
                      left: AppLayout.getWidth(16), top: AppLayout.getHeight(16)),
                  child: Text(
                    itemlist.isNotEmpty
                        ? itemlist['name']
                        : 'No Name', // Provide a default message if item is not found
                    style: Theme.of(context).textTheme.labelMedium,
                  ),

                ),
                // time
                Container(
                    padding: EdgeInsets.only(
                        left: AppLayout.getWidth(16),
                        top: AppLayout.getHeight(8)),
                    child: IconAndTextWidget(
                        icon: Icons.timer_sharp,
                        text: itemlist['createdDate'] != null
                            ? '${TimeAgoWidget.formatTimeAgo(DateTime.parse(itemlist['createdDate']))}  --  ${DateFormat('dd-MM-yyyy').format(DateTime.parse(itemlist['createdDate']))}'
                            : 'No Date',
                        iconColor: Colors.grey)),
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
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) => AnotherProfileUser( userId: itemlist['user']['id'],)));
                      },
                      child: Text(
                        itemlist.isNotEmpty
                          ? itemlist['user']['fullName'] :
                          'No Name', style: TextStyle(fontSize: 20),),
                    )
                  ],
                ),
                Gap(AppLayout.getHeight(40)),
                Center(
                    child: AppButton(boxColor: AppColors.secondPrimaryColor, textButton: "Send Message", onTap: () {})),
                Gap(AppLayout.getHeight(20)),

                itemlist['itemStatus'] != 'RETURNED' ? itemlist['user']['id'] == uid ? Center(
                    child: AppButton(
                        boxColor: AppColors.secondPrimaryColor,
                        textButton: "List Claim",
                        onTap: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => ClaimItems(pageId: widget.pageId, page: "Claim user",itemUserId: itemlist['user']['id'],)));
                        }))
                : Center(
                    child: AppButton(
                      boxColor: isItemClaimed ? AppColors.primaryColor : AppColors.secondPrimaryColor,
                      textButton: isItemClaimed ? "Claimed" : "Claim",
                      onTap: isItemClaimed ? unclaimItem : claimItem,)) : Column(
                        children: [
                          Text('Receiver: ',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          Padding(
                            padding:  EdgeInsets.only(left: 8.0),
                            child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: userReceiptList.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final userReceiptInfo = userReceiptList[index];
                                  final claim = userReceiptInfo['claim'];
                                  final user = userReceiptInfo['user'];
                                  return Row(
                                    children: [
                                      Container(
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage(user['avatar']),
                                        ),
                                      ),
                                      Gap(AppLayout.getWidth(10)),
                                      Column(
                                        children: [
                                          Text(
                                            user['fullName'] ?? '-',
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),
                                          Gap(AppLayout.getHeight(5)),
                                          Text(
                                            user['email'] ?? '-',
                                            style: Theme.of(context).textTheme.titleMedium,
                                          ),

                                        ],
                                      ),

                                    ],
                                  );
                                }

                            ),
                          )
                        ],
                      ),
              ],
            )
                : SizedBox(
              width: AppLayout.getWidth(100),
              height: AppLayout.getHeight(300),
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
