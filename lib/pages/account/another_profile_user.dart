import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';

import '../../data/api/comment/comment_controller.dart';
import '../../data/api/item/item_controller.dart';
import '../../data/api/message/Chat.dart';
import '../../data/api/message/chat_controller.dart';
import '../../data/api/post/post_controller.dart';
import '../../data/api/user/user_controller.dart';
import '../../test/time/time_widget.dart';
import '../../utils/app_constraints.dart';
import '../../utils/colors.dart';
import '../../utils/snackbar_utils.dart';
import '../../widgets/app_button.dart';
import '../../widgets/big_text.dart';
import '../../widgets/icon_and_text_widget.dart';
import '../../widgets/time_ago_found_widget.dart';
import '../items/another_items_detail.dart';
import '../items/items_detail.dart';
import '../message/chat_page.dart';
import '../post/post_detail.dart';

class AnotherProfileUser extends StatefulWidget {
  final String userId;
  const AnotherProfileUser({Key? key, required this.userId}) : super(key: key);

  @override
  State<AnotherProfileUser> createState() => _AnotherProfileUserState();
}

class _AnotherProfileUserState extends State<AnotherProfileUser> {

  bool _isMounted = false;
  Map<String, dynamic> userList = {};
  final UserController userController= Get.put(UserController());
  bool itemsSelected = true;
  bool postsSelected = false;
  bool itemsLoading = false;
  bool postsLoading = false;
  late String uid = "";

  List<dynamic> itemlist = [];
  final ItemController itemController = Get.put(ItemController());

  List<dynamic> postList = [];
  final PostController postController = Get.put(PostController());

  List<dynamic> commentList = [];
  final CommentController commentController = Get.put(CommentController());

  int getCommentCountForPost(int postId) {
    return commentList.where((comment) => comment['postId'] == postId).length;
  }

  Future<void> toggleItemBookmarkStatus(int itemId, Future<void> Function(int) action) async {
    try {
      await action(itemId);

      // Manually update the item status based on the isBookMarkActive field
      setState(() {
        itemlist.forEach((item) {
          if (item['id'] == itemId) {
            item['isBookMarkActive'] = !(item['isBookMarkActive'] ?? false);
          }
        });
      });
    } catch (e) {
      print('Error toggling item status: $e');
    }
  }

  Future<void> bookmarkItem(int itemId) async {
    await toggleItemBookmarkStatus(itemId, itemController.postBookmarkItemByItemId);
  }

  Future<void> loadBookmarkedItems(int itemId) async {
    final bookmarkedItems = await itemController.getBookmarkedItems(itemId);
    if (_isMounted) {
      setState(() {
        final itemToUpdate = itemlist.firstWhere((item) => item['id'] == itemId, orElse: () => null);
        if (itemToUpdate != null) {
          itemToUpdate['isBookMarkActive'] = bookmarkedItems['itemId'] == itemId && bookmarkedItems['isActive'];
        }

      });
    }
  }

  Future<void> toggleItemFlagStatus(int itemId, Future<void> Function(int, String) action, String reason) async {
    try {
      await action(itemId, reason);

      // Manually update the item status based on the isFlagActive field
      setState(() {
        itemlist.forEach((item) {
          if (item['id'] == itemId) {
            item['isFlagActive'] = !(item['isFlagActive'] ?? false);
          }
        });
      });
    } catch (e) {
      print('Error toggling item status: $e');
    }
  }

  Future<void> flagItem(int itemId, String reason) async {
    await toggleItemFlagStatus(itemId, itemController.postFlagItemByItemId, reason);
  }

  Future<void> loadFlagItems(int itemId) async {
    final flagItems = await itemController.getFlagItems(itemId);
    if (_isMounted) {
      setState(() {
        final itemToUpdate = itemlist.firstWhere((item) => item['id'] == itemId, orElse: () => null);
        if (itemToUpdate != null) {
          itemToUpdate['isFlagActive'] = flagItems['itemId'] == itemId && flagItems['isActive'];
        }

      });
    }
  }

