import 'package:get/get.dart';
import 'package:lost_and_find_app/pages/home_login_page.dart';
import 'package:lost_and_find_app/pages/items/items_detail.dart';

class RouteHelper {
  static const String splashPage = "/splash-page";
  static const String initial = "/";
  static const String item = "/item";
  static const String post = "/post";

  static String getInitial(int initialIndex) => '$initial?initialIndex=$initialIndex';
  static String getItem(int pageId, String page) {
    // Ensure that pageId and page are not null
    pageId ??= 0;
    page ??= 'default'; // Provide a default value if page is null

    return '$item?pageId=$pageId&page=$page';
  }

  static List<GetPage> routes = [
    GetPage(
      name: initial,
      page: () {
        var initialIndex = int.tryParse(Get.parameters['initialIndex'] ?? '0');
        return HomeLoginPage(initialIndex: initialIndex ?? 0);
      },
    ),
    GetPage(
      name: item,
      page: () {
        var pageId = int.tryParse(Get.parameters['pageId'] ?? '0');
        var page = Get.parameters['page'] ?? 'default';
        return ItemsDetails(pageId: pageId!, page: page);
      },
      transition: Transition.fadeIn,
    ),
  ];
}
