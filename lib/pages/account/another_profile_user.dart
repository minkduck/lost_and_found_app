import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';

import '../../data/api/comment/comment_controller.dart';
import '../../data/api/item/item_controller.dart';
import '../../data/api/post/post_controller.dart';
import '../../data/api/user/user_controller.dart';
import '../../test/time/time_widget.dart';
import '../../utils/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/big_text.dart';
import '../../widgets/icon_and_text_widget.dart';
import '../items/another_items_detail.dart';
import '../items/items_detail.dart';
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

  List<dynamic> itemlist = [];
  final ItemController itemController = Get.put(ItemController());

  List<dynamic> postList = [];
  final PostController postController = Get.put(PostController());

  List<dynamic> commentList = [];
  final CommentController commentController = Get.put(CommentController());

  int getCommentCountForPost(int postId) {
    return commentList.where((comment) => comment['postId'] == postId).length;
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
          });
        }
      });
      await postController.getPostByUserId(widget.userId).then((result) {
        if (_isMounted) {
          setState(() {
            postList = result;
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
            Gap(AppLayout.getHeight(10)),
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
                ? itemlist.isNotEmpty
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
                          height: AppLayout.getHeight(151),
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
                              Gap(AppLayout.getHeight(8)),
                              Text(
                                item['name'] ?? 'No Name',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Gap(AppLayout.getHeight(15)),
                              IconAndTextWidget(
                                icon: Icons.location_on,
                                text: item['locationName'] ??
                                    'No Location',
                                size: 15,
                                iconColor: Colors.black,
                              ),
                              Gap(AppLayout.getWidth(15)),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.0),
                                child: Align(
                                  alignment:
                                  Alignment.centerLeft,
                                  child: Text(
                                    item['createdDate'] != null
                                        ? '${TimeAgoWidget.formatTimeAgo(DateTime.parse(item['createdDate']))}'
                                        : 'No Date',
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
                                      AnotherItemsDetails(
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
                  : SizedBox(
              width: AppLayout.getWidth(100),
              height: AppLayout.getHeight(300),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
                : postsSelected ? postList.isNotEmpty
                ? ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: postList.length,
              itemBuilder: (BuildContext context, int index) {

                final post = postList[index];
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
                              IconAndTextWidget(
                                  icon: Icons.bookmark,
                                  text: "100",
                                  iconColor: Colors.grey),
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
                : SizedBox(
              width: AppLayout.getWidth(100),
              height: AppLayout.getHeight(300),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            )
                : Container(),
          ],
        ) : const Center(child: CircularProgressIndicator(),
      ),
    )
    );
  }
}
