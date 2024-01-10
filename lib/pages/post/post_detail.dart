import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lost_and_find_app/data/api/comment/comment_controller.dart';
import 'package:lost_and_find_app/data/api/location/location_controller.dart';
import 'package:lost_and_find_app/data/api/post/post_controller.dart';

import '../../data/api/message/Chat.dart';
import '../../data/api/message/chat_controller.dart';
import '../../test/time/time_widget.dart';
import '../../utils/app_assets.dart';
import '../../utils/app_constraints.dart';
import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../utils/snackbar_utils.dart';
import '../../widgets/big_text.dart';
import '../../widgets/icon_and_text_widget.dart';
import '../../widgets/zoomable_image.dart';
import '../account/another_profile_user.dart';
import '../message/chat_page.dart';
import 'edit_post.dart';

class PostDetail extends StatefulWidget {
  final int pageId;
  final String page;

  const PostDetail({Key? key, required this.pageId, required this.page})
      : super(key: key);

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  bool _isMounted = false;

  Map<String, dynamic> postList = {};
  final PostController postController = Get.put(PostController());
  final LocationController locationController = Get.put(LocationController());

  List<dynamic> commentList = [];
  final CommentController commentController = Get.put(CommentController());
  var commentTextController = TextEditingController();
  var editCommentTextController = TextEditingController();
  late String uid = "";
  String? postLocationNames;
  bool? loadingFinished = false;

  Future<void> postCommentAndReloadComments(String comment) async {
    await CommentController().postCommentByPostId(widget.pageId, comment);
    commentTextController.clear();
    final result = await commentController.getCommentByPostId(widget.pageId);
    if (_isMounted) {
      setState(() {
        commentList = result;
      });
    }
  }

  Future<void> togglePostFlagStatus(int postId, Future<void> Function(int, String) action, String reason) async {
    try {
      await action(postId, reason);

      // Manually update the item status based on the isFlagActive field
      setState(() {
        postList['isFlagActive'] = !(postList['isFlagActive'] ?? false);
      });
    } catch (e) {
      print('Error toggling item status: $e');
    }
  }

  Future<void> flagPost(int postId, String reason) async {
    await togglePostFlagStatus(postId, postController.postFlagPostByPostId, reason);
  }

  Future<void> loadFlagPosts(int postId) async {
    final flagPosts = await postController.getFlagPost(postId);
    if (_isMounted) {
      setState(() {
        final postToUpdate = postList;
        if (postToUpdate != null) {
          postToUpdate['isFlagActive'] = flagPosts['postId'] == postId && flagPosts['isActive'];
        }
      });
    }
  }



  Future<void> bookmarkPost(int postId) async {
    try {
      await postController.postBookmarkPostByPostId(postId);

      // Manually update the bookmark status based on the isActive field
      setState(() {
        postList['isActive'] = !(postList['isActive'] ?? false);
      });    } catch (e) {
      print('Error bookmarking post: $e');
    }
  }

  Future<void> loadBookmarkedPost(int postId) async {
    try {
      final bookmarkedPosts = await postController.getBookmarkedPost(postId);

      if (_isMounted) {
        setState(() {
          if (postList.containsKey('id') && postList['id'] == postId) {
            postList['isActive'] =
                bookmarkedPosts['postId'] == postId && bookmarkedPosts['isActive'];
          }
        });
      }
    } catch (e) {
      print('Error loading bookmarked post for post $postId: $e');
      // Handle the error gracefully, e.g., set isActive to false or log the error.
    }
  }

  Future<List<String>> getLocationNames(List<int> locationIds) async {
    List<String> locationNames = [];

    for (int id in locationIds) {
      final result = await locationController.getLocationById(id);
      if (result.isNotEmpty) {
        final locationName = result[0]['locationName'];
        locationNames.add(locationName);
      }
    }

    return locationNames;
  }

/*  Future<void> loadAndDisplayLocationNames() async {
    if (postList['postLocationIdList'] != null) {
      List<int> locationIds = List<int>.from(postList['postLocationIdList']);

      final locationNames = await getLocationNames(locationIds);
      print("locationNames: " + locationNames.toString());
      if (_isMounted) {
        setState(() {
          postLocationNames = locationNames.join(', ');
        });
      }
      print("postLocationNames: " + postLocationNames.toString());
    }
  }*/

