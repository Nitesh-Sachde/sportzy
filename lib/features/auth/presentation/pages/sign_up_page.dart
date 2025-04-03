import 'package:flutter/material.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/widgets/custom_appbar.dart';
import 'package:sportzy/widgets/custom_text_field.dart';
import 'package:sportzy/core/utils/screen_size.dart'; // Import your screen size utility

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  bool isTermsAccepted = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = ScreenSize.screenWidth(context);
    double screenHeight = ScreenSize.screenHeight(context);
    double paddingSize = screenWidth * 0.06; // 6% of screen width
    double textSize = screenWidth * 0.08; // 5% of screen width

    return Scaffold(
      appBar: const CustomAppBar(title: "Sign Up"),
      backgroundColor: AppColors.primary,

      body: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(screenWidth * 0.1), // 10% of screen width
          topRight: Radius.circular(screenWidth * 0.1), // 10% of screen width
        ),
        child: Container(
          height: double.infinity, // 90% of screen height
          color: AppColors.background,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingSize),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.04), // 5% of screen height
                  Text(
                    "Welcome to Sportzy,",
                    style: TextStyle(
                      fontSize: textSize,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.009), // 1% of screen height
                  Text(
                    "Let's Make Scoring Easy",
                    style: TextStyle(
                      fontSize: textSize * 0.6,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04), // 4% of screen height
                  // Name Field
                  CustomTextField(
                    label: "Name",
                    hintText: "Enter your name",
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    prefixIcon: Icons.person,
                  ),
                  SizedBox(height: screenHeight * 0.02), // 2% of screen height
                  // Email Field
                  CustomTextField(
                    label: "Email",
                    hintText: "Enter your email",
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email,
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return "Enter a valid email";
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Password Field
                  CustomTextField(
                    label: "Password",
                    hintText: "Enter your password",
                    controller: passwordController,
                    isPassword: true,
                    prefixIcon: Icons.lock,
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  // Confirm Password Field
                  CustomTextField(
                    label: "Confirm Password",
                    hintText: "Re-enter your password",
                    controller: confirmPasswordController,
                    isPassword: true,
                    prefixIcon: Icons.lock,
                  ),
                  SizedBox(height: screenHeight * 0.015),

                  // ✅ Terms & Conditions Checkbox
                  Row(
                    children: [
                      Checkbox.adaptive(
                        value: isTermsAccepted,
                        activeColor: AppColors.lightBlue,
                        onChanged: (bool? value) {
                          setState(() {
                            isTermsAccepted = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isTermsAccepted = !isTermsAccepted;
                            });
                          },
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
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.03),

                  // Sign Up Button (Disabled if Terms not accepted)
                  SizedBox(
                    width: double.infinity,
                    height: screenHeight * 0.06,
                    child: ElevatedButton(
                      onPressed:
                          isTermsAccepted
                              ? () {
                                // TODO: Handle Sign-Up logic
                              }
                              : null, // Disabled if checkbox not checked
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          fontSize: textSize * 0.7,
                          fontWeight: FontWeight.bold,
                          color: AppColors.White,
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
    );
  }
}
