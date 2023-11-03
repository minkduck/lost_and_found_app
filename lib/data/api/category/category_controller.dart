import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../utils/app_constraints.dart';

class CategoryController extends GetxController{
  late String accessToken = "";

  List<dynamic> _categoryList = [];
  List<dynamic> get categoryList => _categoryList;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<List<dynamic>> getCategoryList() async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse(AppConstrants.GETCATEGORYWITHPAGINATION_URL));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _categoryList = resultList;
      _isLoaded = true;
      update();
      print("_categoryList " + _categoryList.toString());
      return resultList;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load Category');
    }
  }

}
