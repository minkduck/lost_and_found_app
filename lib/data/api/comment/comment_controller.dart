import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../utils/app_constraints.dart';

class CommentController extends GetxController {
  late String accessToken = "";

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<List<dynamic>> getCommentByPostId(int PostId) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request(
        'GET',
        Uri.parse(AppConstrants.GETCOMMENTBYPOSTBID_URL + PostId.toString()));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _isLoaded = true;
      update();
      print("commentList " + resultList.toString());
      return resultList;
    } else {
      print(response.reasonPhrase);
      throw Exception('Failed to load Comment');
    }
  }

  Future<void> postCommentByPostId(int postId, String comment) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request(
        'POST',
        Uri.parse(AppConstrants.POSTCOMMENTREPLYBYPOSTID_URL + postId.toString()));

    request.body = json.encode({
      "commentContent": comment
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201) {
      print(await response.stream.bytesToString());

    } else {
      print(response.reasonPhrase);
      print(response.statusCode);
      throw Exception('Failed to post Comment');
    }
  }

}