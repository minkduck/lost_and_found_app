import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lost_and_find_app/data/api/category/category_controller.dart';
import 'package:lost_and_find_app/pages/items/create_item.dart';
import 'package:lost_and_find_app/utils/app_constraints.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/widgets/big_text.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/api/item/item_controller.dart';
import '../../routes/route_helper.dart';
import '../../test/other/cagory.dart';
import '../../test/time/time_widget.dart';
import '../../utils/app_assets.dart';
import '../../utils/colors.dart';
import '../../utils/snackbar_utils.dart';
import '../../widgets/app_button.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/icon_and_text_widget.dart';
import '../../widgets/time_ago_found_widget.dart';
import '../items/item_details_return.dart';
import '../items/items_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> categoryList = [];
  List<dynamic> categoryGroupList = [];
  List<String> selectedCategories = [];
  dynamic selectedCategoryGroup;
  dynamic previouslySelectedCategoryGroup;
  final CategoryController categoryController = Get.put(CategoryController());

  List<dynamic> itemlist = [];
  List<dynamic> myItemlist = [];
  List<dynamic> returnItemlist = [];

  bool myItemsLoading = false;
  bool itemsLoading = false;
  bool returnItemsLoading = false;

  late String uid = "";
  bool? loadingFinished = false;
  final ItemController itemController = Get.put(ItemController());
  String filterText = '';
  bool itemsSelected = true;
  bool myItemsSelected = false;
  bool returnItemsSelected = false;

  bool _isMounted = false;
  String? firstLogin = '';

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

  void firstLoged() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    firstLogin = prefs.getString('firstLogin');
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

  List<dynamic> filterItemsByCategories() {
    // Apply category filtering first
    final List<dynamic> filteredByCategories = selectedCategoryGroup == null
        ? itemlist
        : itemlist.where((item) {
      final category = item['categoryName'];
      return selectedCategoryGroup['categories']
          .any((selectedCategory) => selectedCategory['name'] == category);
    }).toList();

    // Apply text filter
    final filteredByText = filteredByCategories
        .where((item) =>
    selectedCategories.isEmpty ||
        selectedCategories.contains(item['categoryName']))
        .where((item) =>
    filterText.isEmpty ||
        (item['name'] != null &&
            item['name'].toLowerCase().contains(filterText.toLowerCase())))
        .toList();

    return filteredByText;
  }

  List<dynamic> filterMyItemsByCategories() {
    // Apply category filtering first
    final List<dynamic> filteredByCategories = selectedCategoryGroup == null
        ? myItemlist
        : myItemlist.where((item) {
      final category = item['categoryName'];
      return selectedCategoryGroup['categories']
          .any((selectedCategory) => selectedCategory['name'] == category);
    }).toList();

    // Apply text filter
    final filteredByText = filteredByCategories
        .where((item) =>
    selectedCategories.isEmpty ||
        selectedCategories.contains(item['categoryName']))
        .where((item) =>
    filterText.isEmpty ||
        (item['name'] != null &&
            item['name'].toLowerCase().contains(filterText.toLowerCase())))
        .toList();

    return filteredByText;
  }

  List<dynamic> filterReturnItemsByCategories() {
    // Apply category filtering first
    final List<dynamic> filteredByCategories = selectedCategoryGroup == null
        ? returnItemlist
        : returnItemlist.where((item) {
      final category = item['categoryName'];
      return selectedCategoryGroup['categories']
          .any((selectedCategory) => selectedCategory['name'] == category);
    }).toList();

    // Apply text filter
    final filteredByText = filteredByCategories
        .where((item) =>
    selectedCategories.isEmpty ||
        selectedCategories.contains(item['categoryName']))
        .where((item) =>
    filterText.isEmpty ||
        (item['name'] != null &&
            item['name'].toLowerCase().contains(filterText.toLowerCase())))
        .toList();

    return filteredByText;
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
        myItemlist.forEach((item) {
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

        final myItemToUpdate = myItemlist.firstWhere((item) => item['id'] == itemId, orElse: () => null);
        if (myItemToUpdate != null) {
          myItemToUpdate['isBookMarkActive'] = bookmarkedItems['itemId'] == itemId && bookmarkedItems['isActive'];
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
        myItemlist.forEach((item) {
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

        final myItemToUpdate = myItemlist.firstWhere((item) => item['id'] == itemId, orElse: () => null);
        if (myItemToUpdate != null) {
          myItemToUpdate['isFlagActive'] = flagItems['itemId'] == itemId && flagItems['isActive'];
        }
      });
    }
  }

  Future<void> _refreshData() async {
    _isMounted = true;
    uid = await AppConstrants.getUid();
    await itemController.getItemList().then((result) async {
      if (_isMounted) {
        setState(() {
          itemlist = result;
          itemsLoading = false;

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
    await categoryController.getCategoryList().then((result) {
      if (_isMounted) {
        setState(() {
          categoryList = result;
        });
      }
    });
    await itemController.getItemByUidList().then((result) {
      if (_isMounted) {
        setState(() {
          myItemlist = result;
        });
      }
    });
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
    myItemsLoading = true;
    itemsLoading = true;
    Future.delayed(Duration(seconds: 1), () async {
      uid = await AppConstrants.getUid();
      await itemController.getItemList().then((result) {
        if (_isMounted) {
          setState(() {
            itemlist = result;
            itemsLoading = false;

            Future.forEach(itemlist, (item) async {
              final itemIdForBookmark = item['id'];
              await loadBookmarkedItems(itemIdForBookmark);
            });
            Future.forEach(itemlist, (item) async {
              final itemIdForFlag = item['id'];
              await loadFlagItems(itemIdForFlag);
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
      await itemController.getItemByUidList().then((result) {
        if (_isMounted) {
          setState(() {
            myItemlist = result;
            myItemsLoading = false;

            Future.forEach(myItemlist, (item) async {
              final itemIdForBookmark = item['id'];
              await loadBookmarkedItems(itemIdForBookmark);
            });
            Future.forEach(myItemlist, (item) async {
              final itemIdForFlag = item['id'];
              await loadFlagItems(itemIdForFlag);
            });
          });
        }
      });
      await categoryController.getCategoryGroupList().then((result) {
        if (_isMounted) {
          setState(() {
            categoryGroupList = result;
          });
        }
      });
      await itemController.getReturnItem().then((result) {
        if (_isMounted) {
          setState(() {
            returnItemlist = result;
            returnItemsLoading = false;

          });
        }
      });
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
    loadingFinished = false;
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = filterItemsByCategories();
    final filteredMyItems = filterMyItemsByCategories();
    final filteredReturnItems = filterReturnItemsByCategories();
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
                        text: "Home",
                        size: 20,
                        color: AppColors.secondPrimaryColor,
                        fontW: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomSearchBar(
                      filterText: filterText,
                      // Pass the filter text
                      onFilterTextChanged: onFilterTextChanged,
                      // Set the filter text handler
                      onSubmitted: onSubmitted,
                    ),
                  ],
                ),
                Gap(AppLayout.getHeight(15)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AppButton(
                      boxColor: itemsSelected
                          ? AppColors.primaryColor
                          : AppColors.secondPrimaryColor,
                      textButton: "Items",
                      fontSize: 15,
                      width: AppLayout.getWidth(100),
                      height: AppLayout.getHeight(35),
                      onTap: () {
                        setState(() {
                          itemsSelected = true;
                          myItemsSelected = false;
                          returnItemsSelected = false;
                        });
                      },
                    ),
                    AppButton(
                      boxColor: myItemsSelected
                          ? AppColors.primaryColor
                          : AppColors.secondPrimaryColor,
                      textButton: "My Items",
                      fontSize: 15,
                      width: AppLayout.getWidth(100),
                      height: AppLayout.getHeight(35),
                      onTap: () {
                        setState(() {
                          itemsSelected = false;
                          myItemsSelected = true;
                          returnItemsSelected = false;
                        });
                      },
                    ),
                    AppButton(
                      boxColor: returnItemsSelected
                          ? AppColors.primaryColor
                          : AppColors.secondPrimaryColor,
                      textButton: "Returned Items",
                      fontSize: 15,
                      width: AppLayout.getWidth(150),
                      height: AppLayout.getHeight(35),
                      onTap: () {
                        setState(() {
                          itemsSelected = false;
                          myItemsSelected = false;
                          returnItemsSelected = true;
                        });
                      },
                    ),
                  ],
                ),
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
                Gap(AppLayout.getHeight(25)),
                GetBuilder<ItemController>(builder: (item) {
                  return itemsLoading ? SizedBox(
                    width: AppLayout.getWidth(100),
                    height: AppLayout.getHeight(300),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ) :
                    itemsSelected
                      ? itemlist.isNotEmpty & categoryGroupList.isNotEmpty
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
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = filteredItems[index];
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
                                          height: AppLayout.getHeight(112),
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
                                        Spacer(),
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
                         : SizedBox(
                      width: AppLayout.getScreenWidth(),
                      height: AppLayout.getScreenHeight() - 400,
                      child: Center(
                        child: Text(""),
                      ),
                    )
                      : myItemsSelected // Check if the "My Items" button is selected
                      ? myItemsLoading ? SizedBox(
                    width: AppLayout.getWidth(100),
                    height: AppLayout.getHeight(300),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ) :
                              myItemlist.isNotEmpty & categoryGroupList.isNotEmpty
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
                      itemCount: filteredMyItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredMyItems[index];
                        final mediaUrl = getUrlFromItem(item) ??
                            "https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg";
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
                                height: AppLayout.getHeight(132),
                                width: AppLayout.getWidth(180),
                                child: Image.network(
                                  mediaUrl,
                                  fit: BoxFit.fill,
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    // Handle image loading errors
                                    return Image.network(
                                        "https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg",
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
                                        IconButton(
                                          icon: item['isBookMarkActive'] ?? false
                                              ? Icon(Icons.bookmark,
                                              color: AppColors.secondPrimaryColor)
                                              : Icon(Icons.bookmark_outline,
                                              color: AppColors.secondPrimaryColor),
                                          onPressed: () {
                                            bookmarkItem(item['id']);
                                          },
                                        ),
                                      ],
                                    ),
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
                                    Gap(AppLayout.getWidth(15)),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: Align(
                                        alignment:
                                        Alignment.centerLeft,
                                        child: Text(
                                          item['foundDate']??'No date',
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
                              Spacer(),
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
                                  : SizedBox(
                                width: AppLayout.getScreenWidth(),
                                height: AppLayout.getScreenHeight()-400,
                                child: Center(
                                  child: Text("You haven't created any items yet"),
                                ),
                              )
                    : returnItemsSelected
                        ? returnItemsLoading ? SizedBox(
                      width: AppLayout.getWidth(100),
                      height: AppLayout.getHeight(300),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ) :
                    returnItemlist.isNotEmpty & categoryGroupList.isNotEmpty
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
                        itemCount: filteredReturnItems.length,
                        itemBuilder: (context, index) {
                          final item = filteredReturnItems[index];
                          final mediaUrl = getUrlFromItem(item) ??
                              "https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg";
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
                                  height: AppLayout.getHeight(140),
                                  width: AppLayout.getWidth(180),
                                  child: Image.network(
                                    mediaUrl,
                                    fit: BoxFit.fill,
                                    errorBuilder:
                                        (context, error, stackTrace) {
                                      // Handle image loading errors
                                      return Image.network(
                                          "https://png.pngtree.com/png-vector/20190820/ourmid/pngtree-no-image-vector-illustration-isolated-png-image_1694547.jpg",
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
                                      Gap(AppLayout.getHeight(20)),
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
                                      Gap(AppLayout.getWidth(15)),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Align(
                                          alignment:
                                          Alignment.centerLeft,
                                          child: Text(
                                            item['foundDate']??'No date',
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
                                Spacer(),
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
                                              ItemDetailsReturn(
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
                      width: AppLayout.getScreenWidth(),
                      height: AppLayout.getScreenHeight()-400,
                      child: Center(
                        child: Text("It doesn't have any return items"),
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
              context, MaterialPageRoute(builder: (context) => CreateItem()));
        },
        tooltip: 'Create Items',
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