  Future<void> loadAndDisplayLocationNames(dynamic post) async {
    if (post['postLocationList'] != null) {
      List<dynamic> postLocationList = post['postLocationList'];

      if (postLocationList.isNotEmpty) {
        List locationNames = postLocationList.map((location) {
          return location['locationName'];
        }).toList();

        if (_isMounted) {
          setState(() {
            post['postLocationNames'] = locationNames.join(', ');
          });
        }
      }
    }
  }
  Future<void> loadAndDisplayCategoryNames(dynamic postList) async {
    if (postList['postCategoryList'] != null) {
      List<dynamic> postCategoryList = postList['postCategoryList'];

      if (postCategoryList.isNotEmpty) {
        List categoryNames = postCategoryList.map((caregories) {
          return caregories['name'];
        }).toList();
        print(categoryNames);
        if (_isMounted) {
          setState(() {
            postList['postCategoryNames'] = categoryNames.join(', ');
          });
        }
      }
    }
  }

  Future<void> togglePostBookmarkStatus(int postId, Future<void> Function(int) action) async {
    try {
      await action(postId);

      // Manually update the item status based on the isBookMarkActive field
      setState(() {
        postList.forEach((post) {
          if (post['id'] == postId) {
            post['isBookMarkActive'] = !(post['isBookMarkActive'] ?? false);
          }
        });
      });
    } catch (e) {
      print('Error toggling post status: $e');
    }
  }

  Future<void> bookmarkPost(int postId) async {
    await togglePostBookmarkStatus(postId, postController.postBookmarkPostByPostId);
  }

  Future<void> loadBookmarkedPosts(int postId) async {
    final bookmarkedPosts = await postController.getBookmarkedPost(postId);
    if (_isMounted) {
      setState(() {
        final postToUpdate = postList.firstWhere((post) => post['id'] == postId, orElse: () => null);
        if (postToUpdate != null) {
          postToUpdate['isBookMarkActive'] = bookmarkedPosts['postId'] == postId && bookmarkedPosts['isActive'];
        }
      });
    }
  }

  Future<void> togglePostFlagStatus(int postId, Future<void> Function(int, String) action, String reason) async {
    try {
      await action(postId, reason);

      // Manually update the item status based on the isFlagActive field
      setState(() {
        postList.forEach((post) {
          if (post['id'] == postId) {
            post['isFlagActive'] = !(post['isFlagActive'] ?? false);
          }
        });
      });
    } catch (e) {
      print('Error toggling post status: $e');
    }
  }

  Future<void> flagPost(int postId, String reason) async {
    await togglePostFlagStatus(postId, postController.postFlagPostByPostId, reason);
  }

