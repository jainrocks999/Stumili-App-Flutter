import 'package:flutter/material.dart';
import 'package:weather_app/core/fonts.dart';
import 'package:weather_app/core/secure_storage.dart';
import 'package:weather_app/navigation/routes/app_routes.dart';
import 'package:weather_app/services/api_service.dart';
import 'package:weather_app/widgets/auth/auth_background.dart';
import 'package:weather_app/widgets/auth/input_field.dart';
import 'package:weather_app/widgets/auth/intro.dart';
import 'package:weather_app/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _login() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (!_isValidEmail(email)) {
      _showMessage("Enter a valid email address");
      return;
    }

    if (password.isEmpty) {
      _showMessage("Password cannot be empty");
      return;
    }

    if (password.length < 6) {
      _showMessage("Password must be at least 6 characters");
      return;
    }

    try {
      final response = await ApiService.postRequest(
        '/login',
        body: {
          'email': email,
          'password': password,
          'fcm_token': "fcm_tokenssssssss",
        },
      );
      final data = response.data?['data'];
      if (data != null && data['id'] != null && data['token'] != null) {
        await SecureStore.saveUser(data['id'].toString(), data['token']);
      }
      navigateToHome();
      _showMessage("Login Successful");
    } catch (err) {
      _showMessage("Login failed");
    }
  }

  void navigateToHome() {
    Navigator.pushNamed(context, AppRoutes.welcome);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Intro(
                title1: 'Welcome to',
                title2: 'STUMILI',
                title3: "Let's login here",
              ),
              Column(
                children: [
                  InputField(
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                  ),
                  InputField(
                    hintText: 'Password',
                    controller: _passwordController,
                    obscureText: true,
                    suffixIcon: Icon(
                      Icons.remove_red_eye_outlined,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: EdgeInsets.only(right: 8, top: 6, bottom: 0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Forgot Your Password?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppFonts.medium,
                      ),
                    ),
                  ),
                ),
              ),
              CustomButton(title: "Login", onPress: _login),
              SizedBox(height: 50),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Dont have account?",
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.signup);
                      },
                      child: Text(
                        " Sign Up",
                        style: TextStyle(color: Color(0xFFB72658)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
