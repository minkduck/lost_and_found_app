import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lost_and_find_app/data/api/post/post_controller.dart';
import 'package:lost_and_find_app/pages/post/create_post.dart';
import 'package:lost_and_find_app/pages/post/post_detail.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/widgets/icon_and_text_widget.dart';

import '../../data/api/category/category_controller.dart';
import '../../test/time/time_widget.dart';
import '../../utils/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/big_text.dart';
import '../../widgets/custom_search_bar.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({Key? key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  List<dynamic> postList = [];
  final PostController postController = Get.put(PostController());
  bool _isMounted = false;
  List<dynamic> categoryList = [];
  final CategoryController categoryController = Get.put(CategoryController());
  List<String> selectedCategories = [];
  String filterText = '';
  bool postsSelected = true;
  bool myPostsSelected = false;

  Future<void> _refreshData() async {
    await postController.getPostList().then((result) {
      if (_isMounted) {
        setState(() {
          postList = result;
        });
      }
    });
    await categoryController.getCategoryList().then((result) {
      if (_isMounted) {
        setState(() {
          categoryList = result;
        });
      }
    });

  }
  @override
  void initState() {
    super.initState();
    _isMounted = true;
    Future.delayed(Duration(seconds: 1), () {
      postController.getPostList().then((result) {
        if (_isMounted) {
          setState(() {
            postList = result;
          });
        }
      });
      categoryController.getCategoryList().then((result) {
        if (_isMounted) {
          setState(() {
            categoryList = result;
          });
        }
      });
    });
  }

  void onFilterTextChanged(String text) {
    setState(() {
      filterText = text;
    });
  }

  void onSubmitted() {
    // Handle search submission here
    print('Search submitted with text: $filterText');
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> filteredItems = postList
        .where((post) =>
    selectedCategories.isEmpty ||
        selectedCategories.contains(post['categoryName']))
        .where((post) =>
    filterText.isEmpty ||
        (post['title'] != null &&
            post['title']
                .toLowerCase()
                .contains(filterText.toLowerCase())))
        .toList(); 

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
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Post',
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                    CustomSearchBar(
                      filterText: filterText, // Pass the filter text
                      onFilterTextChanged: onFilterTextChanged, // Set the filter text handler
                      onSubmitted: onSubmitted,
                    ),

                  ],
                ),
                Gap(AppLayout.getHeight(10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AppButton(
                        boxColor: postsSelected ? AppColors.primaryColor : AppColors.secondPrimaryColor,
                        textButton: "Post",
                        width: AppLayout.getWidth(150),
                        height: AppLayout.getHeight(35),
                        onTap: (){
                          setState(() {
                            postsSelected = true;
                            myPostsSelected = false;
                          });
                        }),
                    AppButton(
                        boxColor: myPostsSelected ? AppColors.primaryColor : AppColors.secondPrimaryColor,
                        textButton: "My Posts",
                        width: AppLayout.getWidth(150),
                        height: AppLayout.getHeight(35),
                        onTap: (){
                          setState(() {
                            postsSelected = false;
                            myPostsSelected = true;
                          });
                        })
                  ],),
                Gap(AppLayout.getHeight(10)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: categoryList
                          .map((category) => GestureDetector(
                        onTap: () {
                          setState(() {
                            if (selectedCategories.contains(category['name'])) {
                              selectedCategories.remove(category['name']);
                            } else {
                              selectedCategories.add(category['name']);
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: BigText(
                            text: category['name'] != null ? category['name'].toString() : 'No Category',
                            color: selectedCategories.contains(category['name'])
                                ? AppColors
                                .primaryColor // Selected text color
                                : AppColors.secondPrimaryColor,
                            fontW: FontWeight.w500,
                          ),
                        ),
                      ))
                          .toList(),
                    ),
                  ),
                ),

                GetBuilder<PostController>(builder: (posts) {
                  return postList.isNotEmpty
                      ? RefreshIndicator(
                    onRefresh: _refreshData,
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: filteredItems.length,
                            itemBuilder: (BuildContext context, int index) {

                              final post = filteredItems[index];
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
                                                        [indexs]['media']['url'] ?? Container(),
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
                                          text: post['LocationName'] ??
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
                          ),
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
