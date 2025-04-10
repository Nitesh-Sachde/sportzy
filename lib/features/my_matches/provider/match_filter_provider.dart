// match_filter_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum for tabs
enum MatchFilter { live, completed }

final matchFilterProvider = StateProvider<MatchFilter>(
  (ref) => MatchFilter.live,
);
