import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/validators.dart';
import 'package:sportzy/features/auth/controller/auth_controller.dart';
import 'package:sportzy/features/auth/provider/auth_provider.dart';
import 'package:sportzy/features/auth/screen/forgot_password_page.dart';
import 'package:sportzy/features/auth/screen/sign_up_page.dart';
import 'package:sportzy/widgets/custom_appbar.dart';
import 'package:sportzy/widgets/custom_text_field.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  void _submit() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Add this loading state variable
      });
      {
        ref.read(justSignedInProvider.notifier).state = true;
        signIn(
          context: context,
          email: email,
          password: password,
          onError: (error) {
            _showToast(error, isError: true);
            setState(() {
              _isLoading = false;
            });
          },
          onSuccess: () {
            _showToast("You're now signed in!", isError: false);
          },
        );
      }
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

  @override
  Widget build(BuildContext context) {
    double screenWidth = ScreenSize.screenWidth(context);
    double screenHeight = ScreenSize.screenHeight(context);
    double paddingSize = screenWidth * 0.06;
    double textSize = screenWidth * 0.08;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Sign In",
        isBackButtonVisible: false,
        showDelete: false,
        showShare: false,
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
                // ✅ Wrap in Form
                key: _formKey, // ✅ Assign form key
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.04),
                    Text(
                      "Welcome Back,",
                      style: TextStyle(
                        fontSize: textSize,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      "Sign in to continue",
                      style: TextStyle(
                        fontSize: textSize * 0.6,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    Center(
                      child: Image.asset(
                        "assets/images/sportzy_logo.png",
                        width: screenWidth * 0.7,
                        height: screenHeight * 0.3,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // Email Field
                    CustomTextField(
                      label: "Email",
                      hintText: "Enter your email",
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                      validator: Validators.validateEmail, // ✅ Validation
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Password Field
                    CustomTextField(
                      label: "Password",
                      hintText: "Enter your password",
                      controller: passwordController,
                      isPassword: true,
                      prefixIcon: Icons.lock,
                      validator:
                          Validators.validateSignInPassword, // ✅ Validation
                      textInputAction: TextInputAction.done,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage(),
                              ),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                              fontSize: textSize * 0.5,
                              color: AppColors.lightBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.03),

                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: screenHeight * 0.06,
                      child: ElevatedButton(
                        onPressed: _submit, // ✅ Trigger validation
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>((
                                Set<WidgetState> states,
                              ) {
                                return AppColors.primary;
                              }),
                          foregroundColor: WidgetStateProperty.all<Color>(
                            Colors.white,
                          ),
                          shape:
                              WidgetStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                        ),
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: textSize * 0.8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Sign Up Option
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              fontSize: textSize * 0.5,
                              color: AppColors.black,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const SignUpPage(),
                                ),
                              );
                            },
                            child: Text(
                              "Sign Up",
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
    );
  }
}
