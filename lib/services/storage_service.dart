import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent storage service using SharedPreferences.
///
/// Handles persistence for favorites, playlists, recently played,
/// play counts, and user settings.
class StorageService {
  static const _keyFavorites = 'favorites';
  static const _keyRecentlyPlayed = 'recently_played';
  static const _keyPlayCounts = 'play_counts';
  static const _keyPlaylists = 'playlists';
  static const _keyGapless = 'setting_gapless';
  static const _keyCrossfadeDuration = 'setting_crossfade';
  static const _keyPlaybackSpeed = 'setting_speed';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ── Favorites ────────────────────────────────────────────
  Future<Set<int>> loadFavorites() async {
    final prefs = await _preferences;
    final list = prefs.getStringList(_keyFavorites) ?? [];
    return list.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toSet();
  }

  Future<void> saveFavorites(Set<int> ids) async {
    final prefs = await _preferences;
    await prefs.setStringList(
      _keyFavorites,
      ids.map((e) => e.toString()).toList(),
    );
  }

  // ── Recently Played ──────────────────────────────────────
  Future<List<int>> loadRecentlyPlayed() async {
    final prefs = await _preferences;
    final list = prefs.getStringList(_keyRecentlyPlayed) ?? [];
    return list.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toList();
  }

  Future<void> saveRecentlyPlayed(List<int> ids) async {
    final prefs = await _preferences;
    await prefs.setStringList(
      _keyRecentlyPlayed,
      ids.map((e) => e.toString()).toList(),
    );
  }

  // ── Play Counts ──────────────────────────────────────────
  Future<Map<int, int>> loadPlayCounts() async {
    final prefs = await _preferences;
    final json = prefs.getString(_keyPlayCounts);
    if (json == null) return {};
    final map = jsonDecode(json) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(int.parse(k), v as int));
  }

  Future<void> savePlayCounts(Map<int, int> counts) async {
    final prefs = await _preferences;
    final map = counts.map((k, v) => MapEntry(k.toString(), v));
    await prefs.setString(_keyPlayCounts, jsonEncode(map));
  }

  // ── Playlists ────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> loadPlaylists() async {
    final prefs = await _preferences;
    final json = prefs.getString(_keyPlaylists);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> savePlaylists(List<Map<String, dynamic>> playlists) async {
    final prefs = await _preferences;
    await prefs.setString(_keyPlaylists, jsonEncode(playlists));
  }

  // ── Settings ─────────────────────────────────────────────
  Future<bool> loadGapless() async {
    final prefs = await _preferences;
    return prefs.getBool(_keyGapless) ?? true;
  }

  Future<void> saveGapless(bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(_keyGapless, value);
  }

  Future<double> loadCrossfadeDuration() async {
    final prefs = await _preferences;
    return prefs.getDouble(_keyCrossfadeDuration) ?? 0;
  }

  Future<void> saveCrossfadeDuration(double seconds) async {
    final prefs = await _preferences;
    await prefs.setDouble(_keyCrossfadeDuration, seconds);
  }

  Future<double> loadPlaybackSpeed() async {
    final prefs = await _preferences;
    return prefs.getDouble(_keyPlaybackSpeed) ?? 1.0;
  }

  Future<void> savePlaybackSpeed(double speed) async {
    final prefs = await _preferences;
    await prefs.setDouble(_keyPlaybackSpeed, speed);
  }
}
