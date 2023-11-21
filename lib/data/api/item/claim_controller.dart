import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../routes/route_helper.dart';
import '../../../utils/app_constraints.dart';
import '../../../utils/snackbar_utils.dart';

class ClaimController extends GetxController{
  late String accessToken = "";
  late String uid = "";

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

    if (response.statusCode == 204) {
      print(await response.stream.bytesToString());
      SnackbarUtils().showSuccess(title: "Success", message: "Claim item successfully");
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
      SnackbarUtils().showSuccess(title: "Success", message: "Unclaim item successfully");
    }
    else {
      print(response.reasonPhrase);
      print(response.statusCode);
      throw Exception('Failed to unclaimed Item');
    }

  }
  Future<List<dynamic>> getItemClaimByUidList() async {
    accessToken = await AppConstrants.getToken();
    uid = await AppConstrants.getUid();
    // uid = 'FLtIEJvuMgfg58u4sXhzxPn9qr73';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse('${AppConstrants.GETALLITEMCLAIMBYUSER_URL}$uid'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _isLoaded = true;
      update();
      print("getItemClaimByUidList " + resultList.toString());
      return resultList;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getItemClaimByUidList');
    }
  }
  Future<List<dynamic>> getListClaimByItemId(int id) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse(AppConstrants.GETLISTFOUNDERUSER_URL +id.toString()));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result']['itemClaims'];
      _isLoaded = true;
      update();
      print("itemlistByid " + resultList.toString());
      return resultList;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getItemListById');
    }
  }
  Future<void> denyClaimByItemIdAndUserId(int itemId, String userId) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.MultipartRequest('POST', Uri.parse(AppConstrants.POSTDENYCLAIMBYITEMIDANDUSERID_URL));
    request.fields.addAll({
      'UserId': userId,
      'ItemId': itemId.toString(),
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 204) {
      print(await response.stream.bytesToString());
      SnackbarUtils().showSuccess(title: "Success", message: "Deny claim successfully");
    }
    else {
      print(response.reasonPhrase);
      print(response.statusCode);
      throw Exception('Failed to Deny claim');
    }

  }
  Future<void> accpectClaimByItemIdAndUserId(int itemId, String userId) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.MultipartRequest('POST', Uri.parse('${AppConstrants.POSTACCPECTCLAIMBYITEMIDANDUSERID_URL}'));
    request.fields.addAll({
      'UserId': userId,
      'ItemId': itemId.toString(),
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 204) {
      print(await response.stream.bytesToString());
      SnackbarUtils().showSuccess(title: "Success", message: "Accept claim successfully");
    }
    else {
      print(response.reasonPhrase);
      print(response.statusCode);
      throw Exception('Failed to Accept claim');
    }

  }

}