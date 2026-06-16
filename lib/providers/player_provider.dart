import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../services/audio_service.dart';
import '../services/storage_service.dart';
import 'progress_provider.dart';

/// Manages audio playback state and exposes it to the widget tree.
class PlayerProvider extends ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();
  final StorageService _storage = StorageService();
  ProgressProvider _progressProvider;

  Song? _currentSong;
  bool _isPlaying = false;

  StreamSubscription<PositionData>? _positionSubscription;
  StreamSubscription<bool>? _playingSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  // ── Getters ───────────────────────────────────────────────────
  AudioPlayerService get audioService => _audioService;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get hasSong => _currentSong != null;
  List<Song> get queue => _audioService.queue;
  int get currentIndex => _audioService.currentIndex;
  bool get shuffleEnabled => _audioService.shuffleEnabled;
  LoopMode get loopMode => _audioService.loopMode;

  PlayerProvider(this._progressProvider) {
    _initStreams();
  }

  set progressProvider(ProgressProvider value) {
    _progressProvider = value;
  }

  void _initStreams() {
    _positionSubscription = _audioService.positionDataStream.listen((data) {
      _progressProvider.update(data.position, data.duration, data.buffered);
    });

    _playingSubscription = _audioService.playingStream.listen((playing) {
      if (_isPlaying == playing) return;
      _isPlaying = playing;
      notifyListeners();
    });

    _playerStateSubscription = _audioService.playerStateStream.listen((_) {
      final nextSong = _audioService.currentSong;
      if (_currentSong?.id == nextSong?.id) return;
      _currentSong = nextSong;
      notifyListeners();
    });
  }

  // ── Playback Controls ────────────────────────────────────────
  Future<void> playSong(Song song, {List<Song>? playlist, int? index}) async {
    _currentSong = song;
    notifyListeners();
    await _audioService.playSong(song, playlist: playlist, index: index);
  }

  Future<void> play() async => await _audioService.play();
  Future<void> pause() async => await _audioService.pause();

  Future<void> togglePlayPause() async {
    await _audioService.togglePlayPause();
  }

  Future<void> stop() async {
    await _audioService.stop();
    _currentSong = null;
    _progressProvider.reset();
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> next() async {
    await _audioService.next();
    _currentSong = _audioService.currentSong;
    notifyListeners();
  }

  Future<void> previous() async {
    await _audioService.previous();
    _currentSong = _audioService.currentSong;
    notifyListeners();
  }

  double get speed => _audioService.speed;
  double get playbackSpeed => speed;

  Future<void> setSpeed(double speed) async {
    await _audioService.setSpeed(speed);
    await _storage.savePlaybackSpeed(speed);
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double speed) => setSpeed(speed);

  void addNext(Song song) {
    _audioService.addNext(song);
    notifyListeners();
  }

  void addToQueue(Song song) {
    _audioService.addToQueue(song);
    notifyListeners();
  }

  void removeFromQueue(int index) {
    _audioService.removeFromQueue(index);
    _currentSong = _audioService.currentSong;
    notifyListeners();
  }

  void reorderQueue(int oldIndex, int newIndex) {
    _audioService.reorderQueue(oldIndex, newIndex);
    _currentSong = _audioService.currentSong;
    notifyListeners();
  }

  void clearQueue() {
    _audioService.clearQueue();
    _currentSong = null;
    notifyListeners();
  }

  void toggleShuffle() {
    _audioService.toggleShuffle();
    notifyListeners();
  }

  void cycleLoopMode() {
    _audioService.cycleLoopMode();
    notifyListeners();
  }


  @override
  void dispose() {
    _positionSubscription?.cancel();
    _playingSubscription?.cancel();
    _playerStateSubscription?.cancel();
    unawaited(_audioService.dispose());
    super.dispose();
  }
}
