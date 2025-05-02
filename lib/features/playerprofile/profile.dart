import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/features/auth/screen/forgot_password_page.dart';
import 'package:flutter/services.dart';
import 'package:sportzy/features/auth/screen/sign_in_page.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/playerprofile/edit_profile.dart';
import 'package:sportzy/features/playerprofile/statistics_screen.dart'; // Make sure this exists

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

      // Step 1: Re-authenticate
      await user.reauthenticateWithCredential(cred);

      // Step 2: Delete user matches (where this user is the creator)
      final matchQuery =
          await FirebaseFirestore.instance
              .collection('matches')
              .where('createdBy', isEqualTo: user.uid)
              .get();

      for (final doc in matchQuery.docs) {
        await doc.reference.delete();
      }

      // Step 3: Delete statistics document (if it exists)
      await FirebaseFirestore.instance
          .collection('stats')
          .doc(user.uid)
          .delete()
          .catchError((_) {
            // If stats doc doesn't exist, ignore
          });

      // Step 4: Delete user profile document
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();

      // Step 5: Delete auth account
      await user.delete();

      // Step 6: Navigate to SignInPage
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
        (route) => false,
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
                  () => _showChangePasswordDialog(context),
                ),
                buildProfileOption(
                  context,
                  "Statistics",
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => StatisticsScreen(
                            userId: userId,
                          ), // Using current user's stats
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
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const SignInPage()),
                        (route) => false,
                      );
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

  void _showChangePasswordDialog(BuildContext context) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Change Password"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                  ),
                ),
                TextField(
                  controller: newController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New Password'),
                ),
                TextField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final current = currentController.text.trim();
                  final newPass = newController.text.trim();
                  final confirm = confirmController.text.trim();

                  if (newPass != confirm) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Passwords don't match")),
                    );
                    return;
                  }

                  try {
                    final user = FirebaseAuth.instance.currentUser!;
                    final cred = EmailAuthProvider.credential(
                      email: user.email!,
                      password: current,
                    );

                    await user.reauthenticateWithCredential(cred);
                    await user.updatePassword(newPass);

                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Password changed successfully"),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: ${e.toString()}")),
                    );
                  }
                },
                child: const Text("Update"),
              ),
            ],
          ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Delete Account"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "This will permanently delete your account and all match history/data. "
                  "Please enter your password to confirm.",
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
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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
}
