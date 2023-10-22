import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lost_and_find_app/data/model/item/item_model.dart';

import '../../../utils/app_constraints.dart';

class ItemController extends GetxController{
  late String accessToken = "";

  List<dynamic> _itemList = [];
  List<dynamic> get itemList => _itemList;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;


  Future<List<dynamic>> getItemList() async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse('${AppConstrants.GETITEMWITHPAGINATION_URL}ALL'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
/*      final jsonResponse = json.decode(responseBody);
      final List<Item> items = (jsonResponse['result'] as List).map((e) => Item.fromJson(e)).toList();
      _itemList.addAll(items);
      _isLoaded = true;
      update();
      print("itemlist " + _itemList.toString());*/
      final jsonResponse = json.decode(responseBody);

        final resultList = jsonResponse['result'];
        _itemList = resultList;
        _isLoaded = true;
        update();
        // print("itemlist " + _itemList.toString());
        return resultList;
    } else {
      print(response.reasonPhrase);
      throw Exception('Failed to load Item');
    }
  }
  Future<Map<String, dynamic>> getItemListById(int id) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse(AppConstrants.GETITEMBYID_URL +id.toString()));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      // _itemList = resultList;
      _isLoaded = true;
      update();
      print("itemlistByid " + _itemList.toString());
      return resultList;
    } else {
      print(response.reasonPhrase);
      throw Exception('Failed to load Item');
    }
  }

}