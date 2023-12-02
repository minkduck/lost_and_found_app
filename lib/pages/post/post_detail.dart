import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lost_and_find_app/data/api/comment/comment_controller.dart';
import 'package:lost_and_find_app/data/api/post/post_controller.dart';

import '../../test/time/time_widget.dart';
import '../../utils/app_assets.dart';
import '../../utils/app_constraints.dart';
import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/big_text.dart';
import '../../widgets/icon_and_text_widget.dart';
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
  List<dynamic> commentList = [];
  final CommentController commentController = Get.put(CommentController());
  var commentTextController = TextEditingController();
  var editCommentTextController = TextEditingController();
  late String uid = "";

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

  Future<void> _refreshData() async {
    await postController.getPostListById(widget.pageId).then((result) {
      if (_isMounted) {
        setState(() {
          postList = result;
        });
      }
    });
    await commentController.getCommentByPostId(widget.pageId).then((result) {
      if (_isMounted) {
        setState(() {
          commentList = result;
        });
      }
    });
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
      uid = await AppConstrants.getUid();
    });

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

      child: postList.isNotEmpty ? Column(
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
                                  "postLocationId": postList['locationName'],
                                  "postCategoryId": postList['categoryName'],
                                };

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
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundImage:
                                    NetworkImage(postList['user']['avatar']!),
                              ),
                              Gap(AppLayout.getHeight(15)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    postList['user']['fullName'] ?? 'No Name',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Gap(AppLayout.getHeight(5)),
                                  Text(
                                    postList['createdDate'] != null
                                        ? '${TimeAgoWidget.formatTimeAgo(DateTime.parse(postList['createdDate']))}  --  '
                                        '${DateFormat('dd-MM-yyyy').format(DateTime.parse(postList['createdDate']))}'
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
                                postList['title'] ?? 'No title',
                                style: Theme.of(context).textTheme.titleMedium,
                              )),
                          Gap(AppLayout.getHeight(15)),
                          Container(
                            height:
                            MediaQuery.of(context).size.height *
                                0.25,
                            // Set a fixed height or use any other value
                            child: ListView.builder(
                              padding: EdgeInsets.zero, // Add this line to set zero padding
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: postList['postMedias']
                                  .length,
                              itemBuilder: (context, indexs) {
                                return Container(
                                  alignment: Alignment.centerLeft,
                                  margin: EdgeInsets.only(
                                      left: AppLayout.getWidth(20)),
                                  height: AppLayout.getHeight(151),
                                  width: AppLayout.getWidth(180),
                                  child: Image.network(
                                      postList['postMedias']
                                      [indexs]['media']['url'] ?? Container(),
                                      fit: BoxFit.fill),
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
                          IconAndTextWidget(
                            icon: Icons.location_on,
                            text: postList['locationName'] ?? 'No Location',
                            size: 15,
                            iconColor: Colors.black,
                          ),

                          Gap(AppLayout.getHeight(30)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: postList['isActive'] ?? false
                                    ? Icon(Icons.bookmark,
                                  color: Colors.white, size: 30,)
                                    : Icon(Icons.bookmark_outline,
                                  color: Colors.white, size: 30,),
                                onPressed: () {
                                  bookmarkPost(postList['id']);
                                },
                              ),
                              IconAndTextWidget(
                                  icon: Icons.comment,
                                  text: commentList.length.toString(),
                                  iconColor: Colors.grey),
                              IconAndTextWidget(
                                  icon: Icons.flag,
                                  text: "100",
                                  iconColor: Colors.grey),
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
            Container(
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
            )
          ],
        ),
      ),
    );
  }
}
