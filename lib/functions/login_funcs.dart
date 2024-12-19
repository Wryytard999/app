import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/global_user.dart';
import '../screens/main_dashboard.dart';

class LoginFuncs {

  static Future<void> userLogIn({
    required String email,
    required String password,
    required Uri loginUrl,
    required BuildContext context,
    required Function(bool) onLoadingStateChange,
    required Function(String, Color) onShowError,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      onShowError("Please fill in both fields.", Colors.redAccent);
      return;
    }

    onLoadingStateChange(true);

    try {
      final response = await http.post(
        loginUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['validate'] == true) {
          GlobalUser.setUserData(data);

          // Navigate to the main dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainDashboard()),
          );
        } else {
          onShowError("User not validated.", Colors.redAccent);
        }
      } else {
        onShowError("Invalid email or password.", Colors.redAccent);
      }
    } catch (e) {
      debugPrint("Error during login: $e");
      onShowError("An error occurred. Please try again.", Colors.redAccent);
    } finally {
      onLoadingStateChange(false);
    }
  }
}
