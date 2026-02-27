import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import '../models/song_model.dart';

/// Manages audio playback using just_audio.
class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  // ── Queue Management ─────────────────────────────────────────
  List<Song> _queue = [];
  int _currentIndex = -1;
  bool _shuffleEnabled = false;
  LoopMode _loopMode = LoopMode.off;
  List<int> _shuffledIndices = [];

  // ── Getters ───────────────────────────────────────────────────
  AudioPlayer get player => _player;
  List<Song> get queue => List.unmodifiable(_queue);
  int get currentIndex => _currentIndex;
  Song? get currentSong =>
      _currentIndex >= 0 && _currentIndex < _queue.length
          ? _queue[_currentIndex]
          : null;
  bool get shuffleEnabled => _shuffleEnabled;
  LoopMode get loopMode => _loopMode;
  bool get isPlaying => _player.playing;
  bool get hasNext => _currentIndex < _queue.length - 1;
  bool get hasPrevious => _currentIndex > 0;

  // ── Streams ───────────────────────────────────────────────────
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<bool> get playingStream => _player.playingStream;

  /// Combined stream of position, duration, and buffered position.
  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration?, Duration, PositionData>(
        _player.positionStream,
        _player.durationStream,
        _player.bufferedPositionStream,
        (position, duration, buffered) => PositionData(
          position: position,
          duration: duration ?? Duration.zero,
          buffered: buffered,
        ),
      );

  AudioPlayerService() {
    // Listen for track completion
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onTrackComplete();
      }
    });
  }

  // ── Playback Controls ────────────────────────────────────────
  Future<void> playSong(Song song, {List<Song>? playlist, int? index}) async {
    if (playlist != null) {
      _queue = List.from(playlist);
      _currentIndex = index ?? playlist.indexOf(song);
      if (_shuffleEnabled) {
        _generateShuffleOrder();
      }
    } else if (!_queue.contains(song)) {
      _queue = [song];
      _currentIndex = 0;
    } else {
      _currentIndex = _queue.indexOf(song);
    }

    await _loadAndPlay(song);
  }

  Future<void> _loadAndPlay(Song song) async {
    try {
      if (song.uri != null) {
        await _player.setAudioSource(AudioSource.uri(Uri.parse(song.uri!)));
        await _player.play();
      }
    } catch (e) {
      // Handle errors gracefully
      print('Error playing song: $e');
    }
  }

  Future<void> play() async => await _player.play();

  Future<void> pause() async => await _player.pause();

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> next() async {
    if (_queue.isEmpty) return;

    int nextIndex;
    if (_shuffleEnabled && _shuffledIndices.isNotEmpty) {
      final currentShufflePos = _shuffledIndices.indexOf(_currentIndex);
      if (currentShufflePos < _shuffledIndices.length - 1) {
        nextIndex = _shuffledIndices[currentShufflePos + 1];
      } else if (_loopMode == LoopMode.all) {
        nextIndex = _shuffledIndices.first;
      } else {
        return;
      }
    } else {
      if (_currentIndex < _queue.length - 1) {
        nextIndex = _currentIndex + 1;
      } else if (_loopMode == LoopMode.all) {
        nextIndex = 0;
      } else {
        return;
      }
    }

    _currentIndex = nextIndex;
    await _loadAndPlay(_queue[_currentIndex]);
  }

  Future<void> previous() async {
    if (_queue.isEmpty) return;

    // If more than 3 seconds in, restart track
    if (_player.position.inSeconds > 3) {
      await seek(Duration.zero);
      return;
    }

    int prevIndex;
    if (_shuffleEnabled && _shuffledIndices.isNotEmpty) {
      final currentShufflePos = _shuffledIndices.indexOf(_currentIndex);
      if (currentShufflePos > 0) {
        prevIndex = _shuffledIndices[currentShufflePos - 1];
      } else if (_loopMode == LoopMode.all) {
        prevIndex = _shuffledIndices.last;
      } else {
        await seek(Duration.zero);
        return;
      }
    } else {
      if (_currentIndex > 0) {
        prevIndex = _currentIndex - 1;
      } else if (_loopMode == LoopMode.all) {
        prevIndex = _queue.length - 1;
      } else {
        await seek(Duration.zero);
        return;
      }
    }

    _currentIndex = prevIndex;
    await _loadAndPlay(_queue[_currentIndex]);
  }

  // ── Shuffle & Repeat ─────────────────────────────────────────
  void toggleShuffle() {
    _shuffleEnabled = !_shuffleEnabled;
    if (_shuffleEnabled) {
      _generateShuffleOrder();
    }
  }

  void cycleLoopMode() {
    switch (_loopMode) {
      case LoopMode.off:
        _loopMode = LoopMode.all;
        break;
      case LoopMode.all:
        _loopMode = LoopMode.one;
        _player.setLoopMode(LoopMode.one);
        break;
      case LoopMode.one:
        _loopMode = LoopMode.off;
        _player.setLoopMode(LoopMode.off);
        break;
    }
  }

  void _generateShuffleOrder() {
    _shuffledIndices = List.generate(_queue.length, (i) => i)..shuffle();
    // Ensure current song is first in shuffle
    if (_currentIndex >= 0) {
      _shuffledIndices.remove(_currentIndex);
      _shuffledIndices.insert(0, _currentIndex);
    }
  }

  void _onTrackComplete() {
    if (_loopMode == LoopMode.one) {
      _loadAndPlay(_queue[_currentIndex]);
    } else {
      next();
    }
  }

  // ── Cleanup ───────────────────────────────────────────────────
  Future<void> dispose() async {
    await _player.dispose();
  }
}

/// Bundles position data from multiple streams.
class PositionData {
  final Duration position;
  final Duration duration;
  final Duration buffered;

  PositionData({
    required this.position,
    required this.duration,
    required this.buffered,
  });
}
