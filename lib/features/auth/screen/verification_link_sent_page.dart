import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/home/screen/home_page.dart';
import 'package:sportzy/router/routes.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VerificationLinkSentPage extends StatefulWidget {
  const VerificationLinkSentPage({super.key});

  @override
  State<VerificationLinkSentPage> createState() =>
      _VerificationLinkSentPageState();
}

class _VerificationLinkSentPageState extends State<VerificationLinkSentPage> {
  bool _isButtonDisabled = false;
  int _cooldown = 0;
  Timer? _cooldownTimer;
  Timer? _emailCheckTimer;

  @override
  void initState() {
    super.initState();
    _startCooldownTimer();
    _startEmailVerificationCheck();
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel(); // Cancel any existing timer first

    setState(() {
      _isButtonDisabled = true;
      _cooldown = 60;
    });

    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldown == 1) {
        timer.cancel();
        setState(() {
          _isButtonDisabled = false;
        });
      } else {
        setState(() {
          _cooldown--;
        });
      }
    });
  }

  void _startEmailVerificationCheck() {
    _emailCheckTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) async {
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        timer.cancel();
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
            (route) => false,
          );
        }
      }
    });
  }

  // Update the resend verification email method

  Future<void> _resendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();

        // Use Toast instead of SnackBar for better visibility
        Fluttertoast.showToast(
          msg: 'Verification email sent to your inbox!',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        _startCooldownTimer();
      }
    } catch (e) {
      // Use Toast for error message too
      Fluttertoast.showToast(
        msg: 'Couldn\'t send verification email. Please try again',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailCheckTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = ScreenSize.screenWidth(context);
    double screenHeight = ScreenSize.screenHeight(context);
    double paddingSize = screenWidth * 0.06;
    double textSize = screenWidth * 0.08;
    double buttonHeight = screenHeight * 0.06;
    double buttonFontSize = screenWidth * 0.045;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed:
              () => Navigator.pushReplacementNamed(context, Routes.signIn),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: paddingSize),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/email_sent.avif',
                height: screenHeight * 0.35,
              ),
              SizedBox(height: screenHeight * 0.05),
              Text(
                "Check your Email",
                style: TextStyle(
                  fontSize: textSize * 0.75,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: screenHeight * 0.015),
              Text(
                "Verification link sent to Email",
                style: TextStyle(
                  fontSize: textSize * 0.5,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: screenHeight * 0.04),
              SizedBox(
                width: double.infinity,
                height: buttonHeight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isButtonDisabled ? Colors.grey : AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed:
                      _isButtonDisabled ? null : _resendVerificationEmail,
                  child: Text(
                    _isButtonDisabled
                        ? 'Wait $_cooldown seconds'
                        : 'Resend Link',
                    style: TextStyle(
                      fontSize: buttonFontSize,
                      color: _isButtonDisabled ? AppColors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
