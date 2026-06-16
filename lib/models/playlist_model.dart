/// Represents a user-created playlist.
class Playlist {
  final String id;
  String name;
  final List<int> songIds;
  final DateTime createdAt;

  Playlist({
    required this.id,
    required this.name,
    List<int>? songIds,
    DateTime? createdAt,
  })  : songIds = songIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  int get songCount => songIds.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'songIds': songIds,
    'createdAt': createdAt.toIso8601String(),
  };
}
