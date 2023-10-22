import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:lost_and_find_app/data/api/post/post_controller.dart';
import 'package:lost_and_find_app/pages/post/create_post.dart';
import 'package:lost_and_find_app/pages/post/post_detail.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/widgets/icon_and_text_widget.dart';

import '../../utils/colors.dart';
import '../../widgets/big_text.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<dynamic> postList = [];
  final PostController postController = Get.put(PostController());
  bool _isMounted = false;

  Future<void> _refreshData() async {
    await postController.getPostList().then((result) {
      if (_isMounted) {
        setState(() {
          postList = result;
        });
      }
    });
  }
  @override
  void initState() {
    super.initState();
    _isMounted = true;
    postController.getPostList().then((result) {
      if (_isMounted) {
        setState(() {
          postList = result;
        });
      }
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
            child: Column(
              children: [
                Gap(AppLayout.getHeight(20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: BigText(
                        text: "Post",
                        size: 20,
                        color: AppColors.secondPrimaryColor,
                        fontW: FontWeight.w500,
                      ),
                    ),
                    Container(
                      child: Icon(
                        Icons.search,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Post',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                GetBuilder<PostController>(builder: (posts) {
                  return posts.isLoaded
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: postList.length,
                          itemBuilder: (BuildContext context, int index) {
                            return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => PostDetail(
                                          pageId: postList[index]['id'],
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
                                                postList[index]['user']
                                                    ['avatar']!),
                                          ),
                                          Gap(AppLayout.getHeight(15)),
                                          Column(
                                            children: [
                                              Text(
                                                postList[index]['user']
                                                    ['fullName'],
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleSmall,
                                              ),
                                              Gap(AppLayout.getHeight(5)),
                                              Text(
                                                "16h ago",
                                                style: TextStyle(
                                                    fontSize: 12,
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
                                          postList[index]['title'],
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
                                          itemCount: postList[index]['postMedias']
                                              .length,
                                          itemBuilder: (context, indexs) {
                                            return Container(
                                              alignment: Alignment.centerLeft,
                                              margin: EdgeInsets.only(
                                                  left: AppLayout.getWidth(20)),
                                              height: AppLayout.getHeight(151),
                                              width: AppLayout.getWidth(180),
                                              child: Image.network(
                                                  postList[index]['postMedias']
                                                      [indexs]['media']['url'] ?? Container(),
                                                  fit: BoxFit.fill),
                                            );
                                          },
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                          postList[index]['postContent'],
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall,
                                        ),
                                      ),
                                      Gap(AppLayout.getHeight(30)),
                                      IconAndTextWidget(
                                        icon: Icons.location_on,
                                        text: postList[index]['LocationName'] ??
                                            'No Location',
                                        size: 15,
                                        iconColor: Colors.black,
                                      ),
                                      Gap(AppLayout.getHeight(30)),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconAndTextWidget(
                                              icon: Icons.bookmark,
                                              text: "100",
                                              iconColor: Colors.grey),
                                          IconAndTextWidget(
                                              icon: Icons.comment,
                                              text: "100",
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
                      : SizedBox(
                          width: AppLayout.getWidth(100),
                          height: AppLayout.getHeight(300),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                }),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => CreatePost()));
        },
        tooltip: 'Create Post',
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
