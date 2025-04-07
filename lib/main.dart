import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sportzy/features/home/pages/home_page.dart';
import 'package:sportzy/features/auth/pages/sign_in_page.dart';
import 'package:sportzy/features/auth/pages/sign_up_page.dart';
import 'package:sportzy/router/auth_wrapper.dart';
import 'package:sportzy/router/routes.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: SportzyApp()));
}

class SportzyApp extends ConsumerWidget {
  const SportzyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Sportzy",
      theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
      home: AuthWrapper(),
      routes: {
        Routes.home: (context) => const HomePage(),
        Routes.signIn: (context) => const SignInPage(),
        Routes.signUp: (context) => const SignUpPage(),
      },
    );
  }
}
