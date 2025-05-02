import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sportzy/features/create_match/screens/create_match_screen.dart';
import 'package:sportzy/features/home/screen/home_page.dart';
import 'package:sportzy/features/auth/screen/sign_in_page.dart';
import 'package:sportzy/features/auth/screen/sign_up_page.dart';
import 'package:sportzy/features/home/screen/live_match_scorecard.dart';
import 'package:sportzy/features/home/screen/past_match_scorecard.dart';
import 'package:sportzy/router/routes.dart';
import 'package:sportzy/firebase_options.dart';
import 'package:sportzy/core/utils/dynamic_link_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData? data) {
    final deepLink = data?.link;
    if (deepLink != null) {
      // parse matchId and navigate
    }
  });
  final PendingDynamicLinkData? initialLink =
      await FirebaseDynamicLinks.instance.getInitialLink();

  final Uri? deepLink = initialLink?.link;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  // Request permission
  await messaging.requestPermission();

  // Get the token
  String? token = await messaging.getToken();

  runApp(const ProviderScope(child: SportzyApp()));
}

class SportzyApp extends ConsumerStatefulWidget {
  const SportzyApp({super.key});

  @override
  ConsumerState<SportzyApp> createState() => _SportzyAppState();
}

class _SportzyAppState extends ConsumerState<SportzyApp> {
  @override
  void initState() {
    super.initState();
    _initDynamicLinks();
  }

  void _initDynamicLinks() async {
    await DynamicLinkService.handleDynamicLinks((matchId) async {
      final doc =
          await FirebaseFirestore.instance
              .collection('matches')
              .doc(matchId)
              .get();

      if (!doc.exists) {
        // Optionally show an error or snackbar
        return;
      }

      final data = doc.data();
      final isLive = data?['matchStatus'] == 'live';

      navigatorKey.currentState?.pushNamed(
        isLive ? Routes.liveMatchScoreCard : Routes.pastMatchScoreCard,
        arguments: matchId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: "Sportzy",
      theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
      home: const AuthWrapper(), // This will handle the authentication check
      routes: {
        Routes.home: (context) => const HomePage(),
        Routes.signIn: (context) => const SignInPage(),
        Routes.signUp: (context) => const SignUpPage(),
        Routes.createMatch: (context) => const CreateMatchScreen(),
        Routes.liveMatchScoreCard: (context) {
          final matchId = ModalRoute.of(context)!.settings.arguments as String;
          return LiveMatchScoreCard(matchId: matchId);
        },
        Routes.pastMatchScoreCard: (context) {
          final matchId = ModalRoute.of(context)!.settings.arguments as String;
          return PastMatchScoreCard(matchId: matchId);
        },
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Stream to listen to auth state changes
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // You can show a loading indicator if needed
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          // User is logged in, show the HomePage
          return const HomePage();
        } else {
          // User is not logged in, show the SignInPage
          return const SignInPage();
        }
      },
    );
  }
}
