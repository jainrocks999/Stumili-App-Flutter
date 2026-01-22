import 'package:flutter/material.dart';
import 'package:weather_app/services/api_service.dart';
import 'package:weather_app/widgets/auth/auth_background.dart';
import 'package:weather_app/widgets/auth/input_field.dart';
import 'package:weather_app/widgets/auth/intro.dart';
import 'package:weather_app/widgets/custom_button.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
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
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (!_isValidEmail(email)) {
      _showMessage("Enter a valid email address");
      return;
    }

    if (name.isEmpty) {
      _showMessage("Password cannot be empty");
      return;
    }
    if (name.length < 3) {
      _showMessage("Name must be at least 6 characters");
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
    if (password != confirmPassword) {
      _showMessage("Password must be matched");
      return;
    }
    try {
      final response = await ApiService.postRequest(
        '/registration',
        body: {
          "name": name,
          'email': email,
          'password': password,
          "password_confirmation": confirmPassword,
        },
      );

      if(response.data.status){
         navigate();
      _showMessage("Signup Successful! Please login.");

      }
    } catch (err) {
      // print('eeerr $err');
      _showMessage("Something went wrong!");
    }
  }
 void navigate(){
    Navigator.pop(context);
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
                title1: 'Empower',
                title2: 'Yourself Now',
                title3: "Let's get you Signed Up",
                isLogin: false,
              ),
              Column(
                children: [
                  InputField(
                    hintText: 'Name',
                    keyboardType: TextInputType.name,
                    controller: _nameController,
                  ),
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
                  InputField(
                    hintText: 'Confirm Password',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    suffixIcon: Icon(
                      Icons.remove_red_eye_outlined,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),

              CustomButton(title: "Sign up", onPress: _login),
              SizedBox(height: 50),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have account?",
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: () {
                     navigate();
                      },
                      child: Text(
                        " Login",
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
