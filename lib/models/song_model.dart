import 'package:on_audio_query/on_audio_query.dart';

/// Represents a single song/track in the music library.
class Song {
  final int id;
  final String title;
  final String artist;
  final String album;
  final int duration; // in milliseconds
  final String? uri;
  final int? albumId;
  final String? genre;
  final String? folderPath;
  int playCount;
  DateTime? lastPlayedAt;
  bool isFavorite;

  Song({
    required this.id,
    required this.title,
    this.artist = 'Unknown Artist',
    this.album = 'Unknown Album',
    this.duration = 0,
    this.uri,
    this.albumId,
    this.genre,
    this.folderPath,
    this.playCount = 0,
    this.lastPlayedAt,
    this.isFavorite = false,
  });

  /// Create a Song from on_audio_query SongModel
  factory Song.fromSongModel(SongModel model) {
    // Extract folder path from URI
    String? folder;
    final data = model.data;
    final lastSep = data.lastIndexOf('/');
    if (lastSep > 0) {
      folder = data.substring(0, lastSep);
    }

    return Song(
      id: model.id,
      title: model.title,
      artist: model.artist ?? 'Unknown Artist',
      album: model.album ?? 'Unknown Album',
      duration: model.duration ?? 0,
      uri: model.uri,
      albumId: model.albumId,
      genre: model.genre,
      folderPath: folder,
    );
  }

  /// Formatted duration string (e.g., "3:45")
  String get formattedDuration {
    final d = Duration(milliseconds: duration);
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString();
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:${minutes.padLeft(2, '0')}:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Song && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
