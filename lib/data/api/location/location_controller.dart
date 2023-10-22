import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../utils/app_constraints.dart';
class LocationController extends GetxController{
  late String accessToken = "";

  List<dynamic> _locationList = [];
  List<dynamic> get locationList => _locationList;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<List<dynamic>> getLocationList() async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse(AppConstrants.GETLOCATIONWITHPAGINATION_URL));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _isLoaded = true;
      update();
      print("locationList " + resultList.toString());
      return resultList;
    } else {
      print(response.reasonPhrase);
      throw Exception('Failed to load Location');
    }
  }

}
