import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../data/api/comment/comment_controller.dart';
import '../../data/api/post/post_controller.dart';
import '../../test/time/time_widget.dart';
import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/big_text.dart';
import '../../widgets/icon_and_text_widget.dart';
import '../post/post_detail.dart';

class MyPostBookmark extends StatefulWidget {
  const MyPostBookmark({super.key});

  @override
  State<MyPostBookmark> createState() => _MyPostBookmarkState();
}

class _MyPostBookmarkState extends State<MyPostBookmark> {
  bool _isMounted = false;

  List<dynamic> postBookmarkList = [];
  final PostController postController = Get.put(PostController());
  final CommentController commentController = Get.put(CommentController());
  List<dynamic> commentList = [];

  int getCommentCountForPost(int postId) {
    return commentList.where((comment) => comment['postId'] == postId).length;
  }

  Future<void> bookmarkPost(int postId) async {
    try {
      await postController.postBookmarkPostByPostId(postId);

      // Manually update the bookmark status based on the isActive field
      setState(() {
        postBookmarkList.forEach((item) {
          if (item['id'] == postId) {
            item['isActive'] = !(item['isActive'] ?? false);
          }
        });
      });
    } catch (e) {
      print('Error bookmarking item: $e');
    }
  }

  Future<void> loadBookmarkedPosts(int postId) async {
    try {
      final bookmarkedPosts = await postController.getBookmarkedPost(postId);
      print('Bookmarked Posts Response: $bookmarkedPosts');

      if (_isMounted) {
        setState(() {
          final postToUpdate = postBookmarkList.firstWhere((post) => post['id'] == postId, orElse: () => null);
          if (postToUpdate != null) {
            postToUpdate['isActive'] = bookmarkedPosts['postId'] == postId && bookmarkedPosts['isActive'];
          }
          print(postToUpdate['isActive']);
        });
      }
    } catch (e) {
      print('Error loading bookmarked post for post $postId: $e');
    }
  }

  Future<void> _refreshData() async {
    _isMounted = true;
    Future.delayed(Duration(seconds: 1), () async {
      await postController.getPostBookmark().then((result) {
        if (_isMounted) {
          setState(() {
            postBookmarkList = result;

            Future<void> loadBookmarkedItemsForAllItems() async {
              for (final item in postBookmarkList) {
                final postIdForBookmark = item['id'];
                print(postIdForBookmark);
                await loadBookmarkedPosts(postIdForBookmark);
              }
            }

            loadBookmarkedItemsForAllItems();
          });
        }

      }).whenComplete(() {
        if (_isMounted) {
          setState(() {
            if (postBookmarkList.isEmpty) {
              _isMounted = false;
            }
          });
        }
      });
      for (var post in postBookmarkList) {
        var idPost = post['id'];
        final commentResult = await commentController.getCommentByPostId(idPost);
        if (_isMounted) {
          setState(() {
            commentList.removeWhere((comment) => comment['postId'] == idPost);
            commentList.addAll(commentResult);
          });
        }
      }

    });

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isMounted = true;
    Future.delayed(Duration(seconds: 1), () async {
      await postController.getPostBookmark().then((result) {
        if (_isMounted) {
          setState(() {
            postBookmarkList = result;

            Future<void> loadBookmarkedItemsForAllItems() async {
              for (final item in postBookmarkList) {
                final postIdForBookmark = item['id'];
                print(postIdForBookmark);
                await loadBookmarkedPosts(postIdForBookmark);
              }
            }

            loadBookmarkedItemsForAllItems();
          });
        }

      }).whenComplete(() {
        if (_isMounted) {
          setState(() {
            if (postBookmarkList.isEmpty) {
              _isMounted = false;
            }
          });
        }
      });
      for (var post in postBookmarkList) {
        var idPost = post['id'];
        final commentResult = await commentController.getCommentByPostId(idPost);
        if (_isMounted) {
          setState(() {
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
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Gap(AppLayout.getHeight(80)),
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
                    text: "Bookmark Posts",
                    size: 20,
                    color: AppColors.secondPrimaryColor,
                    fontW: FontWeight.w500,
                  ),
                ],
              ),
              if (postBookmarkList.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: postBookmarkList.length,
                itemBuilder: (BuildContext context, int index) {

                  final post = postBookmarkList[index];
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
                            Gap(AppLayout.getHeight(30)),
                            IconAndTextWidget(
                              icon: Icons.location_on,
                              text: post['locationName'] ??
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
                                  icon: post['isActive'] ?? false
                                      ? Icon(Icons.bookmark,
                                    color: Colors.white, size: 30,)
                                      : Icon(Icons.bookmark_outline,
                                    color: Colors.white, size: 30,),
                                  onPressed: () {
                                    bookmarkPost(post['id']);
                                  },
                                ),

                                IconAndTextWidget(
                                    icon: Icons.comment,
                                    text: getCommentCountForPost(post['id']).toString(),
                                    iconColor: Colors.grey),
                                IconAndTextWidget(
                                    icon: Icons.flag,
                                    text: "100",
                                    iconColor: Colors.grey),
                              ],
                            )
                          ],
                        ),
                      ));
                },
              )
              else if (postBookmarkList.isEmpty && !_isMounted)
                SizedBox(
                  width: AppLayout.getScreenWidth(),
                  height: AppLayout.getScreenHeight()-200,
                  child: Center(
                    child: Text("You have not bookmark any post yet"),
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
