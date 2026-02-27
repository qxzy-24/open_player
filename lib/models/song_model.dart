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
  bool isFavorite;

  Song({
    required this.id,
    required this.title,
    this.artist = 'Unknown Artist',
    this.album = 'Unknown Album',
    this.duration = 0,
    this.uri,
    this.albumId,
    this.isFavorite = false,
  });

  /// Create a Song from on_audio_query SongModel
  factory Song.fromSongModel(SongModel model) {
    return Song(
      id: model.id,
      title: model.title,
      artist: model.artist ?? 'Unknown Artist',
      album: model.album ?? 'Unknown Album',
      duration: model.duration ?? 0,
      uri: model.uri,
      albumId: model.albumId,
    );
  }

  /// Formatted duration string (e.g., "3:45")
  String get formattedDuration {
    final d = Duration(milliseconds: duration);
    final minutes = d.inMinutes.remainder(60).toString();
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Song && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
