import 'package:flutter/material.dart';
import 'package:stumili/screens/auth/verify_otp_screen.dart';
import 'package:stumili/services/api_service.dart';
import 'package:stumili/widgets/auth/auth_background.dart';
import 'package:stumili/widgets/auth/input_field.dart';
import 'package:stumili/widgets/auth/intro.dart';
import 'package:stumili/widgets/custom_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;

  bool _isValidEmail(String email) {
    // allow + also
    return RegExp(r'^[\w\.\-\+]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

Future<void> _sendOtp() async {
  if (_loading) return;

  final email = _emailController.text.trim();
  if (!_isValidEmail(email)) {
    _showMessage("Enter valid email");
    return;
  }

  setState(() => _loading = true);

  try {
    final res = await ApiService.postRequest(
      '/password/forgot',
      body: {'email': email},
    );

    final data = res.data;

    final success = data?['success'] == true;

    // 🔥 TOKEN = OTP
    final otp = data?['token']?.toString();

    if (!success || otp == null || otp.isEmpty) {
      _showMessage(data?['message']?.toString() ?? "Failed to send OTP");
      return;
    }

    _showMessage(data?['message'] ?? "OTP sent");

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerifyOtpScreen(
          email: email,
          initialCode: otp,
        ),
      ),
    );
  } catch (e) {
    _showMessage("Failed to send OTP");
  } finally {
    if (mounted) setState(() => _loading = false);
  }
}


  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
 @override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true,
    body: AuthBackground(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(
          left: 25,
          right: 25,
          top: 25,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Intro(
              title1: "Forgot",
              title2: "Password",
              title3: "Enter your email",
            ),

            const SizedBox(height: 30),

            InputField(
              hintText: 'Email',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 25),

            CustomButton(
              title: _loading ? "Sending..." : "Send OTP",
              onPress: _loading ? null : _sendOtp,
            ),
          ],
        ),
      ),
    ),
  );
}

}
