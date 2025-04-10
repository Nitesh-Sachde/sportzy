import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MatchMode { singles, doubles }

final matchModeProvider = StateProvider<MatchMode>((ref) => MatchMode.singles);
final setCountProvider = StateProvider<int>((ref) => 3); // default
final pointCountProvider = StateProvider<int>((ref) => 21); // default
