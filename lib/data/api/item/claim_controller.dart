import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../routes/route_helper.dart';
import '../../../utils/app_constraints.dart';
import '../../../utils/snackbar_utils.dart';

class ClaimController extends GetxController{
  late String accessToken = "";

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;
  Future<void> postClaimByItemId(int itemId) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('POST', Uri.parse(AppConstrants.POSTCLAIMITEM_URL + itemId.toString()));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      SnackbarUtils().showSuccess(title: "Successs", message: "Claim item successfully");
    }
    else {
      print(response.reasonPhrase);
      print(response.statusCode);
      throw Exception('Failed to claim Item');
    }

  }
  Future<void> postUnClaimByItemId(int itemId) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('POST', Uri.parse(AppConstrants.POSTUNCLAIMITEM_URL + itemId.toString()));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 204) {
      print(await response.stream.bytesToString());
      SnackbarUtils().showSuccess(title: "Successs", message: "Unclaim item successfully");
    }
    else {
      print(response.reasonPhrase);
      print(response.statusCode);
      throw Exception('Failed to unclaimed Item');
    }

  }

}