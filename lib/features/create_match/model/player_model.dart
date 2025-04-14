// Player model class
class Player {
  final String name;
  final String id; // Unique identifier for the player
  final List<String> keywords;

  var photoUrl; // Optional, you can add this if needed

  Player({required this.name, required this.id, this.keywords = const []});

  // CopyWith method to easily create a new instance with modified data
  Player copyWith({String? name, String? uid, List<String>? keywords}) {
    return Player(
      name: name ?? this.name,
      id: uid ?? id,
      keywords: keywords ?? this.keywords,
    );
  }

  // Optionally, you can override toString, equals, and hashCode methods
  @override
  String toString() {
    return 'Player(name: $name, id: $id, keywords: $keywords)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Player && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
