// lib/providers/match_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/models/match_model.dart';
import 'package:sportzy/features/my_matches/data/dummy_data.dart';

final matchListProvider = Provider<List<Match>>((ref) => dummyMatches);
