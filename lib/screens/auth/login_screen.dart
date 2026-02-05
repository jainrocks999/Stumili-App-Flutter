import 'package:flutter/material.dart';
import 'package:stumili/core/fonts.dart';
import 'package:stumili/core/secure_storage.dart';
import 'package:stumili/navigation/routes/app_routes.dart';
import 'package:stumili/screens/auth/forgot_password_screen.dart';
import 'package:stumili/services/api_service.dart';
import 'package:stumili/services/onesignal_service.dart';
import 'package:stumili/widgets/auth/auth_background.dart';
import 'package:stumili/widgets/auth/input_field.dart';
import 'package:stumili/widgets/auth/intro.dart';
import 'package:stumili/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false; // ✅ loader

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void navigateToHome() {
    Navigator.pushNamed(context, AppRoutes.welcome);
  }

   void _clearInputs() {
    _emailController.clear();
    _passwordController.clear();
    // optional: cursor reset / rebuild
    setState(() {});
  }

  void _goToForgot() {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    _clearInputs();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  void _goToSignup() {
    if (_loading) return;
    FocusScope.of(context).unfocus();
    _clearInputs();

    Navigator.pushNamed(context, AppRoutes.signup);
  }

  Future<void> _login() async {
    if (_loading) return;

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

    setState(() => _loading = true);

    try {
      final fcmToken = await SecureStore.getFcmToken();
      final response = await ApiService.postRequest(
        '/login',
        body: {
          'email': email,
          'password': password,
          'fcm_token': fcmToken ?? "fcm_tokenssssssss",
        },
        headers: {'Accept': 'application/json'},
      );

      final data = response.data?['data'];

      // ✅ defensive: token + id
      final userId = data?['id'];
      final token = data?['token'];

      if (userId != null && token != null) {
        await SecureStore.saveUser(userId.toString(), token.toString());
        Future.microtask(() async {
          await OneSignalService.init();
        });
      }

      if (!mounted) return;

      _showMessage("Login Successful");
      navigateToHome();
    } catch (err) {
      if (!mounted) return;
      _showMessage("Login failed");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Stack(
        children: [
          SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Intro(
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
                        obscureText: _obscurePassword,
                        // ✅ disable while loading
                        suffixIcon: InkWell(
                          onTap: _loading
                              ? null
                              : () => setState(() {
                                  _obscurePassword = !_obscurePassword;
                                }),
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        right: 8,
                        top: 6,
                        bottom: 0,
                      ),
                      child: GestureDetector(
                        onTap: _loading
                            ? null
                            : _goToForgot,
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

                  // ✅ button loader text + disable
                  CustomButton(
                    title: _loading ? "Logging in..." : "Login",
                    onPress: _loading ? null : _login,
                  ),

                  const SizedBox(height: 50),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Dont have account?",
                          style: TextStyle(color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: _loading
                              ? null
                              : _goToSignup,
                          child: const Text(
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

          // ✅ full screen loader overlay
          if (_loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
