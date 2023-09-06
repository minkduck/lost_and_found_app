import 'package:get/get.dart';

class Dimensions {

  static double screenHeight = Get.context!.height;
  static double screenWidth = Get.context!.width;

  static double pageView = screenHeight/2;
  static double pageViewContainer = screenHeight/2.9;
  static double pageViewTextContainer = screenHeight/5.2;

//dynamic height padding and margin
  static double height10 = screenHeight/ 64;
  static double height15 = screenHeight/ 42.67;
  static double height20 = screenHeight/ 32;
  static double height30 = screenHeight/ 21.3;
  static double height45 = screenHeight/ 14.2;

//dynamic width padding and margin
  static double width10 = screenHeight/ 64;
  static double width15 = screenHeight/ 42.67;
  static double width20 = screenHeight/ 32;
  static double width25 = screenHeight/ 25.6;
  static double width30 = screenHeight/ 21.3;

  //font size
  static double font16 = screenHeight/40;
  static double font20 = screenHeight/32;
  static double font26 = screenHeight/24.6;

  //radius
  static double radius15 = screenHeight/42.6;
  static double radius20 = screenHeight/32;
  static double radius30 = screenHeight /21.3;

  static double iconSize24 = screenHeight/26.67;
  static double iconSize16 = screenHeight/40;

  static double listViewImgSize = screenWidth/5.8;
  static double listViewTextContSize = screenWidth/7.111;

  // popular food
static double popularFoodImgSize = screenHeight/2.7;

//bottom height
static double bottomHeightBar = screenHeight/5.333;

//splash screen dimensions
static double splashImng = screenHeight/2.56;

}