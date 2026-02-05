import 'package:flutter/material.dart';
import 'package:stumili/services/api_service.dart';
import 'package:stumili/widgets/auth/auth_background.dart';
import 'package:stumili/widgets/auth/input_field.dart';
import 'package:stumili/widgets/auth/intro.dart';
import 'package:stumili/widgets/custom_button.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _loading = false;

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _resetPassword() async {
    if (_loading) return;

    final pass = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    if (pass.length < 6) {
      _showMessage("Password min 6 chars");
      return;
    }

    if (pass != confirm) {
      _showMessage("Passwords do not match");
      return;
    }

    setState(() => _loading = true);

    try {
      await ApiService.getRequest(
        '/change-password',
        queryParameters: {
          'email': widget.email,
          'token': widget.otp,
          'password': pass,
        },
      );

      if (!mounted) return;

      _showMessage("Password changed successfully");
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (_) {
      _showMessage("Password reset failed");
    } finally {
      setState(() => _loading = false);
    }
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true,
    body: AuthBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Intro(
                title1: "Reset",
                title2: "Password",
                title3: "Create new password",
              ),
              const SizedBox(height: 20),
              InputField(
                hintText: 'New Password',
                controller: _passwordController,
                obscureText: true,
              ),
              const SizedBox(height: 15),
              InputField(
                hintText: 'Confirm Password',
                controller: _confirmController,
                obscureText: true,
              ),
              const SizedBox(height: 25),
              CustomButton(
                title: _loading ? "Updating..." : "Change Password",
                onPress: _loading ? null : _resetPassword,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}
