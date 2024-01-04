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
        SnackbarUtils().showSuccess(title: "Success", message: "Create new report successfully");
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

}