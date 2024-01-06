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
  Future<void> putUserByUserId(String firstName,String lastName ,String male, String phone, int campusId) async {
    accessToken = await AppConstrants.getToken();
    uid = await AppConstrants.getUid();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('PUT',
        Uri.parse("${AppConstrants.PUTUSERBYUID_URL}/$uid"));
    request.body = json.encode({
      "firstName": firstName,
      "lastName": lastName,
      "gender": male,
      "phone": phone,
      "campusId": campusId
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      SnackbarUtils().showSuccess(title: "Success", message: "Update user information successful");
      Get.toNamed(RouteHelper.getInitial(4));
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

  Future<Map<String, dynamic>> getUserByEmail(String email) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse('${AppConstrants.GETUSERBYEMAIL_URL}$email'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _isLoaded = true;
      update();
      print("getUserByEmail " + resultList.toString());
      return resultList;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getUserByEmail');
    }
  }

  Future<Map<String, dynamic>> getUserLoginByUserId(String id, String accessToken1) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken1'
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

  Future<void> verifyAccount(
      String schoolId,
      String CCIDFront,
      String CCIDBack,
      String StudentCard,
      ) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.MultipartRequest('POST', Uri.parse(AppConstrants.VERIFYACCOUNT_URL));
    request.fields.addAll({
      'SchoolId': schoolId
    });
    request.files.add(await http.MultipartFile.fromPath('CCIDFront', CCIDFront));
    request.files.add(await http.MultipartFile.fromPath('CCIDBack', CCIDBack));
    request.files.add(await http.MultipartFile.fromPath('StudentCard', StudentCard));
    request.headers.addAll(headers);
    print("request: " + request.fields.toString());
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      SnackbarUtils().showSuccess(title: "Success", message: "Request verify account successful");
      Get.toNamed(RouteHelper.getInitial(4));

    }
    else {
      print(response.reasonPhrase);
      print(response.statusCode);
      throw Exception('Failed to verifyAccount');
    }
  }

}