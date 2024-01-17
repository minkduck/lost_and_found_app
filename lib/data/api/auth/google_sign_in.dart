import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lost_and_find_app/data/api/report/report_controller.dart';
import 'package:lost_and_find_app/utils/app_constraints.dart';
import 'package:lost_and_find_app/utils/snackbar_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../item/claim_controller.dart';
import '../message/chat_controller.dart';
import '../user/user_controller.dart';

class GoogleSignInProvider extends ChangeNotifier {
  final googleSignIn = GoogleSignIn();

  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  GoogleSignInAccount? _user;

  final userP = Rxn<User>();

  GoogleSignInAccount get user => _user!;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String uid = "String";
  late String name = "String";
  late String email = "String";
  late String avatar = "String";
  late String? phoneUser;
  late String fcmToken ;
  late String accessToken = "";
  Stream? members;
  Map<String, dynamic> userList = {};
  List<dynamic> claimItemList = [];
  List<dynamic> reportItemList = [];

  final ClaimController claimController = Get.put(ClaimController());
  final ReportController reportController = Get.put(ReportController());

  final UserController userController= Get.put(UserController());
  Function? onCampusMismatch;
  User? getUser() {
    userP.value = _auth.currentUser;

    return userP.value;
  }

  Future<void> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    fcmToken = prefs.getString('fcmToken')!;
  }

  Future<void> postAuthen() async {
    await getFcmToken();
    accessToken = await AppConstrants.getToken();

    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken'
    };
    var request = http.Request('POST', Uri.parse(AppConstrants.AUTHENTICATE_URL+fcmToken));
    request.body = json.encode({
      "userDeviceToken" : fcmToken
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
      print("post Authen device token successful");
    }
    else {
      print(response.reasonPhrase);
    }

  }

  Future<Map<String, dynamic>> checkCampus(String uid) async {
    userList = await userController.getUserByUserId(uid);
    final campus = userList["campus"];
    return campus;
  }

  Future<String?> getUserPhoneByUserIdAuth(String id, String accessToken1) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $accessToken1'
    };
    var request = http.Request('GET', Uri.parse('${AppConstrants.GETUSERBYUID_URL}$id'));

    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseBody);

      phoneUser = jsonResponse['result']['phone'];

      return phoneUser;
    } else {
      phoneUser = null;
      print('first login');
    }
  }

  Future googleLogin(String campusId) async {
    await Firebase.initializeApp();

    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;
      _user = googleUser;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      final idToken = await userCredential.user!.getIdToken();

      await FirebaseAuth.instance.authStateChanges().listen((User? user) {
        userP.value = user;
        uid = user!.uid;
        email = user.email!;
        name = user.displayName!;
        avatar = user.photoURL!;
      });

      await getUserPhoneByUserIdAuth(uid, idToken!);

        var headers = {
          'Content-Type': 'application/json'
        };
        var request = await http.Request('POST', Uri.parse(AppConstrants.LOGINGOOGLE_URL));
        request.body = json.encode({
          "uid": uid,
          "email": email,
          "name": name,
          "avatar": avatar,
          "phone": phoneUser,
          "campusId": campusId
        });
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          print(await response.stream.bytesToString());
          print('login api success');
          final user = await FirebaseAuth.instance.currentUser!;
          final idTokenUser = await user.getIdToken();
          print("id Token User: " + idTokenUser.toString());
          print(idTokenUser?.substring(0, 1000));
          print(idTokenUser?.substring(1000));
          userList = await userController.getUserLoginByUserId(uid, idTokenUser!);
          if (!userList['isActive']){
            logout();
            SnackbarUtils().showError(title: "Campus", message: 'You are banned from this system.');
          } else {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('verifyStatus', userList['verifyStatus'].toString());
            await prefs.setString('campusId', userList['campus']['id'].toString());
            await prefs.setString('access_token', idTokenUser.toString());
            await prefs.setString('uid', uid);
            await postAuthen();
            claimItemList = await claimController.getItemClaimByUidList();
            await prefs.setInt('claimItemCount', claimItemList.length);
            print('claimItemCount: ' + claimItemList.length.toString());
            SnackbarUtils().showSuccess(title: "Success", message: "Login google successfully");
          }

        } else if (response.statusCode == 403) {
          logout();
          SnackbarUtils().showError(title: "Campus", message: 'You have logged in to the wrong campus.');
        } else {
          print(response.reasonPhrase);
        }

    } catch (e) {
      print(e.toString());
    }

    notifyListeners();
  }

  Future<void> logout() async {
    // Stop listening to authStateChanges
    FirebaseAuth.instance.authStateChanges().listen((User? user) {}).cancel();

    // Sign out from Google and Firebase Auth
    await googleSignIn.signOut();
    await _auth.signOut();

    // Set _isAuthenticated to false
    _isAuthenticated = false;

    notifyListeners();
  }



}