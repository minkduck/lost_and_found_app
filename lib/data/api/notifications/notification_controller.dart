import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../routes/route_helper.dart';
import '../../../utils/app_constraints.dart';
import '../../../utils/snackbar_utils.dart';

class NotificationController extends GetxController {
  late String accessToken = "";
  late String uid = "";

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<List<dynamic>> getNotificationListByUserId() async {
    accessToken = await AppConstrants.getToken();
    uid = await AppConstrants.getUid();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse(AppConstrants.GETALLNOTIBYUSERID + uid));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);
      final resultList = jsonResponse['result'];
      _isLoaded = true;
      update();
      return resultList;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getNotificationListByUserId');
    }
  }

  Future<void> pushNotifications(
      String userId,
      String title,
      String content,
      String notificationType
      ) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('POST', Uri.parse(AppConstrants.PUSHNOTIFICATIONS));
    request.body = json.encode({
      "userId": userId,
      "title": title,
      "content": content,
      "notificationType": notificationType
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    }
    else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to pushNotifications');
    }
  }
}