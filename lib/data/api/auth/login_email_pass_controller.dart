import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:lost_and_find_app/data/api/auth/login_email_pass_repo.dart';

class LoginEmailPasswordController extends GetxController{
  late LoginEmailPasswordRepo loginEmailPasswordRepo;
  LoginEmailPasswordController({required this.loginEmailPasswordRepo});


  Future<void> loginEmailPassword(data) async {
    final String apiUrl = 'https://localhost:44310/auth/login';

    final response = await http.post(Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(data));
    if (response.statusCode == 200) {
      print("login success");

    }
  }

}
