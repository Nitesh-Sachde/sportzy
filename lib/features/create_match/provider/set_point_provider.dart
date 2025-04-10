import 'package:flutter_riverpod/flutter_riverpod.dart';

final setsProvider = StateProvider<int>((ref) => 1); // default 1 set
final pointsProvider = StateProvider<int>((ref) => 11); // default 11 points
