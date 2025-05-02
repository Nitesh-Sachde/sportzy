import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/features/playerprofile/model/statistics_model.dart';
import 'package:sportzy/features/playerprofile/service/statistics_service.dart';

final statisticsServiceProvider = Provider<StatisticsService>((ref) {
  return StatisticsService();
});

// Use StreamProvider to get real-time updates
final userStatisticsProvider = StreamProvider.autoDispose<PlayerStatistics>((
  ref,
) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) {
    throw Exception('User not authenticated');
  }

  // Listen to the document that will act as a trigger for updates
  return FirebaseFirestore.instance
      .collection('player_stats')
      .doc(userId)
      .collection('overall')
      .doc('stats')
      .snapshots()
      .asyncMap((snapshot) async {
        final statisticsService = ref.read(statisticsServiceProvider);
        return await statisticsService.getUserStatistics(userId);
      });
});

final specificUserStatisticsProvider = StreamProvider.autoDispose
    .family<PlayerStatistics, String>((ref, userId) {
      // Listen to the document that will act as a trigger for updates
      return FirebaseFirestore.instance
          .collection('player_stats')
          .doc(userId)
          .collection('overall')
          .doc('stats')
          .snapshots()
          .asyncMap((snapshot) async {
            final statisticsService = ref.read(statisticsServiceProvider);
            return await statisticsService.getUserStatistics(userId);
          });
    });
