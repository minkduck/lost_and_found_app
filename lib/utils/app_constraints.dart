import 'package:shared_preferences/shared_preferences.dart';

class AppConstrants{

  static Future<String> getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') ?? '';
  }
  static Future<String> getFcmToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcmToken') ?? '';
  }

  static const String APP_NAME = "Lost&Find";
  static const int APP_VERSION = 1;

  static const String BASE_URL = "https://lostandfound.io.vn";
  static String TOKEN = '';


  //auth
  static const String LOGINGOOGLE_URL = "$BASE_URL/auth/googleLoginAuthenticate";
  static const String AUTHENTICATE_URL = "$BASE_URL/auth/authenticate?userDeviceToken=";

  //category
  static const String GETCATEGORYWITHPAGINATION_URL = "$BASE_URL/api/categories";

  //item
  static const String GETITEMWITHPAGINATION_URL = "$BASE_URL/api/items?ItemStatus=";
  static const String GETITEMBYID_URL = "$BASE_URL/api/items/id/";

  //post
  static const String GETPOSTWITHPAGINATION_URL = "$BASE_URL/api/posts";
  static const String GETPOSTBYID_URL = "$BASE_URL/api/posts/";

}