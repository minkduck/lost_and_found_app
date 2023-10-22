

import 'package:lost_and_find_app/data/api/category/category_controller.dart';
import 'package:lost_and_find_app/data/api/item/item_controller.dart';
import 'package:lost_and_find_app/data/api/location/location_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../data/api/api_clients.dart';

import '../data/api/post/post_controller.dart';
import '../utils/app_constraints.dart';


Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  Get.lazyPut(() => sharedPreferences);
  //api client
  Get.lazyPut(() => ApiClient(appBaseUrl: AppConstrants.BASE_URL));

  //item
  Get.lazyPut(() => ItemController());

  //location
  Get.lazyPut(() => LocationController());

  //category
  Get.lazyPut(() => CategoryController());

  //post
  Get.lazyPut(() => PostController());

}
