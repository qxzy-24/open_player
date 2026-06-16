import 'dart:async';

import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import '../models/song_model.dart';
import '../models/playlist_model.dart';
import '../services/music_library_service.dart';
import '../services/storage_service.dart';

/// Manages the music library state including songs, albums, artists,
/// genres, favorites, playlists, recently played, and most played.
class LibraryProvider extends ChangeNotifier {
  final MusicLibraryService _libraryService = MusicLibraryService();
  final StorageService _storage = StorageService();

  List<Song> _songs = [];
  List<AlbumModel> _albums = [];
  List<ArtistModel> _artists = [];
  List<GenreModel> _genres = [];
  List<Song> _filteredSongs = [];
  Set<int> _favoriteIds = {};
  List<int> _recentlyPlayedIds = [];
  Map<int, int> _playCounts = {};
  List<Playlist> _playlists = [];

  List<Song> _cachedFavoriteSongs = [];
  bool _favoritesDirty = true;
  bool _isLoading = false;
  bool _hasPermission = false;
  String _searchQuery = '';
  String _errorMessage = '';
  Timer? _searchDebounce;

  // ── Getters ───────────────────────────────────────────────
  MusicLibraryService get libraryService => _libraryService;
  List<Song> get allSongs => _songs;
  List<Song> get songs => _searchQuery.isEmpty ? _songs : _filteredSongs;
  List<AlbumModel> get albums => _albums;
  List<ArtistModel> get artists => _artists;
  List<GenreModel> get genres => _genres;
  List<Playlist> get playlists => _playlists;

  List<Song> get favoriteSongs {
    if (_favoritesDirty) {
      _cachedFavoriteSongs =
          _songs.where((s) => _favoriteIds.contains(s.id)).toList();
      _favoritesDirty = false;
    }
    return _cachedFavoriteSongs;
  }

  List<Song> get recentlyPlayed {
    final songMap = {for (final s in _songs) s.id: s};
    return _recentlyPlayedIds
        .where((id) => songMap.containsKey(id))
        .map((id) => songMap[id]!)
        .toList();
  }

  List<Song> get mostPlayed {
    final sorted = _songs.where((s) => s.playCount > 0).toList()
      ..sort((a, b) => b.playCount.compareTo(a.playCount));
    return sorted.take(50).toList();
  }

  /// Get unique folder paths from all songs.
  List<String> get folders {
    final folderSet = <String>{};
    for (final song in _songs) {
      if (song.folderPath != null && song.folderPath!.isNotEmpty) {
        folderSet.add(song.folderPath!);
      }
    }
    final list = folderSet.toList()..sort();
    return list;
  }

  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;
  String get searchQuery => _searchQuery;
  String get errorMessage => _errorMessage;
  int get totalSongs => _songs.length;
  int get totalAlbums => _albums.length;
  int get totalArtists => _artists.length;

  /// Check permissions, load persisted data, and load library.
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    // Load persisted data
    _favoriteIds = await _storage.loadFavorites();
    _recentlyPlayedIds = await _storage.loadRecentlyPlayed();
    _playCounts = await _storage.loadPlayCounts();
    await _loadPlaylists();

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
        _libraryService.queryGenres(),
      ]);

      _songs = results[0] as List<Song>;
      _albums = results[1] as List<AlbumModel>;
      _artists = results[2] as List<ArtistModel>;
      _genres = results[3] as List<GenreModel>;
      _favoritesDirty = true;

      // Apply persisted data to songs
      for (final song in _songs) {
        song.isFavorite = _favoriteIds.contains(song.id);
        song.playCount = _playCounts[song.id] ?? 0;
      }

      _applyFilter(shouldNotify: false);
    } catch (e) {
      _errorMessage = 'Failed to load music library: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Search songs.
  void search(String query) {
    _searchQuery = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), _applyFilter);
  }

  void _applyFilter({bool shouldNotify = true}) {
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      _filteredSongs = _songs.where((song) {
        return song.title.toLowerCase().contains(lowerQuery) ||
            song.artist.toLowerCase().contains(lowerQuery) ||
            song.album.toLowerCase().contains(lowerQuery);
      }).toList();
    } else {
      _filteredSongs = [];
    }

    if (shouldNotify) {
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    _searchQuery = '';
    _filteredSongs = [];
    notifyListeners();
  }

  // ── Favorites ────────────────────────────────────────────
  void toggleFavorite(Song song) {
    if (_favoriteIds.contains(song.id)) {
      _favoriteIds.remove(song.id);
      song.isFavorite = false;
    } else {
      _favoriteIds.add(song.id);
      song.isFavorite = true;
    }
    _favoritesDirty = true;
    _storage.saveFavorites(_favoriteIds);
    notifyListeners();
  }

  bool isFavorite(int songId) => _favoriteIds.contains(songId);

  // ── Recently Played ──────────────────────────────────────
  void addToRecentlyPlayed(Song song) {
    _recentlyPlayedIds.remove(song.id);
    _recentlyPlayedIds.insert(0, song.id);
    if (_recentlyPlayedIds.length > 50) {
      _recentlyPlayedIds = _recentlyPlayedIds.sublist(0, 50);
    }
    _storage.saveRecentlyPlayed(_recentlyPlayedIds);

    // Update play count
    song.playCount++;
    _playCounts[song.id] = song.playCount;
    _storage.savePlayCounts(_playCounts);

    notifyListeners();
  }

  // ── Playlists ────────────────────────────────────────────
  Future<void> _loadPlaylists() async {
    final data = await _storage.loadPlaylists();
    _playlists = data.map((json) {
      return Playlist(
        id: json['id'] as String,
        name: json['name'] as String,
        songIds: (json['songIds'] as List).cast<int>(),
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
    }).toList();
  }

  Future<void> _savePlaylists() async {
    final data = _playlists.map((p) => p.toJson()).toList();
    await _storage.savePlaylists(data);
  }

  void createPlaylist(String name) {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    _playlists.add(playlist);
    _savePlaylists();
    notifyListeners();
  }

  void deletePlaylist(String id) {
    _playlists.removeWhere((p) => p.id == id);
    _savePlaylists();
    notifyListeners();
  }

  void renamePlaylist(String id, String newName) {
    final playlist = _playlists.firstWhere((p) => p.id == id);
    playlist.name = newName;
    _savePlaylists();
    notifyListeners();
  }

  void addSongToPlaylist(String playlistId, Song song) {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    if (!playlist.songIds.contains(song.id)) {
      playlist.songIds.add(song.id);
      _savePlaylists();
      notifyListeners();
    }
  }

  void removeSongFromPlaylist(String playlistId, int songId) {
    final playlist = _playlists.firstWhere((p) => p.id == playlistId);
    playlist.songIds.remove(songId);
    _savePlaylists();
    notifyListeners();
  }

  List<Song> getPlaylistSongs(Playlist playlist) {
    final songMap = {for (final s in _songs) s.id: s};
    return playlist.songIds
        .where((id) => songMap.containsKey(id))
        .map((id) => songMap[id]!)
        .toList();
  }

  // ── Queries ──────────────────────────────────────────────
  List<Song> getSongsForAlbum(int albumId) {
    return _songs.where((s) => s.albumId == albumId).toList();
  }

  List<Song> getSongsForArtist(String artistName) {
    return _songs.where((s) => s.artist == artistName).toList();
  }

  List<Song> getSongsForGenre(String genreName) {
    return _songs
        .where((s) => s.genre?.toLowerCase() == genreName.toLowerCase())
        .toList();
  }

  List<Song> getSongsForFolder(String folderPath) {
    return _songs.where((s) => s.folderPath == folderPath).toList();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}
