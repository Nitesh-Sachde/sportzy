import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/validators.dart';
import 'package:sportzy/features/auth/controller/auth_controller.dart';
import 'package:sportzy/features/auth/screen/sign_in_page.dart';
import 'package:sportzy/widgets/custom_appbar.dart';
import 'package:sportzy/widgets/custom_text_field.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sportzy/features/auth/screen/terms_and_conditions_screen.dart';
import 'package:flutter/gestures.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); // Form Key
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isTermsAccepted = false;
  bool isLoading = false; // Loading state
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _submitForm() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      signUp(
        context: context,
        name: name,
        email: email,
        password: password,
        onError: (error) {
          _showToast(error, isError: true);
          setState(() {
            isLoading = false;
          });
        },
        onSuccess: () {
          _showToast(
            "Account created! Please check your email to verify",
            isError: false,
          );
        },
      );
    }
  }

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

  // Create a method to navigate to Terms & Conditions
  void _navigateToTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = ScreenSize.screenWidth(context);
    double screenHeight = ScreenSize.screenHeight(context);
    double paddingSize = screenWidth * 0.06;
    double textSize = screenWidth * 0.08;

    return Stack(
      children: [
        Scaffold(
          appBar: CustomAppBar(
            title: "Sign Up",
            isBackButtonVisible: true,
            showDelete: false,
            showShare: false,
            onBack:
                () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SignInPage()),
                  (route) => false,
                ),
          ),
          backgroundColor: AppColors.primary,

          body: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(screenWidth * 0.1),
              topRight: Radius.circular(screenWidth * 0.1),
            ),
            child: Container(
              height: double.infinity,
              color: AppColors.background,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: paddingSize),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenHeight * 0.04),
                        Text(
                          "Welcome to Sportzy,",
                          style: TextStyle(
                            fontSize: textSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.009),
                        Text(
                          "Let's Make Scoring Easy",
                          style: TextStyle(
                            fontSize: textSize * 0.6,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.04),

                        // Name Field
                        CustomTextField(
                          label: "Full Name",
                          hintText: "Enter your full name",
                          controller: nameController,
                          keyboardType: TextInputType.name,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.person,
                          validator: Validators.validateFullName,
                        ),
                        SizedBox(height: 15),

                        // Email Field
                        CustomTextField(
                          label: "Email",
                          hintText: "Enter your email",
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.email,
                          validator: Validators.validateEmail,
                        ),
                        SizedBox(height: 15),

                        // Password Field
                        CustomTextField(
                          label: "Password",
                          hintText: "Enter your password",
                          controller: passwordController,
                          obscureText: !_isPasswordVisible,
                          textInputAction: TextInputAction.next,
                          prefixIcon: Icons.lock,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed:
                                () => setState(
                                  () =>
                                      _isPasswordVisible = !_isPasswordVisible,
                                ),
                          ),
                          validator: Validators.validatePassword,
                        ),
                        SizedBox(height: 15),

                        // Confirm Password Field
                        CustomTextField(
                          label: "Confirm Password",
                          hintText: "Confirm your password",
                          controller: confirmPasswordController,
                          obscureText: !_isConfirmPasswordVisible,
                          textInputAction: TextInputAction.done,
                          prefixIcon: Icons.lock,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed:
                                () => setState(
                                  () =>
                                      _isConfirmPasswordVisible =
                                          !_isConfirmPasswordVisible,
                                ),
                          ),
                          validator:
                              (value) => Validators.validateConfirmPassword(
                                value,
                                passwordController.text,
                              ),
                        ),
                        SizedBox(height: screenHeight * 0.015),

                        // Terms & Conditions Checkbox
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isTermsAccepted = !isTermsAccepted;
                                });
                              },
                              child: Checkbox.adaptive(
                                value: isTermsAccepted,
                                activeColor: AppColors.lightBlue,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isTermsAccepted = value!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: textSize * 0.55,
                                  ),
                                  children: [
                                    const TextSpan(text: "I accept the "),
                                    TextSpan(
                                      text: "Terms and Conditions",
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      recognizer:
                                          TapGestureRecognizer()
                                            ..onTap =
                                                _navigateToTermsAndConditions,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: screenHeight * 0.03),

                        // Sign Up Button
                        SizedBox(
                          width: double.infinity,
                          height: screenHeight * 0.06,
                          child: ElevatedButton(
                            onPressed:
                                isTermsAccepted
                                    ? () {
                                      CircularProgressIndicator.adaptive(
                                        backgroundColor: AppColors.primary,
                                      );
                                      if (_formKey.currentState!.validate()) {
                                        _submitForm(); // Trigger validation
                                      }
                                    }
                                    : null,
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith<
                                Color
                              >((Set<WidgetState> states) {
                                if (states.contains(WidgetState.disabled)) {
                                  return Colors.grey.shade400; // Disabled color
                                }
                                return AppColors.primary; // Active color
                              }),
                              foregroundColor: WidgetStateProperty.all<Color>(
                                Colors.white,
                              ),
                              shape: WidgetStateProperty.all<
                                RoundedRectangleBorder
                              >(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                            ),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                fontSize: textSize * 0.8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.01),
                        // Sign In Option
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Have an account?",
                                style: TextStyle(
                                  fontSize: textSize * 0.5,
                                  color: AppColors.black,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Navigate to Sign In screen
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SignInPage(),
                                    ),
                                    (route) => false,
                                  );
                                },
                                child: Text(
                                  "Sign In",
                                  style: TextStyle(
                                    fontSize: textSize * 0.6,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isLoading)
          Container(
            color: AppColors.white.withAlpha(179),
            child: Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: AppColors.primary,
                size: screenWidth * 0.2,
              ),
            ),
          ),
      ],
    );
  }
}
