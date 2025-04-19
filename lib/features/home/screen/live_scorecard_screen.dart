// 📁 lib/screens/live_scorecard_screen.dart

// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/create_match/model/match_model.dart';
import 'package:sportzy/features/home/provider/match_data_provider.dart';

class LiveScorecardScreen extends ConsumerWidget {
  final String matchId;

  const LiveScorecardScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchAsync = ref.watch(matchProvider(matchId));
    final screenHeight = ScreenSize.screenHeight(context);
    final screenWidth = ScreenSize.screenWidth(context);

    return Scaffold(
      body: matchAsync.when(
        data:
            (match) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CustomAppBar(matchId: match.matchId),
                _MatchInfoCard(match: match),
                _TeamsAndPlayers(match: match),
                _ScoreBox(match: match),
                SizedBox(height: screenHeight * 0.02),
                _Timeline(match: match),
              ],
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _CustomAppBar extends StatelessWidget {
  final String matchId;
  const _CustomAppBar({required this.matchId});

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenSize.screenWidth(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: 12,
      ),
      color: Colors.indigo,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Text(
              matchId,
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => Share.share('Check out the live match: $matchId'),
          ),
        ],
      ),
    );
  }
}

class _MatchInfoCard extends StatelessWidget {
  final MatchModel match;
  const _MatchInfoCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.circle, color: Colors.red, size: 10),
              const SizedBox(width: 6),
              Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'SET ${match.currentSetIndex + 1}',
                  style: const TextStyle(color: Colors.yellow),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${match.sport} ${match.mode}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenWidth * 0.045,
            ),
          ),
          Text(match.location),
          Text(DateFormat.yMMMMd().add_jm().format(match.createdAt)),
        ],
      ),
    );
  }
}

class _TeamsAndPlayers extends StatelessWidget {
  final MatchModel match;
  const _TeamsAndPlayers({required this.match});

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenSize.screenWidth(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(match.team1Name),
              const SizedBox(width: 12),
              const Text('vs'),
              const SizedBox(width: 12),
              Text(match.team2Name),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _PlayerChip(name: match.team1PlayerName.join(', ')),
              _PlayerChip(name: match.team2PlayerName.join(', ')),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlayerChip extends StatelessWidget {
  final String name;
  const _PlayerChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.indigo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(name, style: const TextStyle(color: Colors.white)),
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final MatchModel match;
  const _ScoreBox({required this.match});

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenSize.screenHeight(context);
    final screenWidth = ScreenSize.screenWidth(context);
    final currentScores = match.scores[match.currentSetIndex];
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ScoreTile(score: currentScores[0]),
          _ScoreTile(score: currentScores[1]),
        ],
      ),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  final int score;
  const _ScoreTile({required this.score});

  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenSize.screenHeight(context);
    final screenWidth = ScreenSize.screenWidth(context);

    return Container(
      height: screenHeight * 0.13,
      width: screenWidth * 0.25,
      decoration: BoxDecoration(
        color: Colors.amber[300],
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Text(
        '$score',
        style: TextStyle(
          fontSize: screenWidth * 0.08,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final MatchModel match;
  const _Timeline({required this.match});

  Color _getColor(
    int setIndex,
    int teamScore,
    int opponentScore,
    int currentSetIndex,
  ) {
    if (setIndex == currentSetIndex) return Colors.indigo;
    return teamScore > opponentScore ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenSize.screenWidth(context);

    return Column(
      children: List.generate(match.scores.length, (index) {
        final score = match.scores[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SetScoreTile(
                score: score[0],
                color: _getColor(
                  index,
                  score[0],
                  score[1],
                  match.currentSetIndex,
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'SET ${index + 1}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              _SetScoreTile(
                score: score[1],
                color: _getColor(
                  index,
                  score[1],
                  score[0],
                  match.currentSetIndex,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _SetScoreTile extends StatelessWidget {
  final int score;
  final Color color;
  const _SetScoreTile({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenSize.screenWidth(context);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$score',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: screenWidth * 0.045,
        ),
      ),
    );
  }
}
