import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/core/utils/validators.dart';
import 'package:sportzy/widgets/custom_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(
          email: emailController.text.trim(),
        );

        // (prevents email enumeration attacks)
        _showToast(
          "If your email is registered with us, you'll receive a password reset link shortly",
        );
        emailController.clear();
      } on FirebaseAuthException catch (e) {
        print('Forgot password error code: ${e.code}');

        // Only show specific error messages for validation issues, not for existence issues
        if (e.code == 'invalid-email') {
          _showToast('This email address doesn\'t look right', isError: true);
        } else if (e.code == 'too-many-requests') {
          _showToast('Please wait a bit before trying again', isError: true);
        } else {
          // For security reasons, don't reveal whether the user exists or not
          _showToast(
            "If your email is registered with us, you'll receive a password reset link shortly",
          );
        }
      } catch (e) {
        print('General exception in forgot password: $e');
        _showToast('Something went wrong. Please try again', isError: true);
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = ScreenSize.screenWidth(context);
    double screenHeight = ScreenSize.screenHeight(context);
    double cardPadding = screenWidth * 0.07;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Forgot password",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: cardPadding,
          vertical: screenHeight * 0.05,
        ),
        child: Container(
          padding: EdgeInsets.all(cardPadding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF000000).withOpacity(0.1),
                offset: const Offset(3, 3),
                blurRadius: 10,
              ),
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                offset: const Offset(-3, -3),
                blurRadius: 10,
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Enter your registered Email",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: screenWidth * 0.02),

                // Email Input Field with Validation
                CustomTextField(
                  label: "Email",
                  hintText: "Email",
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email,
                  textInputAction: TextInputAction.done,
                  validator: Validators.validateEmail,
                ),

                SizedBox(height: screenHeight * 0.02),

                Text(
                  "We will send you a link to reset your password.",
                  style: TextStyle(
                    fontSize: screenWidth * 0.035,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),

                // Send Button with loading state
                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.06,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      disabledBackgroundColor: AppColors.primary.withOpacity(
                        0.7,
                      ),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.0,
                              ),
                            )
                            : const Text(
                              "Send",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
