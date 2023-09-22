
import 'package:lost_and_find_app/data/api/auth/login_email_pass_controller.dart';
import 'package:lost_and_find_app/data/api/auth/login_email_pass_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import '../data/api/api_clients.dart';

import '../utils/app_constraints.dart';


Future<void> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  Get.lazyPut(() => sharedPreferences);
  //api client
  Get.lazyPut(() => ApiClient(appBaseUrl: AppConstrants.BASE_URL));

  //project
  Get.lazyPut(() => LoginEmailPasswordRepo(apiClient: Get.find()));
  Get.lazyPut(() => LoginEmailPasswordController(loginEmailPasswordRepo: Get.find()));

}
