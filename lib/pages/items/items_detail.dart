import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:lost_and_find_app/utils/app_assets.dart';
import 'package:lost_and_find_app/widgets/app_button.dart';
import 'package:lost_and_find_app/widgets/icon_and_text_widget.dart';
import 'package:lost_and_find_app/widgets/small_text.dart';
import 'package:lost_and_find_app/widgets/status_widget.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:get/get.dart';

import '../../data/api/item/item_controller.dart';
import '../../routes/route_helper.dart';
import '../../utils/app_layout.dart';
import '../../utils/colors.dart';
import '../../widgets/big_text.dart';

class ItemsDetails extends StatefulWidget {
  final int pageId;
  final String page;
  const ItemsDetails({Key? key, required this.pageId, required this.page}) : super(key: key);

  @override
  State<ItemsDetails> createState() => _ItemsDetailsState();
}


class _ItemsDetailsState extends State<ItemsDetails> {

  late List<String> imageUrls = [
    // AppAssets.airpods,
    // AppAssets.airpods,
    // AppAssets.airpods,
    // AppAssets.airpods,
  ];
  final PageController _pageController = PageController();
  double currentPage = 0;

  bool _isMounted = false;

  Map<String, dynamic> itemlist = {};
  final ItemController itemController = Get.put(ItemController());

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page ?? 0;
      });
    });
    _isMounted = true;
    itemController.getItemListById(widget.pageId).then((result) {
      if (_isMounted) {
        setState(() {
          itemlist = result;
          if (itemlist != null) {
            var itemMedias = itemlist['itemMedias'];

            if (itemMedias != null && itemMedias is List) {
              List mediaList = itemMedias;

              for (var media in mediaList) {
                String imageUrl = media['media']['url'];
                imageUrls.add(imageUrl);
              }
            }
          }
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: itemlist.isNotEmpty ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            // Align children to the left
            children: [
              Gap(AppLayout.getHeight(20)),
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
                    text: "Items",
                    size: 20,
                    color: AppColors.secondPrimaryColor,
                    fontW: FontWeight.w500,
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: AppLayout.getWidth(30), top: AppLayout.getHeight(10)),
                child: Text('Items', style: Theme.of(context).textTheme.displayMedium,),
              ),
              Gap(AppLayout.getHeight(20)),

              Container(
                margin: EdgeInsets.only(left: 20),
                height: AppLayout.getHeight(350),
                width: AppLayout.getWidth(350),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(imageUrls[index]??"https://wowmart.vn/wp-content/uploads/2020/10/null-image.png",fit: BoxFit.fill,));
                    // child: Image.network(imageUrls[index],fit: BoxFit.fill,));               );
                  },
                ),
              ),
              Center(
                child: DotsIndicator(
                  dotsCount: imageUrls.isEmpty ? 1 : imageUrls.length,
                  position: currentPage,
                  decorator: const DotsDecorator(
                    size: Size.square(10.0),
                    activeSize: Size(20.0, 10.0),
                    activeColor: Colors.blue,
                    spacing: EdgeInsets.all(3.0),
                  ),
                ),
              ),
              Gap(AppLayout.getHeight(20)),
              // Container(
              //     padding: EdgeInsets.only(left: AppLayout.getWidth(20)),
              //     child: StatusWidget(text: "Found", color: Colors.grey)),
              Padding(
                padding: EdgeInsets.only(
                    left: AppLayout.getWidth(16), top: AppLayout.getHeight(16)),
                child: Text(
                  itemlist.isNotEmpty 
                      ? itemlist['name']
                      : 'No Name', // Provide a default message if item is not found
                  style: Theme.of(context).textTheme.labelMedium,
                ),

              ),
              // time
              Container(
                  padding: EdgeInsets.only(
                      left: AppLayout.getWidth(16),
                      top: AppLayout.getHeight(8)),
                  child: IconAndTextWidget(
                      icon: Icons.timer_sharp,
                      text: itemlist['createdDate'] != null
                          ? DateFormat('dd-MM-yyyy').format(DateTime.parse(itemlist['createdDate']))
                          : 'No Date',
                      iconColor: Colors.grey)),
              //location
              Container(
                  padding: EdgeInsets.only(
                      left: AppLayout.getWidth(16),
                      top: AppLayout.getHeight(8)),
                  child: IconAndTextWidget(
                      icon: Icons.location_on,
                      text: itemlist.isNotEmpty 
                          ? itemlist['LocationName']
                          : 'No Location',
                      iconColor: Colors.black)),
              //description
              Gap(AppLayout.getHeight(10)),
              Container(
                  padding: EdgeInsets.only(
                      left: AppLayout.getWidth(18),
                      top: AppLayout.getHeight(8)),
                  child: SmallText(
                    text: itemlist.isNotEmpty 
                        ? itemlist['description']
                        : 'No Description',
                    size: 15,
                  )),
              //profile user
              Gap(AppLayout.getHeight(10)),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        left: AppLayout.getWidth(16),
                        top: AppLayout.getHeight(8)),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[500],
                      radius: 50,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(itemlist['user']['avatar']??"https://wowmart.vn/wp-content/uploads/2020/10/null-image.png"),
                      ),
                    ),
                  ),
                  Gap(AppLayout.getHeight(50)),
                  Text(
                    itemlist.isNotEmpty
                      ? itemlist['user']['fullName'] :
                      'No Name', style: TextStyle(fontSize: 20),)
                ],
              ),
              Gap(AppLayout.getHeight(40)),
              Center(
                  child: AppButton(boxColor: AppColors.secondPrimaryColor, textButton: "Send Message", onTap: () {})),
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
      ),
    );
  }
}
