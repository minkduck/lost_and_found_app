import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../routes/route_helper.dart';
import '../../../utils/app_constraints.dart';
import '../../../utils/snackbar_utils.dart';

class ReportController extends GetxController{
  late String accessToken = "";
  late String uid = "";

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  RxBool isLoading = false.obs;

  Future<void> createReport(
      String title,
      String postContent,
      String itemId,
      List<String> medias ) async {
    try {
      accessToken = await AppConstrants.getToken();
      var headers = {
        'Authorization': 'Bearer $accessToken'
      };
      var request = http.MultipartRequest('POST', Uri.parse(AppConstrants.POSTCREATEREPORT_URL));
      request.fields.addAll({
        'Title': title,
        'Content': postContent,
        'ItemId': itemId,
      });
      print(request.fields);

      for (var media in medias) {
        request.files.add(await http.MultipartFile.fromPath('Medias', media));
      }

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 201) {
        print('create report success');
        Get.toNamed(RouteHelper.getInitial(0));
        print(await response.stream.bytesToString());
        SnackbarUtils().showSuccess(title: "Success", message: "Create report successfully");
      }
      else {
        print(response.reasonPhrase);
        print(response.statusCode);
        throw Exception('Failed to create Post');
      }
    } catch (e) {
      isLoading.value = false;
      SnackbarUtils().showError(title: "Error", message: e.toString());
      print("Error creating the post: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<dynamic>> getReportById() async {
    accessToken = await AppConstrants.getToken();
    uid = await AppConstrants.getUid();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse(AppConstrants.GETREPORTBYUSERID_URL + uid));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _isLoaded = true;
      update();
      print("getReportById " + resultList.toString());
      return resultList;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getReportById');
    }
  }
  Future<List<dynamic>> getReportByItemIdAndUserId(int itemId) async {
    accessToken = await AppConstrants.getToken();
    uid = await AppConstrants.getUid();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.MultipartRequest('GET', Uri.parse('${AppConstrants.GETREPORTBYUSERIDANDITEMID_URL}$uid&itemId=$itemId'));
    request.fields.addAll({
      'userId': uid,
      'itemId': itemId.toString(),
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      update();
      print("getReportByItemIdAndUserId: $resultList");
      return resultList;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getReportByItemIdAndUserId');
    }
  }


}