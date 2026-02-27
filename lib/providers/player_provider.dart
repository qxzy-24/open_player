import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/song_model.dart';
import '../services/audio_service.dart';

/// Manages audio playback state and exposes it to the widget tree.
class PlayerProvider extends ChangeNotifier {
  final AudioPlayerService _audioService = AudioPlayerService();

  Song? _currentSong;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _buffered = Duration.zero;

  // ── Getters ───────────────────────────────────────────────────
  AudioPlayerService get audioService => _audioService;
  Song? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  Duration get buffered => _buffered;
  bool get hasSong => _currentSong != null;
  List<Song> get queue => _audioService.queue;
  int get currentIndex => _audioService.currentIndex;
  bool get shuffleEnabled => _audioService.shuffleEnabled;
  LoopMode get loopMode => _audioService.loopMode;

  PlayerProvider() {
    _initStreams();
  }

  void _initStreams() {
    // Listen to position data
    _audioService.positionDataStream.listen((data) {
      _position = data.position;
      _duration = data.duration;
      _buffered = data.buffered;
      notifyListeners();
    });

    // Listen to playing state
    _audioService.playingStream.listen((playing) {
      _isPlaying = playing;
      notifyListeners();
    });

    // Listen to player state for track changes
    _audioService.playerStateStream.listen((state) {
      _currentSong = _audioService.currentSong;
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
    _audioService.dispose();
    super.dispose();
  }
}
