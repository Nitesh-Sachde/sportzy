import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:sportzy/features/home/screen/past_match_scorecard.dart';
import 'package:sportzy/features/home/screen/live_match_scorecard.dart'; // Add this import

class DynamicLinkService {
  static Future<Uri> createMatchDynamicLink(String matchId) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix:
          'https://sportzy.page.link', // Your Firebase dynamic link domain
      link: Uri.parse('https://sportzy.com/match?matchId=$matchId'),
      androidParameters: AndroidParameters(
        packageName: 'com.example.sportzy',
        minimumVersion: 1,
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: 'Check out this Match!',
        description: 'Tap to view match updates.',
      ),
    );

    final ShortDynamicLink shortLink = await FirebaseDynamicLinks.instance
        .buildShortLink(parameters);
    return shortLink.shortUrl;
  }

  static Future<void> handleDynamicLinks(BuildContext context) async {
    // App opened from background or killed
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();
    _handleLinkData(initialLink, context);

    // App opened in foreground
    FirebaseDynamicLinks.instance.onLink.listen((event) {
      _handleLinkData(event, context);
    });
  }

  static Future<void> _handleLinkData(
    PendingDynamicLinkData? data,
    BuildContext context,
  ) async {
    final Uri? deepLink = data?.link;
    if (deepLink != null && deepLink.queryParameters.containsKey('matchId')) {
      final matchId = deepLink.queryParameters['matchId']!;

      // Check match status from Firestore
      try {
        final matchDoc =
            await FirebaseFirestore.instance
                .collection('matches')
                .doc(matchId)
                .get();

        if (!matchDoc.exists) {
          _showErrorDialog(context, "Match not found");
          return;
        }

        final status = matchDoc.data()?['status'] as String?;

        // Navigate based on match status
        if (context.mounted) {
          if (status == 'live') {
            // Navigate to live match scorecard for live matches
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LiveMatchScoreCard(matchId: matchId),
              ),
            );
          } else if (status == 'completed') {
            // Navigate to past match scorecard for completed matches
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PastMatchScoreCard(matchId: matchId),
              ),
            );
          } else {
            // Handle other statuses (upcoming, cancelled, etc.)
            _showErrorDialog(
              context,
              "This match is not active yet or has been cancelled",
            );
          }
        }
      } catch (e) {
        print('Error handling dynamic link: $e');
        if (context.mounted) {
          _showErrorDialog(
            context,
            "Error opening match: ${e.toString().split('\n')[0]}",
          );
        }
      }
    }
  }

  // Helper method to show error dialogs
  static void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Match Error'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}
