import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stumili/screens/auth/reset_password_screen.dart';
import 'package:stumili/services/api_service.dart';
import 'package:stumili/widgets/auth/auth_background.dart';
import 'package:stumili/widgets/auth/intro.dart';
import 'package:stumili/widgets/custom_button.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  /// UI verify flow: backend se jo OTP aaya, wo yaha pass ho raha
  final String initialCode;

  const VerifyOtpScreen({
    super.key,
    required this.email,
    required this.initialCode,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  int _secondsLeft = 30;
  Timer? _timer;

  bool _canResend = false;
  bool _verifying = false;
  bool _resending = false;

  late int otpLength;

  // ✅ IMPORTANT: expected OTP ko state me rakho (resend pe update hoga)
  late String _expectedOtp;

  List<TextEditingController> _otpControllers = [];
  List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();

    _expectedOtp = widget.initialCode;
    otpLength = _expectedOtp.length;

    _initOtpFields(otpLength);
    _startTimer();
  }

  void _initOtpFields(int length) {
    // dispose old fields (if any)
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }

    _otpControllers = List.generate(length, (_) => TextEditingController());
    _focusNodes = List.generate(length, (_) => FocusNode());
  }

  void _startTimer() {
    _secondsLeft = 30;
    _canResend = false;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (_secondsLeft == 0) {
        timer.cancel();
        setState(() => _canResend = true);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _otpControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  String _getEnteredOtp() {
    return _otpControllers.map((e) => e.text.trim()).join();
  }

  void _clearOtpBoxes() {
    for (final c in _otpControllers) {
      c.clear();
    }
    if (_focusNodes.isNotEmpty) _focusNodes.first.requestFocus();
    setState(() {});
  }

  // 🔁 RESEND OTP (UI verify flow => expected otp update)
Future<void> _resendOtp() async {
  if (!_canResend || _resending) return;

  setState(() => _resending = true);

  try {
    final res = await ApiService.postRequest(
      '/password/forgot',
      body: {'email': widget.email},
    );

    final data = res.data;

    final bool success = data?['success'] == true;
    final String? newOtp = data?['token']?.toString(); // 🔥 TOKEN = OTP
    debugPrint("otpn. $newOtp");

    if (!success || newOtp == null || newOtp.isEmpty) {
      _showMessage(data?['message'] ?? "Couldn't resend OTP");
      return;
    }

    // ✅ update OTP for LOCAL verification
    _expectedOtp = newOtp;

    // ✅ reset OTP UI
    if (newOtp.length != otpLength) {
      otpLength = newOtp.length;
      _initOtpFields(otpLength);
    } else {
      _clearOtpBoxes();
    }

    _focusNodes.first.requestFocus();

    _showMessage("New OTP sent to your email");
    _startTimer();
  } catch (e) {
    _showMessage("We couldn't resend the OTP. Please try again.");
  } finally {
    if (mounted) setState(() => _resending = false);
  }
}


  // ✅ VERIFY OTP (UI compare with _expectedOtp)
  Future<void> _verifyOtp() async {
    if (_verifying) return;

    final otp = _getEnteredOtp();

    if (otp.length != otpLength) {
      _showMessage("Please enter the complete OTP.");
      return;
    }

    if (otp != _expectedOtp) {
      _showMessage("The OTP you entered is incorrect. Please try again.");
      return;
    }

    setState(() => _verifying = true);

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(email: widget.email, otp: otp),
      ),
    );

    if (mounted) setState(() => _verifying = false);
  }

  void _handlePaste(String pasted) {
    final clean = pasted.replaceAll(RegExp(r'\D'), '');
    if (clean.length < 2) return; // normal typing

    final clipped = clean.length > otpLength
        ? clean.substring(0, otpLength)
        : clean;

    for (int i = 0; i < otpLength; i++) {
      _otpControllers[i].text = i < clipped.length ? clipped[i] : '';
    }

    // focus to last filled or last box
    final nextIndex = clipped.length >= otpLength
        ? otpLength - 1
        : clipped.length;
    if (nextIndex >= 0 && nextIndex < otpLength) {
      _focusNodes[nextIndex].requestFocus();
    }
    setState(() {});
  }

  Widget _otpBox(int index, double size) {
    final isFocused = _focusNodes[index].hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withAlpha(90),
        border: Border.all(
          color: isFocused
              ? const Color(0xFFB72658)
              : Colors.white.withAlpha(90),
          width: 1.5,
        ),
        boxShadow: isFocused
            ? [
                BoxShadow(
                  color: const Color(0xFFB72658).withAlpha(80),
                  blurRadius: 10,
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        cursorColor: const Color(0xFFB72658),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (value) {
          if (value.length > 1) {
            _handlePaste(value);
            return;
          }

          if (value.isNotEmpty && index < otpLength - 1) {
            _focusNodes[index + 1].requestFocus();
          } else if (value.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }

          setState(() {});
        },
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: AuthBackground(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Intro(
                  title1: "PLEASE ENTER THE",
                  title2: "OTP SENT TO YOUR EMAIL",
                  title3: "Check your inbox or spam folder",
                ),

                const SizedBox(height: 40),

                LayoutBuilder(
                  builder: (context, constraints) {
                    final double boxSize =
                        (constraints.maxWidth - ((otpLength - 1) * 10)) /
                        otpLength;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        otpLength,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: _otpBox(index, boxSize-2),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                CustomButton(
                  title: _verifying ? "Verifying OTP..." : "Verify OTP",
                  onPress: _verifying ? null : _verifyOtp,
                ),

                const SizedBox(height: 20),

                Center(
                  child: _canResend
                      ? TextButton(
                          onPressed: _resending ? null : _resendOtp,
                          child: Text(
                            _resending ? "Resending OTP..." : "Resend OTP",
                            style: const TextStyle(
                              color: Color(0xFFB72658),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      : Text(
                          "Resend OTP in $_secondsLeft seconds",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
