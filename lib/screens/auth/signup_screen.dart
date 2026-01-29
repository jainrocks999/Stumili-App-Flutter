import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:stumili/services/api_service.dart';
import 'package:stumili/widgets/auth/auth_background.dart';
import 'package:stumili/widgets/auth/input_field.dart';
import 'package:stumili/widgets/auth/intro.dart';
import 'package:stumili/widgets/custom_button.dart';

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

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateToLogin() {
    Navigator.pop(context);
  }

  Future<void> _signup() async {
  if (_loading) return;

  final email = _emailController.text.trim();
  final name = _nameController.text.trim();
  final password = _passwordController.text.trim();
  final confirmPassword = _confirmPasswordController.text.trim();

  if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
    _showMessage("All fields are required");
    return;
  }
  if (name.length < 3) {
    _showMessage("Name must be at least 3 characters");
    return;
  }
  if (!_isValidEmail(email)) {
    _showMessage("Enter a valid email address");
    return;
  }
  if (password.length < 6) {
    _showMessage("Password must be at least 6 characters");
    return;
  }
  if (password != confirmPassword) {
    _showMessage("Passwords do not match");
    return;
  }

  setState(() => _loading = true);

  try {
    final formData = {
      "name": name,
      "email": email,
      "password": password,
      "password_confirmation": confirmPassword,
    };

    final response = await ApiService.postRequest(
      '/registration',
      body: formData,
      // ✅ Accept only (Content-Type ApiService handle karega)
      headers: {'Accept': 'application/json'},
    );

    final data = response.data;
    debugPrint("SIGNUP RESPONSE => $data");

    // ✅ SUCCESS CHECK (tumhare response ke base pe)
    bool ok = false;
    String message = "";

    if (data is Map) {
      final st = data['status']; // 200
      final token = data['token'];

      ok = response.statusCode == 200 ||
          response.statusCode == 201 ||
          st == 200 ||
          st == 201 ||
          token != null;

      message = (data['message'] ?? "").toString();
    } else {
      ok = response.statusCode == 200 || response.statusCode == 201;
    }

    if (!mounted) return;

    if (ok) {
      _showMessage("Signup Successful! Please login.");
      _navigateToLogin();
    } else {
      _showMessage(message.isNotEmpty ? message : "Signup failed");
    }
  } on DioException catch (e) {
    final resp = e.response?.data;

    if (!mounted) return;

    // ✅ handle email exists / validation errors
    if (resp is Map) {
      if (resp['message'] != null) {
        _showMessage(resp['message'].toString());
        return;
      }

      if (resp['errors'] != null) {
        final err = resp['errors'];
        if (err is List) {
          _showMessage(err.join('\n'));
          return;
        }
        if (err is Map) {
          final msgs = <String>[];
          err.forEach((_, v) {
            if (v is List) msgs.addAll(v.map((x) => x.toString()));
            else msgs.add(v.toString());
          });
          _showMessage(msgs.join('\n'));
          return;
        }
        _showMessage(err.toString());
        return;
      }
    }

    _showMessage("Signup error! Please try again.");
  } catch (_) {
    if (!mounted) return;
    _showMessage("Something went wrong!");
  } finally {
    if (!mounted) return;
    setState(() => _loading = false);
  }
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
              const Intro(
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

                  // ✅ Password with toggle
                  InputField(
                    hintText: 'Password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    suffixIcon: InkWell(
                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  // ✅ Confirm Password with toggle
                  InputField(
                    hintText: 'Confirm Password',
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: InkWell(
                      onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      child: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              CustomButton(
                title: _loading ? "Signing up..." : "Sign up",
                onPress: _loading ? null : _signup,
              ),

              const SizedBox(height: 50),

              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Already have account?",
                      style: TextStyle(color: Colors.white),
                    ),
                    GestureDetector(
                      onTap: _navigateToLogin,
                      child: const Text(
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
