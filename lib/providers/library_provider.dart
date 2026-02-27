import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/song_model.dart';
import '../services/music_library_service.dart';

/// Manages the music library state.
class LibraryProvider extends ChangeNotifier {
  final MusicLibraryService _libraryService = MusicLibraryService();

  List<Song> _songs = [];
  List<AlbumModel> _albums = [];
  List<ArtistModel> _artists = [];
  List<Song> _filteredSongs = [];
  Set<int> _favoriteIds = {};
  bool _isLoading = false;
  bool _hasPermission = false;
  String _searchQuery = '';
  String _errorMessage = '';

  // ── Getters ───────────────────────────────────────────────────
  MusicLibraryService get libraryService => _libraryService;
  List<Song> get songs => _searchQuery.isEmpty ? _songs : _filteredSongs;
  List<AlbumModel> get albums => _albums;
  List<ArtistModel> get artists => _artists;
  List<Song> get favoriteSongs =>
      _songs.where((s) => _favoriteIds.contains(s.id)).toList();
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;
  String get searchQuery => _searchQuery;
  String get errorMessage => _errorMessage;
  int get totalSongs => _songs.length;
  int get totalAlbums => _albums.length;
  int get totalArtists => _artists.length;

  /// Check permissions and load library.
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    _hasPermission = await _libraryService.requestPermissions();
    if (_hasPermission) {
      await loadLibrary();
    } else {
      _errorMessage = 'Storage permission is required to access your music.';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load all music data.
  Future<void> loadLibrary() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await Future.wait([
        _libraryService.querySongs(),
        _libraryService.queryAlbums(),
        _libraryService.queryArtists(),
      ]);

      _songs = results[0] as List<Song>;
      _albums = results[1] as List<AlbumModel>;
      _artists = results[2] as List<ArtistModel>;

      // Apply favorites
      for (final song in _songs) {
        song.isFavorite = _favoriteIds.contains(song.id);
      }
    } catch (e) {
      _errorMessage = 'Failed to load music library: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Search songs.
  void search(String query) {
    _searchQuery = query;
    if (query.isNotEmpty) {
      final lowerQuery = query.toLowerCase();
      _filteredSongs = _songs.where((song) {
        return song.title.toLowerCase().contains(lowerQuery) ||
            song.artist.toLowerCase().contains(lowerQuery) ||
            song.album.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredSongs = [];
    notifyListeners();
  }

  /// Toggle favorite status for a song.
  void toggleFavorite(Song song) {
    if (_favoriteIds.contains(song.id)) {
      _favoriteIds.remove(song.id);
      song.isFavorite = false;
    } else {
      _favoriteIds.add(song.id);
      song.isFavorite = true;
    }
    notifyListeners();
  }

  bool isFavorite(int songId) => _favoriteIds.contains(songId);

  /// Get songs for a specific album.
  List<Song> getSongsForAlbum(int albumId) {
    return _songs.where((s) => s.albumId == albumId).toList();
  }

  /// Get songs for a specific artist.
  List<Song> getSongsForArtist(String artistName) {
    return _songs.where((s) => s.artist == artistName).toList();
  }
}
