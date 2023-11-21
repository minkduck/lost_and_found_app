import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../routes/route_helper.dart';
import '../../../utils/app_constraints.dart';
import '../../../utils/snackbar_utils.dart';

class UserController extends GetxController {
  late String accessToken = "";
  late String uid = "";

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<Map<String, dynamic>> getUserByUid() async {
    accessToken = await AppConstrants.getToken();
    uid = await AppConstrants.getUid();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse(AppConstrants.GETUSERBYUID_URL +uid));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _isLoaded = true;
      update();
      print("getUser " + resultList.toString());
      return resultList;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getUserByUid');
    }
  }
  Future<void> putUserByPostId(String firstName,String lastName ,String male, String phone) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('PUT',
        Uri.parse(AppConstrants.PUTUSERBYUID_URL));
    request.body = json.encode({
      "firstName": firstName,
      "lastName": lastName,
      "gender": male,
      "phone": phone,
      "schoolId": "string"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      SnackbarUtils().showSuccess(title: "Success", message: "Update user information sucessful");
      Get.toNamed(RouteHelper.getInitial(3));
    }
    else {
      print(response.reasonPhrase);
      print(response.statusCode);
      throw Exception('Failed to put User');
    }
  }

  Future<String> putAvatarUser(String avatar) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.MultipartRequest('POST', Uri.parse(AppConstrants.POSTAVATARUSER_URL));
    request.files.add(await http.MultipartFile.fromPath('avatar', avatar));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final responseJson = json.decode(responseBody);

      if (responseJson['result'] != null) {
        return responseJson['result']['media']['url'];
      } else {
        return '';
      }
    } else {
      print(response.reasonPhrase);
      print(response.statusCode);
      return '';
    }
  }

  Future<Map<String, dynamic>> getUserByUserId(String id) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse('${AppConstrants.GETUSERBYUID_URL}$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _isLoaded = true;
      update();
      print("getUserByUserId " + resultList.toString());
      return resultList;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getUserByUserId');
    }
  }

}