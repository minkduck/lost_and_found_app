import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../routes/route_helper.dart';
import '../../../utils/app_constraints.dart';
import '../../../utils/snackbar_utils.dart';

class ItemController extends GetxController{
  late String accessToken = "";
  late String uid = "";
  late String campusId = "";

  List<dynamic> _itemList = [];
  List<dynamic> get itemList => _itemList;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;


  Future<List<dynamic>> getItemList() async {
    accessToken = await AppConstrants.getToken();
    campusId = await AppConstrants.getCampusId();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse('${AppConstrants.GETITEMWITHPAGINATION_URL}ACTIVE&CampusId=$campusId&MaxPageSize=100'));

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
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getItemList');
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
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getItemListById');
    }
  }

  Future<List<dynamic>> getItemByUidList() async {
    accessToken = await AppConstrants.getToken();
    uid = await AppConstrants.getUid();
    // uid = 'FLtIEJvuMgfg58u4sXhzxPn9qr73';
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse('${AppConstrants.GETITEMBYUID_URL}$uid&ItemStatus=ALL'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _isLoaded = true;
      update();
      print("getItemByUidList " + resultList.toString());
      return resultList;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getItemByUidList');
    }
  }

  Future<List<dynamic>> getItemByUserId(String id) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse('${AppConstrants.GETITEMBYUID_URL}$id&ItemStatus=ACTIVE'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _isLoaded = true;
      update();
      print("getItemByUidList " + resultList.toString());
      return resultList;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getItemByUidList');
    }
  }

  Future<List<dynamic>> getReturnItem() async {
    accessToken = await AppConstrants.getToken();
    campusId = await AppConstrants.getCampusId();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse(AppConstrants.GETRETURNITEM_URL + campusId));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _isLoaded = true;
      update();
      print("getReturnItem " + resultList.toString());
      return resultList;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getReturnItem');
    }
  }


  Future<void> createItem(
      String name,
      String description,
      String categoryId,
      String locationId,
      String foundDate,
      List<String> medias ) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.MultipartRequest('POST', Uri.parse(AppConstrants.POSTITEM_URL));
    request.fields.addAll({
      'Name': name,
      'Description': description,
      'CategoryId': categoryId,
      'LocationId': locationId,
      'FoundDate': foundDate,

    });
    for (var media in medias) {
      request.files.add(await http.MultipartFile.fromPath('Medias', media));
    }
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      SnackbarUtils().showSuccess(title: "Success", message: "Create item successfully");
      Get.toNamed(RouteHelper.getInitial(0));
    }
    else {
      print(response.reasonPhrase);
      print(response.statusCode);
      throw Exception('Failed to create Item');
    }

  }

  Future<void> updateItemById(
      int itemId,
      String title,
      String description,
      String categoryId,
      String locationId,
      String foundDate,
      // String status
      ) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('PUT', Uri.parse("${AppConstrants.POSTITEM_URL}/$itemId"));

    request.body = json.encode({
      "name": title,
      "description": description,
      "locationId": locationId,
      "categoryId": categoryId,
      "cabinetId": null,
      // "itemStatus": status,
      "foundDate": foundDate
    });
    print(request.body);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      SnackbarUtils().showSuccess(title: "Success", message: "Edit item successfully");
      Get.toNamed(RouteHelper.getInitial(0));
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to delete getItemList');
    }
  }

  Future<void> deleteItemById(int itemId) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('DELETE', Uri.parse("${AppConstrants.POSTITEM_URL}/$itemId"));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 204) {
      print(await response.stream.bytesToString());
      SnackbarUtils().showSuccess(title: "Success", message: "Delete item successfully");
      Get.toNamed(RouteHelper.getInitial(0));
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to delete getItemList');
    }
  }

  Future<void> postBookmarkItemByItemId(int itemId) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('POST', Uri.parse("${AppConstrants.POSTBOOKMARKBYITEMID}/$itemId"));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201) {
      print(await response.stream.bytesToString());
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to postBookmarkItemByItemId');
    }
  }

  Future<Map<String, dynamic>> getBookmarkedItems(int itemId) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request =
    http.Request('GET', Uri.parse(AppConstrants.GETBOOKMARKBYITEMID + itemId.toString()));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _isLoaded = true;
      update();
      print("itemlistByid " + _itemList.toString());
      return resultList;
    } else if (response.statusCode == 404) {
        return {'itemId': itemId, 'isActive': false};
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getBookmarkedItems');
    }
  }

  Future<List<dynamic>> getItemBookmark() async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse(AppConstrants.GETITEMBYBOOKMARK));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _isLoaded = true;
      update();
      print("getItemBookmark " + resultList.toString());
      return resultList;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getItemBookmark');
    }
  }

  Future<void> postFlagItemByItemId(int itemId, String reason) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.MultipartRequest('POST', Uri.parse("${AppConstrants.POSTFLAGBYITEMID}/$itemId"));

    request.fields.addAll({
      'reason': reason
    });

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201) {
      print(await response.stream.bytesToString());
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to postFlagItemByItemId');
    }
  }

  Future<Map<String, dynamic>> getFlagItems(int itemId) async {
    uid = await AppConstrants.getUid();
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request =
    http.Request('GET', Uri.parse('${AppConstrants.GETFLAGBYITEMID}$uid&itemId=$itemId'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _isLoaded = true;
      update();
      print("itemlistByid " + _itemList.toString());
      return resultList;
    } else if (response.statusCode == 404) {
      return {'itemId': itemId, 'isActive': false};
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getFlagItems');
    }
  }

}