import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/features/auth/screen/forgot_password_page.dart';
import 'package:flutter/services.dart';
import 'package:sportzy/features/auth/screen/sign_in_page.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/playerprofile/edit_profile.dart'; // Make sure this exists

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String userName = '';
  String userId = '';

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final uid = user.uid;
      final userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        userName = userData['name'] ?? 'User';
        userId = userData['id'] ?? 'N/A';
      });
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Confirm Deletion"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Please enter your password to delete your account:",
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _deleteAccountAndNavigate(context, passwordController.text);
                },
                child: const Text("Delete"),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteAccountAndNavigate(
    BuildContext context,
    String password,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null || user.email == null) {
        throw Exception("No authenticated user found.");
      }

      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(cred);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();
      await user.delete();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  String getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return "";
    final names = name.trim().split(RegExp(r'\s+'));
    if (names.length > 1) {
      return "${names[0][0]}${names[1][0]}".toUpperCase();
    }
    return names[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenSize.screenHeight(context);
    final screenWidth = ScreenSize.screenWidth(context);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: screenHeight * 0.07,
              bottom: screenHeight * 0.025,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(screenWidth * 0.08),
                bottomRight: Radius.circular(screenWidth * 0.08),
              ),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: screenWidth * 0.1,
                  backgroundColor: AppColors.white,
                  child: Text(
                    getInitials(userName),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: screenWidth * 0.08,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.012),
                Text(
                  userName,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.025),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "User ID:",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.05,
                  ),
                ),
                SizedBox(width: screenWidth * 0.025),
                Flexible(
                  child: Text(
                    userId,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth * 0.05,
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.015),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: userId));
                  },
                  child: Icon(
                    Icons.copy,
                    size: screenWidth * 0.05,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenHeight * 0.025),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              children: [
                buildProfileOption(
                  context,
                  "Edit Profile",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileEditScreen(),
                    ),
                  ),
                ),
                buildProfileOption(
                  context,
                  "Change Password",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordPage(),
                    ),
                  ),
                ),
                buildProfileOption(
                  context,
                  "Statistics",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordPage(),
                    ),
                  ),
                ),
                buildProfileOption(
                  context,
                  "Notification Preferences",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ForgotPasswordPage(),
                    ),
                  ),
                ),
                buildProfileOption(
                  context,
                  "Delete Account",
                  () => _showDeleteConfirmationDialog(context),
                ),
                SizedBox(height: screenHeight * 0.04),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.06),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.1,
                        vertical: screenHeight * 0.015,
                      ),
                    ),
                    child: Text(
                      "Logout",
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: screenWidth * 0.04,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildProfileOption(
    BuildContext context,
    String title,
    VoidCallback onTap,
  ) {
    final screenWidth = ScreenSize.screenWidth(context);
    return Column(
      children: [
        ListTile(
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: screenWidth * 0.04,
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: screenWidth * 0.035),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
