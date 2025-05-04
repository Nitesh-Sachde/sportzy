import 'package:flutter/material.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/widgets/custom_appbar.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = ScreenSize.screenWidth(context);
    double screenHeight = ScreenSize.screenHeight(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: "Terms & Conditions",
        isBackButtonVisible: true,
        showDelete: false,
        showShare: false,
        onBack: () => Navigator.pop(context),
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, "Terms and Conditions"),
              _buildLastUpdated(context),
              _buildSectionContent(
                context,
                "Welcome to Sportzy! These Terms and Conditions govern your use of our application and services. By using our application, you accept these terms in full. If you disagree with these terms or any part of them, you must not use our application.",
              ),

              _buildSectionTitle(context, "1. Account Registration"),
              _buildSectionContent(
                context,
                "To use certain features of our application, you may be required to register for an account. When you register, you agree to provide accurate, current, and complete information and to update this information to maintain its accuracy.",
              ),

              _buildSectionTitle(context, "2. User Content"),
              _buildSectionContent(
                context,
                "Users may post content including match details, scores, and player information. You are solely responsible for the content you post and its legality, reliability, and appropriateness.",
              ),

              _buildSectionTitle(context, "3. Privacy Policy"),
              _buildSectionContent(
                context,
                "Your privacy is important to us. Our Privacy Policy explains how we collect, use, and protect your personal information when you use our application. By using Sportzy, you agree to our Privacy Policy.",
              ),

              _buildSectionTitle(context, "4. Intellectual Property"),
              _buildSectionContent(
                context,
                "The application and all content, features, and functionality are owned by Sportzy and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.",
              ),

              _buildSectionTitle(context, "5. Fair Play and Sportsmanship"),
              _buildSectionContent(
                context,
                "Users must adhere to the principles of fair play and good sportsmanship. Fraudulent reporting of match scores or manipulation of statistics is prohibited and may result in account termination.",
              ),

              _buildSectionTitle(context, "6. User Conduct"),
              _buildSectionContent(
                context,
                "Users must not engage in any activity that:\n"
                "• Is illegal, fraudulent, or deceptive\n"
                "• Infringes on the rights of others\n"
                "• Contains harmful code or malware\n"
                "• Harasses, abuses, or harms other users\n"
                "• Interferes with the proper functioning of the application",
              ),

              _buildSectionTitle(context, "7. Limitation of Liability"),
              _buildSectionContent(
                context,
                "Sportzy and its developers will not be liable for any indirect, consequential, or incidental damages arising from your use of the application or services.",
              ),

              _buildSectionTitle(context, "8. Modifications to Terms"),
              _buildSectionContent(
                context,
                "We reserve the right to modify these Terms at any time. We will provide notice of significant changes. Your continued use of the application after changes constitutes acceptance of the modified Terms.",
              ),

              _buildSectionTitle(context, "9. Termination"),
              _buildSectionContent(
                context,
                "We may terminate or suspend your account and access to our services immediately, without prior notice or liability, for any reason, including breach of these Terms.",
              ),

              _buildSectionTitle(context, "10. Governing Law"),
              _buildSectionContent(
                context,
                "These Terms shall be governed by the laws of India, without regard to its conflict of law provisions.",
              ),

              _buildSectionTitle(context, "Contact Us"),
              _buildSectionContent(
                context,
                "If you have any questions about these Terms, please contact us at sportzy.support@example.com",
              ),

              SizedBox(height: screenHeight * 0.03),

              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.1,
                      vertical: screenHeight * 0.015,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: Text(
                    "I Understand",
                    style: TextStyle(
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    double screenWidth = ScreenSize.screenWidth(context);
    return Padding(
      padding: EdgeInsets.only(
        top: screenWidth * 0.05,
        bottom: screenWidth * 0.02,
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: screenWidth * 0.05,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildLastUpdated(BuildContext context) {
    double screenWidth = ScreenSize.screenWidth(context);
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.03),
      child: Text(
        "Last Updated: May 4, 2025",
        style: TextStyle(
          fontSize: screenWidth * 0.035,
          fontStyle: FontStyle.italic,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSectionContent(BuildContext context, String content) {
    double screenWidth = ScreenSize.screenWidth(context);
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.03),
      child: Text(
        content,
        style: TextStyle(
          fontSize: screenWidth * 0.04,
          height: 1.5,
          color: Colors.black87,
        ),
      ),
    );
  }
}
