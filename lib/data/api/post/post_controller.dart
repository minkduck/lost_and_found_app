import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../utils/app_constraints.dart';

class PostController extends GetxController{
  late String accessToken = "";

  List<dynamic> _postList = [];
  List<dynamic> get postList => _postList;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<List<dynamic>> getPostList() async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse(AppConstrants.GETPOSTWITHPAGINATION_URL));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _postList = resultList;
      _isLoaded = true;
      update();
      print("_postList $_postList");
      return resultList;
    } else {
      print(response.reasonPhrase);
      throw Exception('Failed to load Post');
    }
  }
  Future<Map<String, dynamic>> getPostListById(int id) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse(AppConstrants.GETPOSTBYID_URL +id.toString()));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _postList = resultList;
      _isLoaded = true;
      update();
      print("itemlistByid " + _postList.toString());
      return resultList;
    } else {
      print(response.reasonPhrase);
      throw Exception('Failed to load Item');
    }
  }

}