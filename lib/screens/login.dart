import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../components/my_primary_button.dart';
import '../components/my_password_input.dart';
import '../components/my_secondary_button.dart';
import '../components/my_text_input.dart';
import '../main.dart';
import '../functions/login_funcs.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  // API URL
  final Uri loginUrl = Uri.parse("http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/users/login");
  static const EdgeInsets globalPadding = EdgeInsets.symmetric(horizontal: 0);

  void setLoadingState(bool loading) {
    setState(() {
      isLoading = loading;
    });
  }

  void showError(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color,
    ));
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.only(top: 70, bottom: 50),
      child: Column(
        children: [
          const Text('G-SALLES', style: MyApp.titleStyle),
          const SizedBox(height: 50),
          Padding(
            padding: globalPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Login', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, fontFamily: 'Montserrat')),
                SizedBox(height: 5),
                Text('Enter your email below to login to your account.', style: MyApp.subtitleStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: globalPadding,
      child: Column(
        children: [
          MyTextInputInput(
            text: 'Email',
            controller: emailController,
            hintText: 'Type your Email here.',
          ),
          const SizedBox(height: 20),
          MyPasswordInputinput(
            text: 'Password',
            controller: passwordController,
            hintText: 'Type your password here.',
          ),
          const SizedBox(height: 35),
          isLoading
              ? const CircularProgressIndicator()
              : MyPrimaryButtonButton(
            text: 'Login',
            onTap: () {
              LoginFuncs.userLogIn(
                email: emailController.text.trim(),
                password: passwordController.text.trim(),
                loginUrl: loginUrl,
                context: context,
                onLoadingStateChange: setLoadingState,
                onShowError: showError,
              );
            },
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.only(top: 250),
      child: Column(
        children: [
          const Text(
            'Do not have an account?',
            style: TextStyle(fontSize: 17, fontFamily: 'Montserrat', color: Colors.black54),
          ),
          const SizedBox(height: 8),
          MySecondaryButton(
            text: 'Create one!',
            onTap: () {
              // Navigate to the registration page
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                _buildHeader(),
                _buildForm(),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
