import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lost_and_find_app/data/api/location/location_controller.dart';
import 'package:lost_and_find_app/data/api/post/post_controller.dart';
import 'package:lost_and_find_app/pages/post/create_post.dart';
import 'package:lost_and_find_app/pages/post/post_detail.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/widgets/icon_and_text_widget.dart';

import '../../data/api/category/category_controller.dart';
import '../../data/api/comment/comment_controller.dart';
import '../../test/time/time_widget.dart';
import '../../utils/app_constraints.dart';
import '../../utils/colors.dart';
import '../../utils/snackbar_utils.dart';
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
  final LocationController locationController = Get.put(LocationController());

  List<dynamic> postList = [];
  List<dynamic> mypostList = [];
  bool myPostLoading = false;
  late String uid = "";

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
    List<dynamic> filteredPosts = [];

    if (selectedCategoryGroup != null) {
      // Filter posts by selected category group
      filteredPosts = postList.where((post) {
        List<dynamic> postCategories = post['postCategoryList'];
        return postCategories.any((category) =>
        category['categoryGroup']['name'] == selectedCategoryGroup['name']);
      }).toList();

      // If specific categories are selected, further filter posts
      if (selectedCategories.isNotEmpty) {
        filteredPosts = filteredPosts.where((post) {
          List<dynamic> postCategories = post['postCategoryList'];
          return postCategories.any((category) =>
          selectedCategories.contains(category['name']) &&
              category['categoryGroup']['name'] == selectedCategoryGroup['name']);
        }).toList();
      }
    } else if (selectedCategories.isNotEmpty) {
      // No category group selected, but specific categories are selected
      filteredPosts = postList.where((post) {
        List<dynamic> postCategories = post['postCategoryList'];
        return postCategories.any((category) =>
            selectedCategories.contains(category['name']));
      }).toList();
    } else {
      // No category group or category selected, return all posts
      filteredPosts = postList.toList();
    }

    // Filter posts based on the search text
    if (filterText.isNotEmpty) {
      filteredPosts = filteredPosts.where((post) =>
          post['title'].toLowerCase().contains(filterText.toLowerCase())).toList(); // Convert to List
    }

    return filteredPosts;
  }

  List<dynamic> filterMyPostsByCategories() {
    List<dynamic> filteredPosts = [];

    if (selectedCategoryGroup != null) {
      // Filter posts by selected category group
      filteredPosts = mypostList.where((post) {
        List<dynamic> postCategories = post['postCategoryList'];
        return postCategories.any((category) =>
        category['categoryGroup']['name'] == selectedCategoryGroup['name']);
      }).toList();

      // If specific categories are selected, further filter posts
      if (selectedCategories.isNotEmpty) {
        filteredPosts = filteredPosts.where((post) {
          List<dynamic> postCategories = post['postCategoryList'];
          return postCategories.any((category) =>
          selectedCategories.contains(category['name']) &&
              category['categoryGroup']['name'] == selectedCategoryGroup['name']);
        }).toList();
      }
    } else if (selectedCategories.isNotEmpty) {
      // No category group selected, but specific categories are selected
      filteredPosts = mypostList.where((post) {
        List<dynamic> postCategories = post['postCategoryList'];
        return postCategories.any((category) =>
            selectedCategories.contains(category['name']));
      }).toList();
    } else {
      // No category group or category selected, return all posts
      filteredPosts = mypostList.toList();
    }

    // Filter posts based on the search text
    if (filterText.isNotEmpty) {
      filteredPosts = filteredPosts.where((post) =>
          post['title'].toLowerCase().contains(filterText.toLowerCase())).toList(); // Convert to List
    }

    return filteredPosts;
  }


  Future<void> _refreshData() async {
    uid = await AppConstrants.getUid();
    await postController.getPostList().then((result) {
      if (_isMounted) {
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
        mypostList.forEach((post) {
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

        final myPostToUpdate = mypostList.firstWhere((post) => post['id'] == postId, orElse: () => null);
        if (myPostToUpdate != null) {
          myPostToUpdate['isBookMarkActive'] = bookmarkedPosts['postId'] == postId && bookmarkedPosts['isActive'];
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
        mypostList.forEach((post) {
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

          final myPostToUpdate = postList.firstWhere((post) => post['id'] == postId, orElse: () => null);
          if (myPostToUpdate != null) {
            myPostToUpdate['isFlagActive'] = flagPosts['postId'] == postId && flagPosts['isActive'];
          }
        });
      }
    } catch (e) {
      print('Error loading flag posts: $e');
    }
  }

  Future<List<String>> getLocationNames(List<int> locationIds) async {
    List<String> locationNames = [];

    for (int locationId in locationIds) {
      final locations = await locationController.getLocationById(locationId);

      if (locations.isNotEmpty) {
        final locationName = locations[0]['locationName'];
        locationNames.add(locationName);
      }
    }

    return locationNames;
  }

/*
  Future<void> loadAndDisplayLocationNames(dynamic post) async {
    if (post['postLocationIdList'] != null) {
      List<int> locationIds = List<int>.from(post['postLocationIdList']);

      final locationNames = await getLocationNames(locationIds);
      // print("locationNames: "+locationNames.toString());

      if (_isMounted) {
        setState(() {
          post['postLocationNames'] = locationNames.join(', ');
        });
      }
    }
  }
*/

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

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    myPostLoading = true;
    Future.delayed(Duration(seconds: 1), () async {
      uid = await AppConstrants.getUid();
      await postController.getPostList().then((result) {
        if (_isMounted) {
          setState(() {
            postList = result;
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
      await postController.getPostByUidList().then((result) {
        if (_isMounted) {
          setState(() {
            mypostList = result;
            myPostLoading = false;
            mypostList.removeWhere((post) => post['postStatus'] == 'DISABLED');
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
                        'All',
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
                        final locationList = loadAndDisplayLocationNames(post);
                        loadAndDisplayCategoryNames(post);
                        // print("locationList: " + locationList.toString());
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
/*                                        IconAndTextWidget(
                                          icon: Icons.location_on,
                                          text: (post['postLocationNames'] as String?) ?? 'No Location',
                                          size: 15,
                                          iconColor: Colors.black,
                                        ),*/
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
                                          (post['postLocationNames'] as String?) ?? 'No Location',
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Gap(AppLayout.getHeight(10)),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.timer_sharp,
                                        color: Theme.of(context).iconTheme.color,
                                        size: AppLayout.getHeight(24),
                                      ),
                                      const Gap(5),
                                      post['lostDateFrom'] != null || post['lostDateTo'] != null ? Row(
                                        children: [
                                          Text(
                                            post['lostDateFrom'] != null
                                                ? DateFormat('dd-MM-yyyy').format(DateTime.parse(post['lostDateFrom']))
                                                : '',
                                            maxLines: 5,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          post['lostDateFrom'] != null && post['lostDateTo'] != null ? Text(" to ") : Text(""),
                                          Text(
                                            post['lostDateTo'] != null
                                                ? DateFormat('dd-MM-yyyy').format(DateTime.parse(post['lostDateTo']))
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
                                      post['user']['id'] == uid ? Container()  : IconButton(
                                        icon: post['isFlagActive'] ?? false
                                            ? Icon(Icons.flag, color: Theme.of(context).iconTheme.color, size: 30,)
                                            : Icon(Icons.flag_outlined, color: Theme.of(context).iconTheme.color, size: 30,),
                                        onPressed: () {
                                          String? selectedReason;

                                          if (post['isFlagActive'] ?? false) {
                                            flagPost(post['id'], "FALSE_INFORMATION");
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
                                          (post['postLocationNames'] as String?) ?? 'No Location',
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
                                        Icons.timer_sharp,
                                        color: Theme.of(context).iconTheme.color,
                                        size: AppLayout.getHeight(24),
                                      ),
                                      const Gap(5),
                                      post['lostDateFrom'] != null || post['lostDateTo'] != null ? Row(
                                        children: [
                                          Text(
                                            post['lostDateFrom'] != null
                                                ? DateFormat('dd-MM-yyyy').format(DateTime.parse(post['lostDateFrom']))
                                                : '',
                                            maxLines: 5,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          post['lostDateFrom'] != null && post['lostDateTo'] != null ? Text(" to ") : Text(""),
                                          Text(
                                            post['lostDateTo'] != null
                                                ? DateFormat('dd-MM-yyyy').format(DateTime.parse(post['lostDateTo']))
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
                                          text: getCommentCountForMyPost(post['id']).toString(),
                                          iconColor: Colors.grey),
                                      Text("")
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
