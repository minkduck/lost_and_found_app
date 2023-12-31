import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../routes/route_helper.dart';
import '../../../utils/app_constraints.dart';
import '../../../utils/snackbar_utils.dart';

class PostController extends GetxController{
  late String accessToken = "";
  late String uid = "";
  late String campusId = "";

  List<dynamic> _postList = [];
  List<dynamic> get postList => _postList;

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  RxBool isLoading = false.obs;

  Future<List<dynamic>> getPostList() async {
    accessToken = await AppConstrants.getToken();
    campusId = await AppConstrants.getCampusId();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse(AppConstrants.GETPOSTWITHPAGINATION_URL+campusId));
    // var request = http.Request('GET', Uri.parse("https://lostandfound.io.vn/api/posts/query-with-status?PostStatus=All"));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _postList = resultList;
      _isLoaded = true;
      update();
      print("_postList $_postList");
      return resultList;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getPostList');
    }
  }
  Future<Map<String, dynamic>> getPostListById(int id) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse(AppConstrants.GETPOSTBYID_URL +id.toString()));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _isLoaded = true;
      update();
      print("itemlistByid " + resultList.toString());
      return resultList;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load PostById');
    }
  }

  Future<List<dynamic>> getPostByUserId(String id) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse('${AppConstrants.GETPOSTBYUSERID_URL}$id'));

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


  Future<Map<String, dynamic>> getPostMediaById(int id) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse(AppConstrants.GETPOSTMEDIABYID_URL+id.toString()+'/media'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _isLoaded = true;
      update();
      print("PostMediaById " + resultList.toString());
      return resultList;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load PostMediaById');
    }
  }

  Future<List<dynamic>> getPostByUidList() async {
    accessToken = await AppConstrants.getToken();
    uid = await AppConstrants.getUid();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse('${AppConstrants.GETPOSTBYUID_URL}$uid&PostStatus=ALL'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _isLoaded = true;
      update();
      print("getPostByUidList " + resultList.toString());
      return resultList;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load Posts By Uid');
    }
  }


  Future<void> createPost(
      String title,
      String postContent,
      String postLocationId,
      String postCategoryId,
      String? lostDateFrom,
      String? lostDateTo,
      List<String> medias ) async {
    try {
      accessToken = await AppConstrants.getToken();
      var headers = {
        'Authorization': 'Bearer $accessToken'
      };
      var request = http.MultipartRequest('POST', Uri.parse(AppConstrants.POSTPOST_URL));
      request.fields.addAll({
        'Title': title,
        'PostContent': postContent,
        'PostLocation': postLocationId,
        'PostCategory': postCategoryId,
      });
      if (lostDateFrom != null && lostDateFrom.isNotEmpty) {
        request.fields['LostDateFrom'] = lostDateFrom;
      }

      // Conditionally add 'LostDateTo' if it has data
      if (lostDateTo != null && lostDateTo.isNotEmpty) {
        request.fields['LostDateTo'] = lostDateTo;
      }
      for (var media in medias) {
        request.files.add(await http.MultipartFile.fromPath('Medias', media));
      }

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 201) {
        print('create post success');
        Get.toNamed(RouteHelper.getInitial(1));
        print(await response.stream.bytesToString());
        SnackbarUtils().showSuccess(title: "Success", message: "Create new post successfully");
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

  Future<void> updatePostById(
      int postId,
      String title,
      String description,
      String categoryId,
      String locationId,
      String? lostDateFrom,
      String? lostDateTo,
      ) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('PUT', Uri.parse("${AppConstrants.GETPOSTBYID_URL}$postId"));

    request.body = json.encode({
      "title": title,
      "postContent": description,
      "postLocation": locationId,
      "postCategory": categoryId,
      "lostDateFrom": lostDateFrom,
      "lostDateTo": lostDateTo
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      SnackbarUtils().showSuccess(title: "Success", message: "Edit post successfully");
      Get.toNamed(RouteHelper.getInitial(1));
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to delete getItemList');
    }
  }

  Future<void> deleteItemById(int postId) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('DELETE', Uri.parse("${AppConstrants.GETPOSTBYID_URL}/$postId"));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 204) {
      print(await response.stream.bytesToString());
      SnackbarUtils().showSuccess(title: "Success", message: "Delete post successfully");
      Get.toNamed(RouteHelper.getInitial(1));
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to delete post');
    }
  }

  Future<void> postBookmarkPostByPostId(int postId) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('POST', Uri.parse("${AppConstrants.POSTBOOKMARKBYPOSTID}/$postId"));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201) {
      print(await response.stream.bytesToString());
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to postBookmarkPostByPostId');
    }
  }

  Future<Map<String, dynamic>> getBookmarkedPost(int postId) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request =
    http.Request('GET', Uri.parse(AppConstrants.GETBOOKMARKBYPOSTID + postId.toString()));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      update();
      return resultList;
    } else if (response.statusCode == 404) {
      return {'postId': postId, 'isActive': false};
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getBookmarkedItems');
    }
  }

  Future<List<dynamic>> getPostBookmark() async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('GET', Uri.parse(AppConstrants.GETPOSTBYBOOKMARK));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      final resultList = jsonResponse['result'];
      _isLoaded = true;
      update();
      print("getPostBookmark " + resultList.toString());
      return resultList;
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getPostBookmark');
    }
  }

  Future<void> postFlagPostByPostId(int postId, String reason) async {
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.MultipartRequest('POST', Uri.parse("${AppConstrants.POSTFLAGBYPOSTID}$postId"));
    request.fields.addAll({
      'reason': reason
    });
    request.headers.addAll(headers);
    print(request);
    print(request.fields);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 201) {
      print(await response.stream.bytesToString());
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to postFlagPostByPostId');
    }
  }

  Future<Map<String, dynamic>> getFlagPost(int postId) async {
    uid = await AppConstrants.getUid();
    accessToken = await AppConstrants.getToken();
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request =
    http.Request('GET', Uri.parse('${AppConstrants.GETFLAGBYPOSTID}$uid&postId=$postId'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);
      print(responseBody);
      print('200');
      final resultList = jsonResponse['result'];
      update();
      return resultList;
    } else if (response.statusCode == 404) {
      return {'postId': postId, 'isActive': false};
    } else {
      print(response.statusCode);
      print(response.reasonPhrase);
      throw Exception('Failed to load getBookmarkedItems');
    }
  }

}