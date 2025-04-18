import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/auth/provider/auth_provider.dart';
import 'package:sportzy/features/home/screen/home_page.dart';
import 'package:sportzy/features/auth/screen/sign_in_page.dart';
import 'package:sportzy/features/auth/screen/verification_link_sent_page.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final justSignedIn = ref.watch(justSignedInProvider);
    double screenWidth = ScreenSize.screenWidth(context);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const SignInPage(); // ❌ Not signed in
        }

        if (user.emailVerified) {
          return const HomePage(); // ✅ Signed in & verified
        }

        // 🟡 Not verified
        if (justSignedIn) {
          // Reset `justSignedIn` flag after navigation
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(justSignedInProvider.notifier).state = false;

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const VerificationLinkSentPage(),
              ),
            );
          });

          // Loading screen while navigating
          return Scaffold(
            body: Container(
              color: AppColors.white,
              child: Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: AppColors.primary,
                  size: screenWidth * 0.2,
                ),
              ),
            ),
          );
        }

        // 🟡 Not verified & not just signed in (e.g. app reopened)
        return const VerificationLinkSentPage();
      },
      loading:
          () => Scaffold(
            body: Container(
              color: AppColors.white,
              child: Center(
                child: LoadingAnimationWidget.staggeredDotsWave(
                  color: AppColors.primary,
                  size: screenWidth * 0.2,
                ),
              ),
            ),
          ),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }
}