  Future<void> loadFlagPosts(int postId) async {
    try {
      final flagPosts = await postController.getFlagPost(postId);
      print("flagPosts: " + flagPosts.toString());
      if (_isMounted) {
        setState(() {
          final postToUpdate = postList.firstWhere((post) => post['id'] == postId, orElse: () => null);
          if (postToUpdate != null) {
            postToUpdate['isFlagActive'] = flagPosts['postId'] == postId && flagPosts['isActive'];
          }
        });
      }
    } catch (e) {
      print('Error loading flag posts: $e');
    }
  }

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
      uid = await AppConstrants.getUid();
      await userController.getUserByUserId(widget.userId).then((result) {
        if (_isMounted) {
          setState(() {
            userList = result;
          });
        }
      });
      await itemController.getItemByUserId(widget.userId).then((result) {
        if (_isMounted) {
          setState(() {
            itemlist = result;
            itemsLoading = true;

            Future<void> loadBookmarkedItemsForAllItems() async {
              for (final item in itemlist) {
                final itemIdForBookmark = item['id'];
                print(itemIdForBookmark);
                await loadBookmarkedItems(itemIdForBookmark);
              }
            }

            loadBookmarkedItemsForAllItems();
            Future<void> loadFlagItemsForAllItems() async {
              for (final item in itemlist) {
                final itemIdForFlag = item['id'];
                await loadFlagItems(itemIdForFlag);
              }
            }

            loadFlagItemsForAllItems();
          });
        }
      });
      await postController.getPostByUserId(widget.userId).then((result) {
        if (_isMounted) {
          setState(() {
            postList = result;
            postsLoading = true;
            postList.removeWhere((post) => post['postStatus'] == 'DISABLED');
            setState(() {
              postList = result;
              Future.forEach(postList, (post) async {
                final postIdForBookmark = post['id'];
                print(postIdForBookmark);
                await loadBookmarkedPosts(postIdForBookmark);
              });
              Future.forEach(postList, (post) async {
                final postIdForFlag = post['id'];
                await loadFlagPosts(postIdForFlag);
              });

            });
          });
        }
      });
      for (var post in postList) {
        var idPost = post['id'];
        final commentResult = await commentController.getCommentByPostId(idPost);
        if (_isMounted) {
          setState(() {
            // Filter comments for the specific post and update commentList
            commentList.removeWhere((comment) => comment['postId'] == idPost);
            commentList.addAll(commentResult);
          });
        }
      }

    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: userList.isNotEmpty ? Column(
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
                  text: "Profile",
                  size: 20,
                  color: AppColors.secondPrimaryColor,
                  fontW: FontWeight.w500,
                ),
              ],
            ),
            Gap(AppLayout.getHeight(20)),

            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(userList['avatar']),
              ),
            ),
            Gap(AppLayout.getHeight(10)),
            Text(userList['fullName'] ?? '-', style: Theme.of(context).textTheme.headlineMedium,),
            Gap(AppLayout.getHeight(20)),
            userList['id'] != uid ? Center(
                child: AppButton(boxColor: AppColors.secondPrimaryColor, textButton: "Send Message", onTap: () async {
                  String otherUserId = userList['id'];

                  await ChatController().createUserChats(uid, otherUserId);
                  // Get.toNamed(RouteHelper.getInitial(2));
                  String chatId = uid.compareTo(otherUserId) > 0 ? uid + otherUserId : otherUserId + uid;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        chat: Chat(
                          uid: otherUserId,
                          name: userList['fullName'] ?? 'No Name',
                          image: userList['avatar'] ?? '',
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
                })) : Container(),
            Gap(AppLayout.getHeight(20)),

            const Divider(
              color: Colors.grey, // Color of the dashes
              height: 1,          // Height of the divider
              thickness: 1,       // Thickness of the dashes
              indent: 20,         // Indent (left padding) of the divider
              endIndent: 20,      // End indent (right padding) of the divider
            ),
            Gap(AppLayout.getHeight(10)),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 30),
              padding: EdgeInsets.only(top: AppLayout.getHeight(20), bottom: AppLayout.getHeight(20)),
              decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 4,
                        spreadRadius: 4,
                        offset: Offset(0, 4),
                        color: Colors.grey.withOpacity(0.2))
                  ]),
              // color: Colors.red,
              child: Column(
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding:  EdgeInsets.only(bottom: AppLayout.getHeight(8), left: AppLayout.getWidth(40)),
                    child: IconAndTextWidget(icon: Icons.email, text: userList['email']?? '-', iconColor: AppColors.secondPrimaryColor),
                  ),

                  Divider(color: Colors.grey,thickness: 1, indent: 30,endIndent: 30,),
                  Gap(AppLayout.getHeight(10)),

                  Padding(
                    padding: EdgeInsets.only(bottom: AppLayout.getHeight(8), left: AppLayout.getWidth(40)),
                    child: IconAndTextWidget(icon: FontAwesomeIcons.genderless, text: userList['gender'] ?? '-', iconColor: AppColors.secondPrimaryColor),

                  ),
                  Divider(color: Colors.grey,thickness: 1, indent: 30,endIndent: 30,),
                  Gap(AppLayout.getHeight(10)),

                  Padding(
                    padding: EdgeInsets.only(bottom: AppLayout.getHeight(8), left: AppLayout.getWidth(40)),
                    child: IconAndTextWidget(icon: Icons.phone, text: userList['phone']?? '-', iconColor: AppColors.secondPrimaryColor),
                  ),

                ],
              ),
            ),
            Gap(AppLayout.getHeight(30)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AppButton(
                    boxColor: itemsSelected ? AppColors.primaryColor : AppColors.secondPrimaryColor,
                    textButton: "Items",
                    width: AppLayout.getWidth(150),
                    height: AppLayout.getHeight(35),
                    onTap: (){
                      setState(() {
                        itemsSelected = true;
                        postsSelected = false;
                      });
                    }),
                AppButton(
                    boxColor: postsSelected ? AppColors.primaryColor : AppColors.secondPrimaryColor,
                    textButton: "Posts",
                    width: AppLayout.getWidth(150),
                    height: AppLayout.getHeight(35),
                    onTap: (){
                      setState(() {
                        itemsSelected = false;
                        postsSelected = true;
                      });
                    })
              ],),
            Gap(AppLayout.getHeight(30)),
            itemsSelected
                ? itemlist.isNotEmpty && itemsLoading
                  ? Center(
              child: GridView.builder(
                padding: EdgeInsets.all(15),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate:
                SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: AppLayout.getWidth(200),
                  childAspectRatio: 0.55,
                  crossAxisSpacing: AppLayout.getWidth(20),
                  mainAxisSpacing: AppLayout.getHeight(20),
                ),
                itemCount: itemlist.length,
                itemBuilder: (context, index) {
                  final item = itemlist[index];
                  final mediaUrl = getUrlFromItem(item) ??
                      "https://www.freeiconspng.com/thumbs/no-image-icon/no-image-icon-6.png";

                  if (item['foundDate'] != null) {
                    String foundDate = item['foundDate'];
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
                        DateFormat originalDateFormat = DateFormat("yyyy-MM-dd");
                        DateTime originalDate = originalDateFormat.parse(date);

                        // Format the date in the desired format
                        DateFormat desiredDateFormat = DateFormat("dd-MM-yyyy");
                        String formattedDate = desiredDateFormat.format(originalDate);
                        String timeAgo = TimeAgoFoundWidget.formatTimeAgo(originalDate);

                        // Update the foundDate in the itemlist
                        item['foundDate'] = '$timeAgo';
                      }
                    }
                  }


                  return Container(
                    decoration: const BoxDecoration(
                      borderRadius:
                      BorderRadius.all(Radius.circular(15)),
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: AppLayout.getHeight(130),
                          width: AppLayout.getWidth(180),
                          child: Image.network(
                            mediaUrl,
                            fit: BoxFit.fill,
                            errorBuilder:
                                (context, error, stackTrace) {
                              // Handle image loading errors
                              return Image.network(
                                  "https://www.freeiconspng.com/thumbs/no-image-icon/no-image-icon-6.png",
                                  fit: BoxFit.fill);
                            },
                          ),
                        ),
                        Container(
                          color: Theme.of(context).cardColor,
                          padding: EdgeInsets.only(
                            bottom: AppLayout.getHeight(28.5),
                            left: AppLayout.getWidth(8),
                            right: AppLayout.getWidth(8),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: item['isBookMarkActive'] ?? false
                                        ? Icon(Icons.bookmark, color: AppColors.secondPrimaryColor)
                                        : Icon(Icons.bookmark_outline, color: AppColors.secondPrimaryColor),
                                    onPressed: () {
                                      bookmarkItem(item['id']);
                                    },
                                  ),
                                  item['user']['id'] == uid ? Container()  : IconButton(
                                    icon: item['isFlagActive'] ?? false
                                        ? Icon(Icons.flag, color: Colors.redAccent)
                                        : Icon(Icons.flag_outlined, color: Colors.redAccent),
                                    onPressed: () {
                                      String? selectedReason;

                                      if (item['isFlagActive'] ?? false) {
                                        flagItem(item['id'], "Wrong");
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
                                                    print('selectedReason: '+ selectedReason.toString());

                                                    // Provide the selected reason to the flagItem function
                                                    flagItem(item['id'], selectedReason!);
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


                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['name'] ?? 'No Name',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              Gap(AppLayout.getHeight(10)),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Theme.of(context).iconTheme.color,
                                    size: AppLayout.getHeight(24),
                                  ),
                                  const Gap(5),
                                  Expanded(
                                    child: Text(
                                      item['locationName'] ??
                                          'No Location',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              Gap(AppLayout.getHeight(15)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.0),
                                child: Align(
                                  alignment:
                                  Alignment.centerLeft,
                                  child: Text(
                                    item['foundDate'] ?? '',
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                    style:
                                    TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: AppButton(
                            boxColor:
                            AppColors.secondPrimaryColor,
                            textButton: "Details",
                            fontSize: 18,
                            height: AppLayout.getHeight(30),
                            width: AppLayout.getWidth(180),
                            topLeft: 1,
                            topRight: 1,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ItemsDetails(
                                          pageId: item['id'],
                                          page: "item"),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
            : itemlist.isEmpty && itemsLoading
                ? SizedBox(
              width: AppLayout.getScreenWidth(),
              height: AppLayout.getHeight(300),
              child: Center(
                child: Text("This user doesn't have any items"),
              ),
            )
                  : SizedBox(
              width: AppLayout.getWidth(100),
              height: AppLayout.getHeight(300),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
                : postsSelected ? postList.isNotEmpty && postsLoading
                ? ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: postList.length,
              itemBuilder: (BuildContext context, int index) {

                final post = postList[index];
                loadAndDisplayLocationNames(post);
                loadAndDisplayCategoryNames(post);
                return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PostDetail(
                              pageId: post['id'],
                              page: "post"), // Navigate to PostDetail
                        ),
                      );
                    },
                    child: Container(
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
                              CircleAvatar(
                                radius: 25,
                                backgroundImage: NetworkImage(
                                    post['user']
                                    ['avatar']!),
                              ),
                              Gap(AppLayout.getHeight(15)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    post['user']
                                    ['fullName'],
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                  Gap(AppLayout.getHeight(5)),
                                  Text(
                                    post['createdDate'] != null
                                        ? '${TimeAgoWidget.formatTimeAgo(DateTime.parse(post['createdDate']))}'
                                        : 'No Date',
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey),
                                  )
                                ],
                              )
                            ],
                          ),
                          Gap(AppLayout.getHeight(30)),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              post['title'],
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium,
                            ),
                          ),
                          Container(
                            height:
                            MediaQuery.of(context).size.height *
                                0.3,
                            // Set a fixed height or use any other value
                            child: ListView.builder(
                              padding: EdgeInsets.zero, // Add this line to set zero padding
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: post['postMedias']
                                  .length,
                              itemBuilder: (context, indexs) {
                                return Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(
                                      left: AppLayout.getWidth(20)),
                                  height: AppLayout.getHeight(151),
                                  width: AppLayout.getWidth(180),
                                  child: Image.network(
                                      post['postMedias']
                                      [indexs]['media']['url'] ?? 'https://www.freeiconspng.com/thumbs/no-image-icon/no-image-icon-6.png',
                                      fit: BoxFit.fill),
                                );
                              },
                            ),
                          ),
                          Container(
                            child: Text(
                              post['postContent'],
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall,
                            ),
                          ),
                          Gap(AppLayout.getHeight(20)),

                          Row(
                            children: [
                              Icon(
                                Icons.category,
                                color: Theme.of(context).iconTheme.color,
                                size: AppLayout.getHeight(24),
                              ),
                              const Gap(5),
                              Expanded(
                                child: Text(
                                  post['postCategoryNames'] ?? 'No Categories',
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Gap(AppLayout.getHeight(10)),
                          IconAndTextWidget(
                            icon: Icons.location_on,
                            text: post['postLocationNames'] ??
                                'No Location',
                            size: 15,
                            iconColor: Colors.black,
                          ),
                          Gap(AppLayout.getHeight(30)),
                          Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: post['isBookMarkActive'] ?? false
                                    ? Icon(Icons.bookmark,
                                  color: Theme.of(context).iconTheme.color, size: 30,)
                                    : Icon(Icons.bookmark_outline,
                                  color: Theme.of(context).iconTheme.color, size: 30,),
                                onPressed: () {
                                  bookmarkPost(post['id']);
                                },
                              ),

                              IconAndTextWidget(
                                  icon: Icons.comment,
                                  text: getCommentCountForPost(post['id']).toString(),
                                  iconColor: Colors.grey),
                              post['user']['id'] == uid ? const Text("")  : IconButton(
                                icon: post['isFlagActive'] ?? false
                                    ? Icon(Icons.flag, color: Theme.of(context).iconTheme.color, size: 30,)
                                    : Icon(Icons.flag_outlined, color: Theme.of(context).iconTheme.color, size: 30,),
                                onPressed: () {
                                  String? selectedReason;

                                  if (post['isFlagActive'] ?? false) {
                                    flagPost(post['id'], "WrongInformation");
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
                                                  items: ["FALSE_INFORMATION", "VIOLATED_USER_POLICIES", "SPAM"].map((String value) {
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
                                                  isExpanded: true, // Add this line to make the dropdown button expand to the available width

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

                                                // Provide the selected reason to the flagItem function
                                                flagPost(post['id'], selectedReason!);
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
                          )
                        ],
                      ),
                    ));
              },
            )
            : postList.isEmpty && postsLoading ? SizedBox(
              width: AppLayout.getScreenWidth(),
              height: AppLayout.getHeight(300),
              child: const Center(
                child: Text("This user doesn't have any items"),
              ),
            )
                : SizedBox(
              width: AppLayout.getWidth(100),
              height: AppLayout.getHeight(300),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
                : Container(),
          ],
        ) : SizedBox(
          height: AppLayout.getScreenHeight() - 200,
          width: AppLayout.getScreenWidth(),
          child: const Center(child: CircularProgressIndicator(),
      ),
        ),
    )
    );
  }
}
