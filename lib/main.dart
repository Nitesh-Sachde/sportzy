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

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Remove duplicate code - we'll handle this in the app state
  // FirebaseDynamicLinks.instance.onLink.listen...
  // final PendingDynamicLinkData?...

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

    // Initialize dynamic links once the context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDynamicLinks();
    });
  }

  void _initDynamicLinks() async {
    // Handle initial link (app opened from link while app was closed)
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();

    if (initialLink != null) {
      _handleDynamicLink(initialLink);
    }

    // Handle links when app is in foreground
    FirebaseDynamicLinks.instance.onLink
        .listen((dynamicLinkData) {
          _handleDynamicLink(dynamicLinkData);
        })
        .onError((error) {
          print('Dynamic link error: $error');
        });
  }

  void _handleDynamicLink(PendingDynamicLinkData data) async {
    final Uri deepLink = data.link;
    if (deepLink.queryParameters.containsKey('matchId')) {
      final matchId = deepLink.queryParameters['matchId']!;

      try {
        final doc =
            await FirebaseFirestore.instance
                .collection('matches')
                .doc(matchId)
                .get();

        if (!doc.exists) {
          print('Match not found: $matchId');
          return;
        }

        final data = doc.data();
        // Check for 'status' not 'matchStatus'
        final isLive = data?['status'] == 'live';

        // Navigate to appropriate screen
        navigatorKey.currentState?.pushNamed(
          isLive ? Routes.liveMatchScoreCard : Routes.pastMatchScoreCard,
          arguments: matchId,
        );
      } catch (e) {
        print('Error handling dynamic link: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: "Sportzy",
      theme: ThemeData(textTheme: GoogleFonts.poppinsTextTheme()),
      home: const AuthWrapper(),
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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          return const HomePage();
        } else {
          return const SignInPage();
        }
      },
    );
  }
}
