import 'package:flutter/material.dart';

/// Holds high-frequency playback progress values.
class ProgressProvider extends ChangeNotifier {
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _buffered = Duration.zero;

  Duration get position => _position;
  Duration get duration => _duration;
  Duration get buffered => _buffered;

  void update(Duration position, Duration duration, Duration buffered) {
    if (_position == position &&
        _duration == duration &&
        _buffered == buffered) {
      return;
    }

    _position = position;
    _duration = duration;
    _buffered = buffered;
    notifyListeners();
  }

  void reset() {
    update(Duration.zero, Duration.zero, Duration.zero);
  }
}
