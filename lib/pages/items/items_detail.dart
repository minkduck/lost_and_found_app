import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lost_and_find_app/data/api/item/receipt_controller.dart';
import 'package:lost_and_find_app/pages/account/another_profile_user.dart';
import 'package:lost_and_find_app/pages/claims/claim_items.dart';
import 'package:lost_and_find_app/pages/items/edit_item.dart';
import 'package:lost_and_find_app/pages/message/chat_page.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/widgets/app_button.dart';
import 'package:lost_and_find_app/widgets/icon_and_text_widget.dart';
import 'package:lost_and_find_app/widgets/small_text.dart';
import 'package:lost_and_find_app/widgets/status_widget.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/api/item/claim_controller.dart';
import '../../data/api/item/item_controller.dart';
import '../../data/api/message/Chat.dart';
import '../../data/api/message/chat_controller.dart';
import '../../data/api/user/user_controller.dart';
import '../../routes/route_helper.dart';
import '../../test/time/time_widget.dart';
import '../../utils/app_constraints.dart';
import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../utils/snackbar_utils.dart';
import '../../widgets/big_text.dart';
import '../../widgets/zoomable_image.dart';

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
  String? isStatusClaim;
  int itemId = 0;
  bool loadingAll = false;
  late String verifyStatus = "";
  bool isDeleteItem = false;
  int? claimItemCount;
  List<dynamic> claimItemList = [];

  Map<String, dynamic> itemlist = {};
  final ItemController itemController = Get.put(ItemController());
  final ClaimController claimController = Get.put(ClaimController());
  final ReceiptController receiptController = Get.put(ReceiptController());
  final UserController userController = Get.put(UserController());
  List<Map<String, dynamic>> userReceiptList = [];

  List<dynamic> recepitList = [];
  Future<void> claimItem() async {
    try {
      claimItemList = await claimController.getItemClaimByUidList();
      print("claimItemList: " + claimItemList.toString());

      // Filter the claimItemList to include only items with claimStatus 'PENDING'
      List filteredClaimItemList = claimItemList
          .where((claimItem) =>
      claimItem['itemClaims'] != null &&
          claimItem['itemClaims'][0]['claimStatus'] == 'PENDING')
          .toList();

      claimItemCount = filteredClaimItemList.length;

      print("claimItemCount: " + claimItemCount.toString());
      if (claimItemCount! < 5) {
        await claimController.postClaimByItemId(itemId);
        setState(() {
          isItemClaimed = true;
        });
      } else {
        SnackbarUtils().showError(
          title: "Claim",
          message: "You can only have 5 active Claims at a time! Unclaim some to proceed",
        );
      }
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

  Future<void> bookmarkItem(int itemId) async {
    try {
      await itemController.postBookmarkItemByItemId(itemId);

      // Manually update the bookmark status based on the isBookMarkActive field
      setState(() {
        itemlist['isBookMarkActive'] = !(itemlist['isBookMarkActive'] ?? false);
      });
    } catch (e) {
      print('Error bookmarking item: $e');
    }
  }

  Future<void> loadBookmarkedItems(int itemId) async {
    try {
      // Call the API to get bookmarked items for the given itemId
      final bookmarkedItems = await itemController.getBookmarkedItems(itemId);

      if (_isMounted) {
        setState(() {
          // Update the isBookMarkActive field for the specific item
          if (itemlist.containsKey('id') && itemlist['id'] == itemId) {
            itemlist['isBookMarkActive'] =
                bookmarkedItems['itemId'] == itemId && bookmarkedItems['isActive'];
          }
        });
      }
    } catch (e) {
      print('Error loading bookmarked items for item $itemId: $e');
      // Handle the error gracefully, e.g., set isBookMarkActive to false or log the error.
    }
  }

  Future<void> toggleItemStatus(int itemId, Future<void> Function(int) action) async {
    try {
      await action(itemId);

      // Manually update the item status based on the isFlagActive field
      setState(() {
        itemlist['isFlagActive'] = !(itemlist['isFlagActive'] ?? false);
      });
    } catch (e) {
      print('Error toggling item status: $e');
    }
  }

  Future<void> flagItem(int itemId, String reason) async {
    await toggleItemStatus(itemId, (int id) => itemController.postFlagItemByItemId(id, reason));
  }

  Future<void> loadFlagItems(int itemId) async {
    final flagItems = await itemController.getFlagItems(itemId);
    if (_isMounted) {
      setState(() {
        final itemToUpdate = itemlist;
        if (itemToUpdate != null) {
          itemToUpdate['isFlagActive'] = flagItems['itemId'] == itemId && flagItems['isActive'];
        }
      });
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'ACTIVE':
        return AppColors.primaryColor;
      case 'RETURNED':
        return AppColors.secondPrimaryColor;
      case 'CLOSED':
        return Colors.red;
      default:
        return Colors.grey; // Default color, you can change it to your preference
    }
  }


  Future<void> _refreshData() async {
    await itemController.getItemListById(widget.pageId).then((result) {
      if (_isMounted) {
        setState(() {
          itemlist = result;
          if (itemlist != null) {
            if (itemlist['itemClaims'] != null && itemlist['itemClaims'] is List) {
              var claimsList = itemlist['itemClaims'];
              var matchingClaim = claimsList.firstWhere(
                    (claim) => claim['userId'] == uid,
                orElse: () => null,
              );

              if (matchingClaim != null) {
                isItemClaimed = matchingClaim['isActive'] == true ? true : false;
                isStatusClaim = matchingClaim['claimStatus']??'';
                print("isStatusClaim: " + isStatusClaim.toString() );
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
                  itemlist['foundDates'] = '$formattedDate $slot';
                  itemlist['slot'] = slot;
                  itemlist['date'] = originalDate;
                  print(itemlist['slot']);
                  print(itemlist['date']);
                }
              }
            }
          }
        });
      }
    });
    await loadBookmarkedItems(widget.pageId);
    await loadFlagItems(widget.pageId);
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
          print("claimInfo:$claimInfo");
          setState(() {
            userReceiptList.add(claimInfo);
          });
        }
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
      verifyStatus = await AppConstrants.getVerifyStatus();
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
                  isItemClaimed = matchingClaim['isActive'] == true ? true : false;
                  isStatusClaim = matchingClaim['claimStatus']??'';
                  print("isStatusClaim: " + isStatusClaim.toString() );
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
                    itemlist['foundDates'] = '$formattedDate $slot';
                    itemlist['slot'] = slot;
                    itemlist['date'] = originalDate;
                    print(itemlist['slot']);
                    print(itemlist['date']);


                  }
                }
              }
            }
          });
        }
      });
      await loadBookmarkedItems(widget.pageId);
      await loadFlagItems(widget.pageId);
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
              print("claimInfo:$claimInfo");
              setState(() {
                userReceiptList.add(claimInfo);
              });
            }
        }

      });
      setState(() {
        loadingAll = true;
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
                    itemlist['user']['id'] == uid ? itemlist['itemStatus'] != 'RETURNED' ? Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            print("itemlist_foundDates: "+ itemlist['foundDate']);
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
                                  slot: itemlist['slot'],
                                  date: itemlist['date']
                                ),
                              ),
                            );
                          },
                          child: Text("Edit", style: TextStyle(color: AppColors.primaryColor, fontSize: 20),),
                        ),
                        Gap(AppLayout.getWidth(15)),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  title: Text("Confirmation"),
                                  content: Text("Do you want to delete this item?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop(); // Close the dialog
                                      },
                                      child: Text("Cancel",
                                        style: TextStyle( fontSize: 20),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        if (isDeleteItem) {
                                          // If creation is already in progress, do nothing or show a message.
                                          return;
                                        }

                                        isDeleteItem = true;

                                        await itemController.deleteItemById(itemId);
                                      },
                                      child: Text(
                                        "Delete",
                                        style: TextStyle(color: Colors.redAccent, fontSize: 20),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text("Delete", style: TextStyle(color: Colors.redAccent, fontSize: 20)),
                        ),

                      ],
                    ) : Container() : Container()
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
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ZoomableImagePage(
                                imageUrls: imageUrls,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(
                            imageUrls[index] ??
                                "https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg",
                            fit: BoxFit.fill,
                          ),
                        ),
                      );
                    },
                  ),
                ),                Center(
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: itemlist['isBookMarkActive'] ?? false
                          ? Icon(Icons.bookmark, color: AppColors.secondPrimaryColor, size: 35)
                          : Icon(Icons.bookmark_outline, color: AppColors.secondPrimaryColor, size: 35),
                      onPressed: () {
                        bookmarkItem(itemlist['id']);
                      },
                    ),
                    itemlist['user']['id'] == uid ? Container() : IconButton(
                      icon: itemlist['isFlagActive'] ?? false
                          ? Icon(Icons.flag, color: Colors.redAccent, size: 35,)
                          : Icon(Icons.flag_outlined, color: Colors.redAccent, size: 35),
                      onPressed: () {
                        String? selectedReason;

                        if (itemlist['isFlagActive'] ?? false) {
                          flagItem(itemlist['id'], "Wrong");
                          return;
                        }

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Why are you flagging this item?"),
                              content: StatefulBuilder(
                                builder: (BuildContext context, StateSetter setState) {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      DropdownButton<String>(
                                        value: selectedReason,
                                        items: ["BLURRY", "WRONG", "INAPPROPRIATE"].map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedReason = newValue;
                                          });
                                        },
                                        hint: Text("Select Reason"),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Cancel button pressed
                                  },
                                  child: Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (selectedReason != null) {
                                      Navigator.pop(context); // Close the dialog
                                      print('selectedReason: $selectedReason');
                                      // Provide the selected reason to the flagItem function
                                      flagItem(itemlist['id'], selectedReason!);
                                    } else {
                                      // Show a message if no reason is selected
                                      // You can replace this with a Snackbar or any other UI feedback
                                      SnackbarUtils().showError(title: "", message: "You must select a reason");
                                    }
                                  },
                                  child: Text("Flag"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                Gap(AppLayout.getHeight(20)),
                itemlist['user']['id'] == uid ? Text("   "+ itemlist['itemStatus'] ??
                    'No Status',style: TextStyle(color: _getStatusColor(itemlist['itemStatus']), fontSize: 20),): Container(),
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
                Gap(AppLayout.getHeight(10)),

                // time
                Container(
                    padding: EdgeInsets.only(
                        left: AppLayout.getWidth(16),
                        top: AppLayout.getHeight(8)),
                    child: IconAndTextWidget(
                        icon: Icons.timer_sharp,
                        text: itemlist['foundDates'],
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
                          if (itemlist['user']['id'] != uid) {
                            Navigator.push(
                                context, MaterialPageRoute(builder: (context) => AnotherProfileUser( userId: itemlist['user']['id'],)));
                          }
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

                itemlist['itemStatus'] != 'RETURNED' ? itemlist['user']['id'] == uid
                    ? Center(
                    child: AppButton(
                        boxColor: AppColors.secondPrimaryColor,
                        textButton: "List Claim",
                        onTap: () {
                          Navigator.push(
                              context, MaterialPageRoute(builder: (context) => ClaimItems(pageId: widget.pageId, page: "Claim user",itemUserId: itemlist['user']['id'],)));
                        }))
                : verifyStatus == 'VERIFIED' ? isStatusClaim == 'DENIED' ? const Center(child: Text('Claim Denied', style: TextStyle(color: Colors.red, fontSize: 20),),) :Center(
                    child: AppButton(
                      boxColor: isItemClaimed ? AppColors.primaryColor : AppColors.secondPrimaryColor,
                      textButton: isItemClaimed ? "Claimed" : "Claim",
                      onTap: isItemClaimed ? unclaimItem : claimItem,)): Container() : Column(
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
                                      Flexible(
                                        child: Column(
                                          children: [
                                            Text(
                                              user['fullName'] ?? '-',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context).textTheme.titleMedium,
                                            ),
                                            Gap(AppLayout.getHeight(5)),
                                            Text(
                                              user['email'] ?? '-',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: Theme.of(context).textTheme.titleMedium,
                                            ),

                                          ],
                                        ),
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
