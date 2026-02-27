import 'song_model.dart';

/// Represents a user-created playlist.
class Playlist {
  final String id;
  String name;
  final List<Song> songs;
  final DateTime createdAt;

  Playlist({
    required this.id,
    required this.name,
    List<Song>? songs,
    DateTime? createdAt,
  })  : songs = songs ?? [],
        createdAt = createdAt ?? DateTime.now();

  int get songCount => songs.length;

  Duration get totalDuration {
    final totalMs = songs.fold<int>(0, (sum, s) => sum + s.duration);
    return Duration(milliseconds: totalMs);
  }

  String get formattedTotalDuration {
    final d = totalDuration;
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m';
  }

  void addSong(Song song) {
    if (!songs.contains(song)) {
      songs.add(song);
    }
  }

  void removeSong(Song song) {
    songs.remove(song);
  }
}
