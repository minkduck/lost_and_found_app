import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lost_and_find_app/data/api/category/category_controller.dart';
import 'package:lost_and_find_app/data/model/item/item_model.dart';
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
import '../../widgets/app_button.dart';
import '../../widgets/custom_search_bar.dart';
import '../../widgets/icon_and_text_widget.dart';
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
  bool myItemsLoading = false;
  final ItemController itemController = Get.put(ItemController());
  String filterText = '';
  bool itemsSelected = true;
  bool myItemsSelected = false;

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

  Future<void> _refreshData() async {
    _isMounted = true;
    await itemController.getItemList().then((result) {
      if (_isMounted) {
        setState(() {
          itemlist = result;
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
    setState(() {
      firstLoged();
    });
    if (firstLogin == 'firstLogin') {
      Future.delayed(Duration(seconds: 3), () {
        itemController.getItemList().then((result) {
          if (_isMounted) {
            setState(() {
              itemlist = result;
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
        categoryController.getCategoryGroupList().then((result) {
          if (_isMounted) {
            setState(() {
              categoryGroupList = result;
            });
          }
        });
      });
      setState(() {
        firstLogin = 'h';
      });
    } else {
      Future.delayed(Duration(seconds: 1), () async {
        await itemController.getItemList().then((result) {
          if (_isMounted) {
            setState(() {
              itemlist = result;
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
      });
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = filterItemsByCategories();
    final filteredMyItems = filterMyItemsByCategories();
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
                        width: AppLayout.getWidth(150),
                        height: AppLayout.getHeight(35),
                        onTap: () {
                          setState(() {
                            itemsSelected = true;
                            myItemsSelected = false;
                          });
                        }),
                    AppButton(
                        boxColor: myItemsSelected
                            ? AppColors.primaryColor
                            : AppColors.secondPrimaryColor,
                        textButton: "My Items",
                        width: AppLayout.getWidth(150),
                        height: AppLayout.getHeight(35),
                        onTap: () {
                          setState(() {
                            itemsSelected = false;
                            myItemsSelected = true;
                          });
                        })
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
                  return itemsSelected
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
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = filteredItems[index];
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
                              width: AppLayout.getWidth(100),
                              height: AppLayout.getHeight(300),
                              child: const Center(
                                child: CircularProgressIndicator(),
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
                              myItemlist.isNotEmpty // Render myItemList grid view when My Items button is selected
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
                  ) : SizedBox(
                                width: AppLayout.getScreenWidth(),
                                height: AppLayout.getScreenHeight()-400,
                                child: Center(
                                  child: Text("You haven't created any items yet"),
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
