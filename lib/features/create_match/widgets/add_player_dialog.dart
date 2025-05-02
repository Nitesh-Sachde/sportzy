import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sportzy/core/utils/screen_size.dart';
import 'package:sportzy/features/create_match/provider/add_players_provider.dart';
import 'package:sportzy/features/create_match/model/player_model.dart';

class AddPlayerDialog extends ConsumerStatefulWidget {
  final int teamNumber;
  final bool isDoubles;

  const AddPlayerDialog({
    super.key,
    required this.teamNumber,
    required this.isDoubles,
  });

  @override
  ConsumerState<AddPlayerDialog> createState() => _AddPlayerDialogState();
}

class _AddPlayerDialogState extends ConsumerState<AddPlayerDialog> {
  String query = '';
  List<Player> searchResults = [];
  List<Player> selectedPlayers = [];
  bool hasSearched = false;

  void search() async {
    final results = await ref
        .read(teamPlayersProvider(widget.teamNumber).notifier)
        .searchPlayers(query);

    // Exclude players already added to either team
    final team1 = ref.read(teamPlayersProvider(1));
    final team2 = ref.read(teamPlayersProvider(2));
    final allSelected = [...team1, ...team2];
    if (!mounted) return;
    setState(() {
      hasSearched = true;
      searchResults = results.where((p) => !allSelected.contains(p)).toList();
    });
  }

  void toggleSelect(Player player) {
    if (!mounted) return;
    setState(() {
      selectedPlayers.clear(); // Ensure only one player is selected
      selectedPlayers.add(player);
    });
  }

  void confirmSelection() {
    final notifier = ref.read(teamPlayersProvider(widget.teamNumber).notifier);
    for (var player in selectedPlayers) {
      notifier.addPlayer(player, widget.isDoubles);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final height = ScreenSize.screenHeight(context);
    final width = ScreenSize.screenWidth(context);

    final tilePadding = height * 0.012;
    final borderRadius = height * 0.02;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: width * 0.05,
          vertical: height * 0.02,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).viewInsets.bottom > 0
                    ? height *
                        0.7 // More height when keyboard is open
                    : height * 0.6,
          ),
          padding: EdgeInsets.all(width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Search Player',
                style: TextStyle(
                  fontSize: height * 0.024,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height * 0.02),

              TextField(
                decoration: InputDecoration(
                  hintText: 'Enter name or ID',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: height * 0.018,
                    horizontal: width * 0.03,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                onChanged: (val) => setState(() => query = val.trim()),
              ),

              SizedBox(height: height * 0.015),

              SizedBox(
                width: width,
                height: height * 0.06,
                child: ElevatedButton(
                  onPressed: search,
                  child: const Text('Search'),
                ),
              ),

              SizedBox(height: height * 0.015),

              if (hasSearched)
                searchResults.isEmpty
                    ? Padding(
                      padding: EdgeInsets.symmetric(vertical: height * 0.02),
                      child: Center(
                        child: Text(
                          'No results found',
                          style: TextStyle(fontSize: height * 0.018),
                        ),
                      ),
                    )
                    : Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics:
                            const AlwaysScrollableScrollPhysics(), // Ensures scrolling works in all cases
                        itemCount: searchResults.length,
                        itemBuilder: (_, index) {
                          final player = searchResults[index];
                          final isSelected = selectedPlayers.contains(player);
                          return Padding(
                            padding: EdgeInsets.only(bottom: tilePadding),
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  borderRadius,
                                ),
                              ),
                              child: ListTile(
                                leading:
                                    player.photoUrl != null &&
                                            player.photoUrl!.isNotEmpty
                                        ? CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            player.photoUrl!,
                                          ),
                                          radius: height * 0.025,
                                        )
                                        : CircleAvatar(
                                          radius: height * 0.025,
                                          backgroundColor: Colors.blueGrey,
                                          child: Text(
                                            player.name.isNotEmpty
                                                ? player.name[0]
                                                : '?',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: height * 0.02,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                title: Text(
                                  player.name,
                                  style: TextStyle(
                                    fontSize: height * 0.02,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text("ID: ${player.id}"),
                                trailing:
                                    isSelected
                                        ? Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: height * 0.028,
                                        )
                                        : null,
                                onTap: () => toggleSelect(player),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  SizedBox(width: width * 0.02),
                  TextButton(
                    onPressed:
                        selectedPlayers.isEmpty ? null : confirmSelection,
                    child: const Text('Add Player'),
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