  Future<void> loadAndDisplayLocationNames(dynamic postList) async {
    if (postList['postLocationList'] != null) {
      List<dynamic> postLocationList = postList['postLocationList'];

      if (postLocationList.isNotEmpty) {
        List locationNames = postLocationList.map((location) {
          return location['locationName'];
        }).toList();
        print(locationNames);
        if (_isMounted) {
          setState(() {
            postList['postLocationNames'] = locationNames.join(', ');
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

  Future<void> _refreshData() async {
    await postController.getPostListById(widget.pageId).then((result) {
      if (_isMounted) {
        setState(() {
          postList = result;
        });
      }
    });
    await loadBookmarkedPost(widget.pageId);

    await commentController.getCommentByPostId(widget.pageId).then((result) {
      if (_isMounted) {
        setState(() {
          commentList = result;
        });
      }
    });
    await loadFlagPosts(widget.pageId);
    uid = await AppConstrants.getUid();
    loadAndDisplayLocationNames(postList);
    loadAndDisplayCategoryNames(postList);
  }

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    Future.delayed(Duration(seconds: 0), () async {
      await postController.getPostListById(widget.pageId).then((result) {
        if (_isMounted) {
          setState(() {
            postList = result;
          });
        }
      });
      await loadBookmarkedPost(widget.pageId);

      await commentController.getCommentByPostId(widget.pageId).then((result) {
        if (_isMounted) {
          setState(() {
            commentList = result;
          });
        }
      });
      await loadFlagPosts(widget.pageId);
      uid = await AppConstrants.getUid();
      loadAndDisplayLocationNames(postList);
      loadAndDisplayCategoryNames(postList);
      setState(() {
        loadingFinished = true;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    loadingFinished = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.0),                child: SingleChildScrollView(

      child: postList.isNotEmpty && loadingFinished! ? Column(
                  children: [
                    Gap(AppLayout.getHeight(50)),
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
                              text: "Post",
                              size: 20,
                              color: AppColors.secondPrimaryColor,
                              fontW: FontWeight.w500,
                            ),
                          ],
                        ),
                        postList['user']['id'] == uid ? Row(children: [
                          GestureDetector(
                            onTap: () async {
                                Map<String, dynamic> postData = {
                                  'postId': postList['id'],
                                  'title': postList['title'],
                                  'description': postList['postContent'],
                                  "postLocationIdList": postList['postLocationIdList'] ?? [],
                                  "postCategoryIdList": postList['postCategoryIdList'] ?? [],
                                  "lostDateFrom": postList['lostDateFrom'],
                                  "lostDateTo": postList['lostDateTo'],
                                };
                                print("postData: " + postData.toString());
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditPost(postData: postData),
                                  ),
                                );
                            },
                            child: Text("Edit", style: TextStyle(color: AppColors.primaryColor, fontSize: 20),),
                          ),
                          Gap(AppLayout.getWidth(15)),
                          GestureDetector(
                            onTap: () async {
                              await postController.deleteItemById(postList['id']);
                            },
                            child: Text("Delete", style: TextStyle(color: Colors.redAccent, fontSize: 20),),
                          ),

                        ],) : Container()
                      ],
                    ),
                    Gap(AppLayout.getHeight(30)),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).cardColor,
                      ),
                      // color: Colors.red,
                      margin: EdgeInsets.only(bottom: AppLayout.getHeight(20)),
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AnotherProfileUser(userId: postList['user']['id'])),
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width, // or use a fixed width as needed
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 25,
                                    backgroundImage: NetworkImage(postList['user']['avatar'] ?? ''),
                                  ),
                                  Gap(AppLayout.getWidth(10)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          postList['user']['fullName'] ?? 'No Name',
                                          style: Theme.of(context).textTheme.titleSmall,
                                        ),
                                        Gap(AppLayout.getHeight(5)),
                                        Text(
                                          postList['createdDate'] != null
                                              ? '${TimeAgoWidget.formatTimeAgo(DateTime.parse(postList['createdDate']))}  --  ${DateFormat('dd-MM-yyyy').format(DateTime.parse(postList['createdDate']))}'
                                              : 'No Date',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Gap(AppLayout.getHeight(10)),
/*
                          GestureDetector(
                                onTap: () async {
                                  String otherUserId = postList['user']['id'];

                                  await ChatController().createUserChats(uid, otherUserId);
                                  // Get.toNamed(RouteHelper.getInitial(2));
                                  String chatId = uid.compareTo(otherUserId) > 0 ? uid + otherUserId : otherUserId + uid;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatPage(
                                        chat: Chat(
                                          uid: otherUserId,
                                          name: postList['user']['fullName'] ?? 'No Name',
                                          image: postList['user']['avatar'] ?? '',
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
                                },
                                child: Text("Message", style: TextStyle(color: AppColors.primaryColor, fontSize: 20),),
                              ),
*/
                          Gap(AppLayout.getHeight(30)),

                          Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                postList['title'] ?? 'No title',
                                style: Theme.of(context).textTheme.titleMedium,
                              )),
                          Gap(AppLayout.getHeight(15)),
                          Container(
                            height: MediaQuery.of(context).size.height * 0.25,
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: postList['postMedias'].length,
                              itemBuilder: (context, indexs) {
                                return GestureDetector(
                                  onTap: () {
                                    List<String> imageUrls = postList['postMedias']
                                        .map((media) => media['media']['url']?.toString() ?? "")
                                        .whereType<String>()
                                        .toList();

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ZoomableImagePage(
                                          imageUrls: imageUrls,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(left: AppLayout.getWidth(20)),
                                    height: AppLayout.getHeight(151),
                                    width: AppLayout.getWidth(180),
                                    child: Image.network(
                                      postList['postMedias'][indexs]['media']['url']?.toString() ??
                                          'https://www.freeiconspng.com/thumbs/no-image-icon/no-image-icon-6.png',
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Gap(AppLayout.getHeight(10)),
                          Container(
                            child: Text(postList['postContent'],
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                          Gap(AppLayout.getHeight(30)),
/*
                          IconAndTextWidget(
                            icon: Icons.location_on,
                            text: postLocationNames ?? 'No Location',
                            size: 15,
                            iconColor: Colors.black,
                          ),
*/
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
                                  postList['postCategoryNames'] ?? 'No Categories',
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          Gap(AppLayout.getHeight(15)),
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
                                  postList['postLocationNames'] ?? 'No Locations',
                                  maxLines: 5,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Gap(AppLayout.getHeight(15)),
                          Row(
                            children: [
                              Icon(
                                Icons.timer_sharp,
                                color: Theme.of(context).iconTheme.color,
                                size: AppLayout.getHeight(24),
                              ),
                              const Gap(5),
                              postList['lostDateFrom'] != null || postList['lostDateTo'] != null ? Row(
                                children: [
                                  Text(
                                    postList['lostDateFrom'] != null
                                        ? DateFormat('dd-MM-yyyy').format(DateTime.parse(postList['lostDateFrom']))
                                        : '',
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  postList['lostDateFrom'] != null && postList['lostDateTo'] != null ? Text(" to ") : Text(""),
                                  Text(
                                    postList['lostDateTo'] != null
                                        ? DateFormat('dd-MM-yyyy').format(DateTime.parse(postList['lostDateTo']))
                                        : '',
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                ],
                              ) : Text("Don't remember"),
                            ],
                          ),
                          Gap(AppLayout.getHeight(30)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: postList['isActive'] ?? false
                                    ? Icon(Icons.bookmark,
                                  color: Theme.of(context).iconTheme.color, size: 30,)
                                    : Icon(Icons.bookmark_outline,
                                  color: Theme.of(context).iconTheme.color, size: 30,),
                                onPressed: () {
                                  bookmarkPost(postList['id']);
                                },
                              ),
                              IconAndTextWidget(
                                  icon: Icons.comment,
                                  text: commentList.length.toString(),
                                  iconColor: Colors.grey),
                              postList['user']['id'] == uid ? Container()  : IconButton(
                                icon: postList['isFlagActive'] ?? false
                                    ? Icon(Icons.flag, color: Theme.of(context).iconTheme.color, size: 30,)
                                    : Icon(Icons.flag_outlined, color: Theme.of(context).iconTheme.color, size: 30,),
                                onPressed: () {
                                  String? selectedReason;

                                  if (postList['isFlagActive'] ?? false) {
                                    flagPost(postList['id'], "FALSE_INFORMATION");
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
                                                  isExpanded: true,
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
                                                flagPost(postList['id'], selectedReason!);
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
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).cardColor,
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                top: AppLayout.getHeight(10),
                                left: AppLayout.getWidth(10)),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Comment",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: commentList.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                margin: EdgeInsets.only(
                                    bottom: AppLayout.getHeight(20),
                                    left: AppLayout.getWidth(15)),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundImage:
                                          NetworkImage(commentList[index]['user']['avatar']!),
                                    ),
                                    Gap(AppLayout.getWidth(10)),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              commentList[index]['user']['fullName'] + " - " ,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleSmall?.copyWith(fontWeight: FontWeight.bold),
                                            ),
                                            Text(commentList[index]['createdDate'] != null
                                                ? DateFormat('dd-MM-yyyy').format(DateTime.parse(commentList[index]['createdDate']))
                                                : 'No Date' ,style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey)),
                                          ],
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context).size.width - AppLayout.getWidth(120), // Adjust this width
                                          child: Text(
                                            commentList[index]['commentContent'] ?? 'No Comment',
                                            style: Theme.of(context).textTheme.titleSmall,
                                            softWrap: true,
                                          ),
                                        ),
                                        Gap(AppLayout.getWidth(15)),
                                        commentList[index]['user']['id'] == uid ? Row(
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(context: context, builder: (context) => AlertDialog(
                                                  title: Text('Edit Comment'),
                                                  content: TextField(
                                                    controller: editCommentTextController,
                                                    decoration: InputDecoration(hintText: "Write a comment.."),
                                                      maxLines: 2
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () async {
                                                      await CommentController().putCommentByPostId(commentList[index]['id'], editCommentTextController.text);
                                                      editCommentTextController.clear();
                                                      final result = await commentController.getCommentByPostId(widget.pageId);
                                                      if (_isMounted) {
                                                        setState(() {
                                                          commentList = result;
                                                        });
                                                      }
                                                      Navigator.pop(context);
                                                    }, child: Text('Update')),
                                                    TextButton(onPressed: (){
                                                      Navigator.pop(context);
                                                    }, child: Text('Cancel'))

                                                  ],
                                                ));
                                              },
                                              child: Text("Edit", style: TextStyle(fontSize: 15,color: AppColors.primaryColor),),
                                            ),
                                            Gap(AppLayout.getWidth(10)),
                                            GestureDetector(
                                              onTap: () {
                                                showDialog(context: context, builder: (context) => AlertDialog(
                                                  title: Text('Are you sure to delete this comment'),
                                                  actions: [
                                                    TextButton(
                                                        onPressed: () async {
                                                          await CommentController().deleteCommentByCommentId(commentList[index]['id']);
                                                          final result = await commentController.getCommentByPostId(widget.pageId);
                                                          if (_isMounted) {
                                                            setState(() {
                                                              commentList = result;
                                                            });
                                                          }
                                                          Navigator.pop(context);
                                                        }, child: Text('Delete')),
                                                    TextButton(onPressed: (){
                                                      Navigator.pop(context);
                                                    }, child: Text('Cancel'))

                                                  ],
                                                ));
                                              },

                                              child: Text("Delete", style: TextStyle(fontSize: 15,color: Colors.redAccent),),
                                            ),
                                          ],
                                        ) : Container()
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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
            )),
            postList['postStatus'] == 'ACTIVE' ? Container(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 4),
                    blurRadius: 32,
                    color: const Color(0xFF087949).withOpacity(0.08),
                  ),
                ],
              ),
              //comment container
              child: Container(
                padding: EdgeInsets.only(top: 30),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        postCommentAndReloadComments(commentTextController.text);
                      },
                        child: Icon(Icons.send, color: Color(0xFF00BF6D))),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20 * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF00BF6D).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: AppLayout.getWidth(5)),
                            Expanded(
                              child: TextField(
                                controller: commentTextController,
                                decoration: InputDecoration(
                                  hintText: "Type message",
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ) : Container()
          ],
        ),
      ),
    );
  }
}
