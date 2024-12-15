import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:login_test/components/my_primary_button.dart';
import 'package:login_test/components/my_password_input.dart';
import 'package:login_test/components/my_secondary_button.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../components/my_text_input.dart';
import '../data/global_user.dart';
import 'main_dashboard.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  void userLogIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError("Please fill in both fields.", Colors.redAccent);
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse("http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/users/login");
    try {
      print(email);
      print(password);
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['validate'] == true) {
          // Save user data globally
          GlobalUser.setUserData(data);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => MainDashboard()),
          );
        } else {
          showError("User not validated.", Colors.redAccent);
        }
      } else {
        showError("Invalid email or password.", Colors.redAccent);
      }
    } catch (e) {
      showError("An error occurred. Please try again.", Colors.redAccent);
    } finally {
      setState(() => isLoading = false);
    }
  }


  void showError(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message),
      backgroundColor: color,
    ));
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 70),
                const Text(
                  'G-SALLES',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                    fontSize: 40,
                  ),
                ),
                const SizedBox(height: 50),
                const Row(
                  children: [
                    SizedBox(width: 30),
                    Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        fontSize: 25,
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 5),
                const Row(
                  children: [
                    SizedBox(width: 30),
                    Text(
                      'Enter your email below to login to your account.',
                      style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Montserrat',
                          color: Colors.black54
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                MyTextInputInput(
                    text: 'Email',
                    controller: emailController,
                    hintText: 'Type your Email here.'
                ),
                const SizedBox(height: 20),
                MyPasswordInputinput(
                    text: 'Password',
                    controller: passwordController,
                    hintText: 'Type your password here.'
                ),
                const SizedBox(height: 35),
                isLoading
                    ? const CircularProgressIndicator()
                    : MyPrimaryButtonButton(
                  text: 'Login',
                  onTap: userLogIn,
                  color: Colors.black,
                ),
                SizedBox(height: 250),
                Text(
                  'Do not have an account?',
                  style: TextStyle(
                      fontSize: 17,
                      fontFamily: 'Montserrat',
                      color: Colors.black54
                  ),
                ),
                SizedBox(height: 8),
                MySecondaryButton(
                    text: 'Create one !',
                    onTap: null,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
