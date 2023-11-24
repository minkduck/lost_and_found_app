import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../routes/route_helper.dart';
import '../../../utils/app_constraints.dart';
import '../../../utils/snackbar_utils.dart';

class ReceiptController extends GetxController{
  late String accessToken = "";
  late String uid = "";

  Future<void> createReceipt(
      String receiverId,
      String senderId,
      int itemId,
      String media
      ) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.MultipartRequest('POST', Uri.parse(AppConstrants.POSTRECEIPT_URL));
    request.fields.addAll({
      "ReceiverId": receiverId,
      "SenderId": senderId,
      "ItemId": itemId.toString(),
      "ReceiptType": "RETURN_USER_TO_USER",
    });
    request.files.add(await http.MultipartFile.fromPath('image', media));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      SnackbarUtils().showSuccess(title: "Success", message: "Receipt item successfully");
      Get.toNamed(RouteHelper.getInitial(0));
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to create recepit');
    }
  }
}