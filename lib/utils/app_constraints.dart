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

  static void init() async {
    TOKEN = await getToken();
  }

  static const String LOGINGOOGLE_URL = "$BASE_URL/auth/googleLoginAuthenticate";
  static const String PROJECT_URL = "/api/v1/projects";
  static const String POST_URL = "/api/v1/posts";
  static const String STUDENT_URL = "/api/v1/students";
  static const String CATEGORY_URL = "/api/v1/categories";
  static const String MAJOR_URL = "/api/v1/majors";
  static const String ROLE_URL = "/api/v1/roles";



}