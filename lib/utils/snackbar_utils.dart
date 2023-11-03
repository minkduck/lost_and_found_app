import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarUtils {
  showInfo({
    title = String,
    message = String,
  }) {
    Get.snackbar(
      title, // title
      message, // message
      icon: const Icon(Icons.alarm),
      shouldIconPulse: false,
      // onTap: (){},
      isDismissible: false,
      duration: const Duration(seconds: 3),
    );
  }

  showSuccess({
    title = String,
    message = String,
  }) {
    Get.snackbar(
      title, // title
      message, // message
      icon: const Icon(
        Icons.check,
        color: Color(0xFF4DB57A),
      ),
      backgroundColor: const Color(0xAAA2BCF2),
      shouldIconPulse: false,
      // onTap: (){},
      isDismissible: false,
      duration: const Duration(seconds: 3),
    );
  }

  showError({
    title = String,
    message = String,
  }) {
    Get.snackbar(
      title, // title
      message, // message
      icon: const Icon(
        Icons.warning,
        color: Color(0xFFE74C3C),
      ),
      backgroundColor: const Color(0xffF08671),
      shouldIconPulse: false,
      // onTap: (){},
      isDismissible: false,
      duration: const Duration(seconds: 3),
    );
  }

  showLoading({
    String message = "",
  }) {
    Get.snackbar(
      "Loading", // title
      message, // message
      icon: Container(
        padding: const EdgeInsets.all(10),
        height: 40,
        child: const CircularProgressIndicator(
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xffDEA828),
      shouldIconPulse: false,
      // onTap: (){},
      isDismissible: false,
      duration: const Duration(minutes: 5),
    );
  }
}
