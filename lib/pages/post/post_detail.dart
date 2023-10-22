import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:lost_and_find_app/data/api/post/post_controller.dart';

import '../../utils/app_assets.dart';
import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/big_text.dart';
import '../../widgets/icon_and_text_widget.dart';

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

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    postController.getPostListById(widget.pageId).then((result) {
      if (_isMounted) {
        setState(() {
          postList = result;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: postList.isNotEmpty ? Column(
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
                        text: "Post",
                        size: 20,
                        color: AppColors.secondPrimaryColor,
                        fontW: FontWeight.w500,
                      ),
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
                                  AssetImage(AppAssets.avatarDefault!),
                            ),
                            Gap(AppLayout.getHeight(15)),
                            Column(
                              children: [
                                Text(
                                  postList['user']['fullName'] ?? 'No Name',
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                Gap(AppLayout.getHeight(5)),
                                Text(
                                  "16h ago",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey),
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
                          itemCount: 5,
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
                                        AssetImage(AppAssets.avatarDefault!),
                                  ),
                                  Gap(AppLayout.getWidth(10)),
                                  Column(
                                    children: [
                                      Text(
                                        "John",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
                                      Text(
                                        "Lorem ipsum dolor sit amet",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall,
                                      ),
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
                  const Icon(Icons.send, color: Color(0xFF00BF6D)),
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
                      child: const Row(
                        children: [
                          SizedBox(width: 20 / 4),
                          Expanded(
                            child: TextField(
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
    );
  }
}
