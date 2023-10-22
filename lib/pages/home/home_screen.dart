import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lost_and_find_app/data/api/category/category_controller.dart';
import 'package:lost_and_find_app/data/model/item/item_model.dart';
import 'package:lost_and_find_app/pages/items/create_item.dart';
import 'package:lost_and_find_app/utils/app_layout.dart';
import 'package:lost_and_find_app/widgets/big_text.dart';
import 'package:get/get.dart';

import '../../data/api/item/item_controller.dart';
import '../../routes/route_helper.dart';
import '../../test/other/cagory.dart';
import '../../utils/app_assets.dart';
import '../../utils/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/icon_and_text_widget.dart';
import '../items/items_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> categoryList = [
    // 'All',
    // 'Mobile',
    // 'Documents',
    // 'Laptop',
    // 'Paper',
    // 'Card',
    // 'Panel'
  ];
  final CategoryController categoryController = Get.put(CategoryController());
  List<String> selectedCategories = [];
  List<dynamic> itemlist = [];
  final ItemController itemController = Get.put(ItemController());

  bool _isMounted = false;

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
    // Return a default URL or null if no URL is found.
    return "https://wowmart.vn/wp-content/uploads/2020/10/null-image.png";
  }

  List<dynamic> filterItemsByCategories(List<String> selectedCategories) {
    return itemlist.where((item) {
      return selectedCategories.contains(item['categoryName']);
    }).toList();
  }

  Future<void> _refreshData() async {
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
  }

  @override
  void initState() {
    super.initState();
    _isMounted = true;
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
                        text: "Home",
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
                    )
                  ],
                ),
                Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'All',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                ),
                Gap(AppLayout.getHeight(25)),
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
                Gap(AppLayout.getHeight(25)),
                itemlist.isNotEmpty
                    ? Center(
                  child: GridView.builder(
                    padding: EdgeInsets.all(15),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: AppLayout.getWidth(200),
                      childAspectRatio: 0.55,
                      crossAxisSpacing: AppLayout.getWidth(20),
                      mainAxisSpacing: AppLayout.getHeight(20),
                    ),
                    itemCount: selectedCategories.isNotEmpty
                        ? filterItemsByCategories(selectedCategories).length
                        : itemlist.length,
                    itemBuilder: (context, index) {
                      final List<dynamic> filteredItems = selectedCategories.isNotEmpty
                          ? filterItemsByCategories(selectedCategories)
                          : itemlist;

                      final item = filteredItems[index];
                      final mediaUrl = getUrlFromItem(item) ?? "https://wowmart.vn/wp-content/uploads/2020/10/null-image.png";

                      return Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: AppLayout.getHeight(151),
                              width: AppLayout.getWidth(180),
                              child: Image.network(
                                  mediaUrl,
                                  fit: BoxFit.fill,
                                errorBuilder: (context, error, stackTrace) {
                                  // Handle image loading errors
                                  return Image.network("https://wowmart.vn/wp-content/uploads/2020/10/null-image.png", fit: BoxFit.fill);
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Gap(AppLayout.getHeight(8)),
                                  Text(
                                    item['name'] ?? 'No Name',                                  maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Gap(AppLayout.getHeight(15)),
                                  IconAndTextWidget(
                                    icon: Icons.location_on,
                                    text: item['LocationName'] ?? 'No Location',
                                    size: 15,
                                    iconColor: Colors.black,
                                  ),
                                  Gap(AppLayout.getWidth(15)),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        item['createdDate'] != null
                                            ? DateFormat('dd-MM-yyyy').format(DateTime.parse(item['createdDate']))
                                            : 'No Date',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Spacer(),
                            Container(
                              child: AppButton(
                                boxColor: AppColors.secondPrimaryColor,
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
                                      builder: (context) => ItemsDetails(pageId: item['id'], page: "item"),
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
                ),

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