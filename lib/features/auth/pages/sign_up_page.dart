import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/validators.dart';
import 'package:sportzy/features/auth/controller/auth_controller.dart';
import 'package:sportzy/features/auth/pages/sign_in_page.dart';
import 'package:sportzy/widgets/custom_appbar.dart';
import 'package:sportzy/widgets/custom_text_field.dart';
import 'package:sportzy/core/utils/screen_size.dart';

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
  void _submitForm() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // Set loading state to true
      });
      signUp(context: context, name: name, email: email, password: password);
    }
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
                          label: "Name",
                          hintText: "Enter your name",
                          controller: nameController,
                          keyboardType: TextInputType.name,
                          prefixIcon: Icons.person,
                          validator: Validators.validateName,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Email Field
                        CustomTextField(
                          label: "Email",
                          hintText: "Enter your email",
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email,
                          validator: Validators.validateEmail,
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Password Field
                        CustomTextField(
                          label: "Password",
                          hintText: "Enter your password",
                          controller: passwordController,
                          keyboardType: TextInputType.visiblePassword,
                          isPassword: true,
                          prefixIcon: Icons.lock,
                          validator: Validators.validatePassword,
                          textInputAction: TextInputAction.done,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Confirm Password Field
                        CustomTextField(
                          label: "Confirm Password",
                          hintText: "Re-enter your password",
                          controller: confirmPasswordController,
                          isPassword: true,
                          prefixIcon: Icons.lock,
                          keyboardType: TextInputType.visiblePassword,
                          textInputAction: TextInputAction.done,
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
                                      // TODO: Navigate to Terms & Conditions page when clicked
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
            color: AppColors.white.withOpacity(0.7),
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
