import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:lost_and_find_app/utils/app_constraints.dart';
import 'package:lost_and_find_app/utils/snackbar_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late String fcmToken ;
  late String accessToken = "";
  Stream? members;
  Map<String, dynamic> userList = {};
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

      userList = await userController.getUserLoginByUserId(uid, idToken!);
      print("uid" + uid);
      final campus = userList["campus"];
      print("campus: "+ campus.toString());
      if (campus == null) {
        var headers = {
          'Content-Type': 'application/json'
        };
        var request = await http.Request('POST', Uri.parse(AppConstrants.LOGINGOOGLE_URL));
        request.body = json.encode({
          "uid": uid,
          "email": email,
          "name": name,
          "avatar": avatar,
          "phone": "string",
          "campusId": campusId
        });
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          print(await response.stream.bytesToString());
          print('login api success');
          print('first login');
          SnackbarUtils().showSuccess(title: "Success", message: "Login google successfully");
          final user = await FirebaseAuth.instance.currentUser!;
          final idTokenUser = await user.getIdToken();
          print("id Token User: " + idTokenUser.toString());
          print(idTokenUser?.substring(0, 1000));
          print(idTokenUser?.substring(1000));

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', idTokenUser.toString());
          await prefs.setString('uid', uid);
          await postAuthen();
/*          ChatController(uid: FirebaseAuth.instance.currentUser!.uid)
              .gettingUserChats()
              .then((val) {
            members = val;
          });
          print("sn " + members.toString());*/
        } else {
          print(response.reasonPhrase);
        }
      } else {
        // If userList["campus"] is not null, compare campusId with userList["campus"]["id"]
        if (campus["id"].toString() != campusId) {
          logout();
          SnackbarUtils().showError(title: "Campus", message: 'You have logged in to the wrong campus.');
          return;
        }

        print("Continuing with login process...");
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('verifyStatus', userList['verifyStatus'].toString());

        var headers = {
          'Content-Type': 'application/json'
        };
        var request = await http.Request('POST', Uri.parse(AppConstrants.LOGINGOOGLE_URL));
        request.body = json.encode({
          "uid": uid,
          "email": email,
          "name": name,
          "avatar": avatar,
          "phone": "string",
          "campusId": campusId
        });
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          print(await response.stream.bytesToString());
          print('login api success');
          SnackbarUtils().showSuccess(title: "Success", message: "Login google successfully");
          final user = await FirebaseAuth.instance.currentUser!;
          final idTokenUser = await user.getIdToken();
          print("id Token User: " + idTokenUser.toString());
          print(idTokenUser?.substring(0, 1000));
          print(idTokenUser?.substring(1000));

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', idTokenUser.toString());
          await prefs.setString('uid', uid);
          await postAuthen();
/*          ChatController(uid: FirebaseAuth.instance.currentUser!.uid)
              .gettingUserChats()
              .then((val) {
            members = val;
          });
          print("sn " + members.toString());*/
        } else {
          print(response.reasonPhrase);
        }
      }
    } catch (e) {
      print(e.toString());
    }

    notifyListeners();
  }

  Future<void> logout() async {
    await googleSignIn.signOut();
    await _auth.signOut();

    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _isAuthenticated = false;
        notifyListeners();
      }
    });
  }


}