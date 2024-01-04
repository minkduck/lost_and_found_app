import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../routes/route_helper.dart';
import '../../../utils/app_constraints.dart';
import '../../../utils/snackbar_utils.dart';

class GiveawayController extends GetxController{
  late String accessToken = "";
  late String uid = "";
  late String campusId = "";

  Future<List<dynamic>> getGiveawayStatusList() async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse('${AppConstrants.GETGIVEAWAYSTATUS_URL}ALL'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      update();
      print("giveaway: " + resultList.toString());
      return resultList;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getGiveawayList');
    }
  }

  Future<List<dynamic>> getGiveawayList() async {
    accessToken = await AppConstrants.getToken();
    campusId = await AppConstrants.getCampusId();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse("${AppConstrants.GETALLGIVEAWAY_URL}?CampusId=$campusId"));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      update();
      print("giveaway: " + resultList.toString());
      return resultList;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getGiveawayList');
    }
  }

  Future<void> postParticipateByGiveawayId(int giveawayId) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('POST', Uri.parse(AppConstrants.POSTPARTICIPATEGIVEAWAY_URL + giveawayId.toString()));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201) {
      print(await response.stream.bytesToString());
      SnackbarUtils().showSuccess(title: "Success", message: "Participated giveaway successfully");
    }
    else {
      print(response.reasonPhrase);
      print(response.statusCode);
      throw Exception('Failed to claim Item');
    }

  }


}