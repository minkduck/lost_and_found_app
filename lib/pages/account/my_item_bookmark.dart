import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:lost_and_find_app/data/api/item/item_controller.dart';

import '../../test/time/time_widget.dart';
import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/app_button.dart';
import '../../widgets/big_text.dart';
import '../../widgets/icon_and_text_widget.dart';
import '../items/items_detail.dart';

class MyItemBookmark extends StatefulWidget {
  const MyItemBookmark({super.key});

  @override
  State<MyItemBookmark> createState() => _MyItemBookmarkState();
}

class _MyItemBookmarkState extends State<MyItemBookmark> {
  bool _isMounted = false;

  List<dynamic> itemBookmarkList = [];
  final ItemController itemController = Get.put(ItemController());

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

  Future<void> bookmarkItem(int itemId) async {
    try {
      await itemController.postBookmarkItemByItemId(itemId);

      // Manually update the bookmark status based on the isActive field
      setState(() {
        itemBookmarkList.forEach((item) {
          if (item['id'] == itemId) {
            item['isActive'] = !(item['isActive'] ?? false);
          }
        });
      });
    } catch (e) {
      print('Error bookmarking item: $e');
    }
  }

  Future<void> loadBookmarkedItems(int itemId) async {
    try {
      final bookmarkedItems = await itemController.getBookmarkedItems(itemId);
      if (_isMounted) {
        setState(() {
          // Update the isActive field for the specific item
          final itemToUpdate = itemBookmarkList.firstWhere((item) => item['id'] == itemId, orElse: () => null);
          if (itemToUpdate != null) {
            itemToUpdate['isActive'] = bookmarkedItems['itemId'] == itemId && bookmarkedItems['isActive'];
          }
        });
      }
    } catch (e) {
      print('Error loading bookmarked items for item $itemId: $e');
    }
  }
  
  Future<void> _refreshData() async {
    _isMounted = true;
    await itemController.getItemBookmark().then((result) {
      if (_isMounted) {
        setState(() {
          itemBookmarkList = result;

          Future<void> loadBookmarkedItemsForAllItems() async {
            for (final item in itemBookmarkList) {
              final itemIdForBookmark = item['id'];
              print(itemIdForBookmark);
              await loadBookmarkedItems(itemIdForBookmark);
            }
          }

          loadBookmarkedItemsForAllItems();
        });
      }
    }).whenComplete(() {
      if (_isMounted) {
        setState(() {
          if (itemBookmarkList.isEmpty) {
            _isMounted = false;
          }
        });
      }
    });
    
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isMounted = true;
    itemController.getItemBookmark().then((result) {
      if (_isMounted) {
        setState(() {
          itemBookmarkList = result;

          Future<void> loadBookmarkedItemsForAllItems() async {
            for (final item in itemBookmarkList) {
              final itemIdForBookmark = item['id'];
              print(itemIdForBookmark);
              await loadBookmarkedItems(itemIdForBookmark);
            }
          }

          loadBookmarkedItemsForAllItems();
        });
      }
    }).whenComplete(() {
      if (_isMounted) {
        setState(() {
          if (itemBookmarkList.isEmpty) {
            _isMounted = false;
          }
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
                    text: "Bookmark Items",
                    size: 20,
                    color: AppColors.secondPrimaryColor,
                    fontW: FontWeight.w500,
                  ),
                ],
              ),
              if (itemBookmarkList.isNotEmpty)
                Center(
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
                    itemCount: itemBookmarkList.length,
                    itemBuilder: (context, index) {
                      final item = itemBookmarkList[index];
                      final mediaUrl = getUrlFromItem(item) ??
                          "https://www.freeiconspng.com/thumbs/no-image-icon/no-image-icon-6.png";

                      return Container(
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: AppLayout.getHeight(140),
                              width: AppLayout.getWidth(180),
                              child: Image.network(
                                mediaUrl,
                                fit: BoxFit.fill,
                                errorBuilder: (context, error, stackTrace) {
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                        icon: item['isActive'] ?? false
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
                                  Gap(AppLayout.getHeight(15)),
                                  IconAndTextWidget(
                                    icon: Icons.location_on,
                                    text: item['locationName'] ?? 'No Location',
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
                                            ? '${TimeAgoWidget.formatTimeAgo(DateTime.parse(item['createdDate']))}'
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
                                      builder: (context) => ItemsDetails(
                                          pageId: item['id'], page: "item"),
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
              else if (itemBookmarkList.isEmpty && !_isMounted)
                SizedBox(
                  width: AppLayout.getScreenWidth(),
                  height: AppLayout.getScreenHeight()-200,
                  child: Center(
                    child: Text("You have not bookmark any item yet"),
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
