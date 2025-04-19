import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

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

  static Future<void> handleDynamicLinks(
    Function(String matchId) onMatchLinkOpened,
  ) async {
    // App opened from background or killed
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();
    _handleLinkData(initialLink, onMatchLinkOpened);

    // App opened in foreground
    FirebaseDynamicLinks.instance.onLink.listen((event) {
      _handleLinkData(event, onMatchLinkOpened);
    });
  }

  static void _handleLinkData(
    PendingDynamicLinkData? data,
    Function(String) onMatchLinkOpened,
  ) {
    final Uri? deepLink = data?.link;
    if (deepLink != null && deepLink.queryParameters.containsKey('matchId')) {
      final matchId = deepLink.queryParameters['matchId']!;
      onMatchLinkOpened(matchId);
    }
  }
}
