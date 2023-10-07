import 'package:get/get.dart';
import 'package:lost_and_find_app/pages/home_login_page.dart';


class RouteHelper{
  static const String splashPage = "/splash-page";
  static const String initial = "/";


  static String getInitial() => '$initial' ;


  static List<GetPage> routes = [
    GetPage(name: initial, page: () => const HomeLoginPage()),

  ];

}