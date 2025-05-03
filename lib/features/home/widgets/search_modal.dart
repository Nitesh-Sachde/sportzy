import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sportzy/core/theme/app_colors.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/create_match/model/match_model.dart';
import 'package:sportzy/features/home/provider/match_search_provider.dart';
import 'package:sportzy/features/home/screen/live_match_scorecard.dart';
import 'package:sportzy/features/home/screen/past_match_scorecard.dart';

class SearchModal extends ConsumerStatefulWidget {
  const SearchModal({super.key});

  @override
  ConsumerState<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends ConsumerState<SearchModal> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Request focus on the search field when the modal opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _performSearch(String value) {
    ref.read(searchQueryProvider.notifier).state = value;
    setState(() {
      _isSearching = value.isNotEmpty && value.length >= 2;
    });
  }

  void _navigateToMatchDetails(BuildContext context, MatchModel match) {
    Navigator.pop(context); // Close the search modal

    if (match.status == 'live') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LiveMatchScoreCard(matchId: match.matchId),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PastMatchScoreCard(matchId: match.matchId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = ScreenSize.screenWidth(context);
    final screenHeight = ScreenSize.screenHeight(context);
    final searchResults = ref.watch(matchSearchResultsProvider);

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: screenWidth * 0.15,
            height: 5,
            margin: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.01,
            ),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search matches by ID, team name, or location',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _performSearch('');
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                  horizontal: screenWidth * 0.05,
                ),
              ),
              onChanged: _performSearch,
            ),
          ),

          // Search results
          Expanded(
            child:
                _isSearching
                    ? searchResults.when(
                      data: (matches) {
                        if (matches.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: screenHeight * 0.08,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: screenHeight * 0.02),
                                Text(
                                  'No matches found',
                                  style: TextStyle(
                                    fontSize: screenHeight * 0.02,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.01,
                            horizontal: screenWidth * 0.02,
                          ),
                          itemCount: matches.length,
                          itemBuilder: (context, index) {
                            final match = matches[index];
                            return _buildSearchResultCard(
                              context,
                              match,
                              screenWidth,
                              screenHeight,
                            );
                          },
                        );
                      },
                      loading:
                          () =>
                              const Center(child: CircularProgressIndicator()),
                      error:
                          (error, stack) =>
                              Center(child: Text('Error: ${error.toString()}')),
                    )
                    : _buildInitialContent(screenHeight),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialContent(double screenHeight) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: screenHeight * 0.08,
            color: Colors.grey[300],
          ),
          SizedBox(height: screenHeight * 0.02),
          Text(
            'Enter at least 2 characters to search',
            style: TextStyle(
              fontSize: screenHeight * 0.02,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: screenHeight * 0.01),
          Text(
            'Search by match ID, team name, or location',
            style: TextStyle(
              fontSize: screenHeight * 0.016,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultCard(
    BuildContext context,
    MatchModel match,
    double width,
    double height,
  ) {
    final isBadminton = match.sport.toLowerCase() == 'badminton';
    final dateFormatter = DateFormat('MMM d, yyyy • hh:mm a');

    return Card(
      margin: EdgeInsets.symmetric(
        vertical: height * 0.008,
        horizontal: width * 0.02,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToMatchDetails(context, match),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.all(width * 0.03),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors:
                  isBadminton
                      ? [
                        AppColors.badmintoncardBackground.withOpacity(0.8),
                        AppColors.badmintoncardBackground,
                      ]
                      : [
                        AppColors.ttcardBackground.withOpacity(0.8),
                        AppColors.ttcardBackground,
                      ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Match ID and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    match.matchId,
                    style: TextStyle(
                      fontSize: height * 0.02,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.025,
                      vertical: height * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: match.status == 'live' ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      match.status == 'live' ? 'LIVE' : 'COMPLETED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: height * 0.014,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.01),

              // Sport and Date
              Row(
                children: [
                  Icon(
                    isBadminton ? Icons.sports_tennis : Icons.sports_tennis,
                    color: Colors.white70,
                    size: height * 0.02,
                  ),
                  SizedBox(width: width * 0.01),
                  Text(
                    "${match.sport} ${match.mode}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: height * 0.016,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    dateFormatter.format(match.createdAt),
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: height * 0.014,
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.01),

              // Location
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: Colors.white70,
                    size: height * 0.02,
                  ),
                  SizedBox(width: width * 0.01),
                  Expanded(
                    child: Text(
                      match.location,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: height * 0.016,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),

              SizedBox(height: height * 0.015),

              // Team names with VS
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      match.team1Name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: height * 0.018,
                      ),
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.03),
                    child: Text(
                      "VS",
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: height * 0.018,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      match.team2Name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: height * 0.018,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
