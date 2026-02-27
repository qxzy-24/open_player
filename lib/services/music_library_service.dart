import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/song_model.dart';

/// Service to query the device's music library.
class MusicLibraryService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  OnAudioQuery get audioQuery => _audioQuery;

  /// Request storage/audio permissions.
  Future<bool> requestPermissions() async {
    // For Android 13+ use audio permission, older uses storage
    if (defaultTargetPlatform == TargetPlatform.android) {
      final audioStatus = await Permission.audio.request();
      if (audioStatus.isGranted) return true;

      // Fallback to storage permission for older Android
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    }

    // iOS - media library
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final status = await Permission.mediaLibrary.request();
      return status.isGranted;
    }

    // Desktop platforms don't need runtime permissions
    return true;
  }

  /// Check if permissions are granted.
  Future<bool> hasPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await Permission.audio.isGranted ||
          await Permission.storage.isGranted;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return await Permission.mediaLibrary.isGranted;
    }
    return true;
  }

  /// Query all songs on the device.
  Future<List<Song>> querySongs({
    SongSortType sortType = SongSortType.TITLE,
    OrderType orderType = OrderType.ASC_OR_SMALLER,
  }) async {
    try {
      final songs = await _audioQuery.querySongs(
        sortType: sortType,
        orderType: orderType,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      return songs
          .where((s) => s.duration != null && s.duration! > 0)
          .map((s) => Song.fromSongModel(s))
          .toList();
    } catch (e) {
      print('Error querying songs: $e');
      return [];
    }
  }

  /// Query all albums.
  Future<List<AlbumModel>> queryAlbums({
    AlbumSortType sortType = AlbumSortType.ALBUM,
    OrderType orderType = OrderType.ASC_OR_SMALLER,
  }) async {
    try {
      return await _audioQuery.queryAlbums(
        sortType: sortType,
        orderType: orderType,
      );
    } catch (e) {
      print('Error querying albums: $e');
      return [];
    }
  }

  /// Query all artists.
  Future<List<ArtistModel>> queryArtists({
    ArtistSortType sortType = ArtistSortType.ARTIST,
    OrderType orderType = OrderType.ASC_OR_SMALLER,
  }) async {
    try {
      return await _audioQuery.queryArtists(
        sortType: sortType,
        orderType: orderType,
      );
    } catch (e) {
      print('Error querying artists: $e');
      return [];
    }
  }

  /// Search songs by query string.
  Future<List<Song>> searchSongs(String query, List<Song> allSongs) async {
    if (query.isEmpty) return allSongs;
    final lowerQuery = query.toLowerCase();
    return allSongs.where((song) {
      return song.title.toLowerCase().contains(lowerQuery) ||
          song.artist.toLowerCase().contains(lowerQuery) ||
          song.album.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
