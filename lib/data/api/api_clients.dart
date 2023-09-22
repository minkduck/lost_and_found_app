import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../utils/app_constraints.dart';

class ApiClient extends GetConnect implements GetxService{
  late String token ;
  late String appBaseUrl;

  late Map<String, String> _mainHeaders;

  ApiClient({ required this.appBaseUrl}){
    baseUrl = appBaseUrl;
    timeout = Duration(seconds: 10);
    token = AppConstrants.TOKEN;
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ',
    };
    print("appbaseurl: " + appBaseUrl);

    print("token: " + token);
  }


  Future<void> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('access_token')!;
  }

  Future<Response> getData(String uri) async {
    await getToken();
    try{
      Response response = (await http.get(Uri.parse(uri), headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': token})) as Response;
      return response;
    }catch(e){
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> postData(String uri, Map<String, dynamic> data) async {
    await getToken();

    try {
      final Response response = (await http.post(
        Uri.parse(uri),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': token, // Assuming 'token' is a valid authorization token
        },
        body: jsonEncode(data),
      )) as Response;

      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }
}

