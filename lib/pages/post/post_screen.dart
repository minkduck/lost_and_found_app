import 'package:flutter/foundation.dart';
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
import '../../data/api/comment/comment_controller.dart';
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
  List<dynamic> categoryList = [];
  List<dynamic> categoryGroupList = [];
  List<String> selectedCategories = [];
  dynamic selectedCategoryGroup;
  dynamic previouslySelectedCategoryGroup;
  final CategoryController categoryController = Get.put(CategoryController());

  List<dynamic> postList = [];
  List<dynamic> mypostList = [];
  bool myPostLoading = false;

  final PostController postController = Get.put(PostController());
  String filterText = '';
  bool postsSelected = true;
  bool myPostsSelected = false;

  bool _isMounted = false;

  final CommentController commentController = Get.put(CommentController());
  List<dynamic> commentList = [];
  List<dynamic> commentMyList = [];

  int getCommentCountForPost(int postId) {
    return commentList.where((comment) => comment['postId'] == postId).length;
  }

  int getCommentCountForMyPost(int postId) {
    return commentMyList.where((comment) => comment['postId'] == postId).length;
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

  void selectCategoryGroup(dynamic categoryGroup) {
    setState(() {
      previouslySelectedCategoryGroup = selectedCategoryGroup;

      // If the clicked category group is the same as the previously selected one, clear the selection
      if (selectedCategoryGroup == categoryGroup) {
        selectedCategoryGroup = null;
        selectedCategories.clear(); // Clear selected categories
      } else {
        selectedCategoryGroup = categoryGroup;
      }
    });
  }

  List<dynamic> filterPostsByCategories() {
    // Apply category filtering first
    final List<dynamic> filteredByCategories = selectedCategoryGroup == null
        ? postList
        : postList.where((post) {
      final category = post['categoryName'];
      return selectedCategoryGroup['categories']
          .any((selectedCategory) => selectedCategory['name'] == category);
    }).toList();

    // Apply text filter
    final filteredByText = filteredByCategories
        .where((post) =>
    selectedCategories.isEmpty ||
        selectedCategories.contains(post['categoryName']))
        .where((post) =>
    filterText.isEmpty ||
        (post['title'] != null &&
            post['title'].toLowerCase().contains(filterText.toLowerCase())))
        .toList();

    return filteredByText;
  }

  List<dynamic> filterMyPostsByCategories() {
    // Apply category filtering first
    final List<dynamic> filteredByCategories = selectedCategoryGroup == null
        ? mypostList
        : mypostList.where((item) {
      final category = item['categoryName'];
      return selectedCategoryGroup['categories']
          .any((selectedCategory) => selectedCategory['name'] == category);
    }).toList();

    // Apply text filter
    final filteredByText = filteredByCategories
        .where((post) =>
    selectedCategories.isEmpty ||
        selectedCategories.contains(post['categoryName']))
        .where((post) =>
    filterText.isEmpty ||
        (post['name'] != null &&
            post['name'].toLowerCase().contains(filterText.toLowerCase())))
        .toList();

    return filteredByText;
  }

  Future<void> _refreshData() async {
    await postController.getPostList().then((result) {
      if (_isMounted) {
        setState(() {
          postList = result;
        });
      }
    });
    await postController.getPostByUidList().then((result) {
      if (_isMounted) {
        setState(() {
          mypostList = result;
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
    for (var post in mypostList) {
      var idPost = post['id'];
      final commentResult = await commentController.getCommentByPostId(idPost);
      if (_isMounted) {
        setState(() {
          commentMyList.removeWhere((comment) => comment['postId'] == idPost);
          commentMyList.addAll(commentResult);
        });
      }
    }
    await categoryController.getCategoryGroupList().then((result) {
      if (_isMounted) {
        setState(() {
          categoryGroupList = result;
        });
      }
    });

  }
  @override
  void initState() {
    super.initState();
    _isMounted = true;
    myPostLoading = true;
    Future.delayed(Duration(seconds: 1), () async {
      await postController.getPostList().then((result) {
        if (_isMounted) {
          setState(() {
            postList = result;
            postList.removeWhere((post) => post['postStatus'] == 'DELETED');
            setState(() {
              postList = result;
            });
          });
        }
      });
      await postController.getPostByUidList().then((result) {
        if (_isMounted) {
          setState(() {
            mypostList = result;
            myPostLoading = false;
            mypostList.removeWhere((post) => post['postStatus'] == 'DELETED');
            setState(() {
              mypostList = result;
            });
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
      for (var post in postList) {
        var idPost = post['id'];
        final commentResult = await commentController.getCommentByPostId(idPost);
        if (_isMounted) {
          setState(() {
            commentList.removeWhere((comment) => comment['postId'] == idPost);
            commentList.addAll(commentResult);
          });
        }
      }
      for (var post in mypostList) {
        var idPost = post['id'];
        final commentResult = await commentController.getCommentByPostId(idPost);
        if (_isMounted) {
          setState(() {
            commentMyList.removeWhere((comment) => comment['postId'] == idPost);
            commentMyList.addAll(commentResult);
          });
        }
      }
      await categoryController.getCategoryGroupList().then((result) {
        if (_isMounted) {
          setState(() {
            categoryGroupList = result;
          });
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
    final List<dynamic> filteredPost = filterPostsByCategories();
    final List<dynamic> filteredMyPost = filterMyPostsByCategories();

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
                      children: categoryGroupList.map((categoryGroup) {
                        return GestureDetector(
                          onTap: () {
                            // Call the selectCategoryGroup function when a categoryGroup is clicked
                            selectCategoryGroup(categoryGroup);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            child: BigText(
                              text: categoryGroup['name'] != null
                                  ? categoryGroup['name'].toString()
                                  : 'No Category',
                              color: categoryGroup == selectedCategoryGroup
                                  ? AppColors.primaryColor
                                  : AppColors.secondPrimaryColor,
                              fontW: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                Gap(AppLayout.getHeight(10)),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: selectedCategoryGroup != null
                          ? (selectedCategoryGroup['categories'] as List<dynamic>)
                          .map((category) {
                        return GestureDetector(
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
                              vertical: 8,
                              horizontal: 16,
                            ),
                            child: BigText(
                              text: category['name'] != null
                                  ? category['name'].toString()
                                  : 'No Category',
                              color: selectedCategories.contains(category['name'])
                                  ? AppColors.primaryColor
                                  : AppColors.secondPrimaryColor,
                              fontW: FontWeight.w500,
                            ),
                          ),
                        );
                      })
                          .toList()
                          : [],
                    ),
                  ),
                ),

                GetBuilder<PostController>(builder: (posts) {
                  return postsSelected ?
                    postList.isNotEmpty & categoryGroupList.isNotEmpty
                      ? RefreshIndicator(
                    onRefresh: _refreshData,
                        child: ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: filteredPost.length,
                            itemBuilder: (BuildContext context, int index) {

                              final post = filteredPost[index];
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
                          ),
                      )
                      : SizedBox(
                          width: AppLayout.getWidth(100),
                          height: AppLayout.getHeight(300),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : myPostsSelected ? myPostLoading ? SizedBox(
                    width: AppLayout.getWidth(100),
                    height: AppLayout.getHeight(300),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ) :
                       mypostList.isNotEmpty & categoryGroupList.isNotEmpty
                      ? RefreshIndicator(
                    onRefresh: _refreshData,
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: filteredMyPost.length,
                      itemBuilder: (BuildContext context, int index) {

                        final post = filteredMyPost[index];
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
                                          text: getCommentCountForMyPost(post['id']).toString(),
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
                         width: AppLayout.getScreenWidth(),
                         height: AppLayout.getScreenHeight()-400,
                         child: Center(
                           child: Text("You haven't created any post yet"),
                         ),
                       )
                      : Container();
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
