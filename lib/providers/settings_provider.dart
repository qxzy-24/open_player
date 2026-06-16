import 'dart:async';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Manages app-wide settings state.
class SettingsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  bool _gaplessPlayback = true;
  double _crossfadeDuration = 0;
  double _playbackSpeed = 1.0;
  int _sleepTimerMinutes = 0;
  Timer? _sleepTimer;
  int _sleepTimerRemaining = 0; // seconds remaining

  // ── Getters ───────────────────────────────────────────────
  bool get gaplessPlayback => _gaplessPlayback;
  double get crossfadeDuration => _crossfadeDuration;
  double get playbackSpeed => _playbackSpeed;
  int get sleepTimerMinutes => _sleepTimerMinutes;
  int get sleepTimerRemaining => _sleepTimerRemaining;
  bool get isSleepTimerActive => _sleepTimer != null && _sleepTimerRemaining > 0;

  String get sleepTimerDisplay {
    if (!isSleepTimerActive) return '';
    final m = _sleepTimerRemaining ~/ 60;
    final s = _sleepTimerRemaining % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  /// Initialize from persisted values.
  Future<void> initialize() async {
    _gaplessPlayback = await _storage.loadGapless();
    _crossfadeDuration = await _storage.loadCrossfadeDuration();
    _playbackSpeed = await _storage.loadPlaybackSpeed();
    notifyListeners();
  }

  void setGaplessPlayback(bool value) {
    _gaplessPlayback = value;
    _storage.saveGapless(value);
    notifyListeners();
  }

  void setCrossfadeDuration(double seconds) {
    _crossfadeDuration = seconds;
    _storage.saveCrossfadeDuration(seconds);
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    _storage.savePlaybackSpeed(speed);
    notifyListeners();
  }

  /// Start sleep timer. [onTimerComplete] is called when timer expires.
  void startSleepTimer(int minutes, {VoidCallback? onTimerComplete}) {
    cancelSleepTimer();
    _sleepTimerMinutes = minutes;
    _sleepTimerRemaining = minutes * 60;
    notifyListeners();

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _sleepTimerRemaining--;
      if (_sleepTimerRemaining <= 0) {
        cancelSleepTimer();
        onTimerComplete?.call();
      }
      notifyListeners();
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerMinutes = 0;
    _sleepTimerRemaining = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    super.dispose();
  }
}
