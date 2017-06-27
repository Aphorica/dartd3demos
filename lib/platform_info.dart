import 'dart:html';

class PlatformInfo {
  static PlatformInfo _platformInfo;

  Point _winDimensions;
  String _orientationStr = "none";
  bool _isPortrait = false;
  bool _highResDisplay = false;

  num get width => _winDimensions.x;
  num get height => _winDimensions.y;
  String get orientationStr => _orientationStr;
  bool get isPortrait => _isPortrait;
  bool get isLandscape => !_isPortrait;
  bool get highResDisplay => _highResDisplay;

  factory PlatformInfo() {
    if (_platformInfo == null) {
      _platformInfo = new PlatformInfo._internal();
    }

    return _platformInfo;
  }

  PlatformInfo._internal()
  {
      _winDimensions = new Point(window.innerWidth, window.innerHeight);
      _isPortrait = width < height;
      _orientationStr = isPortrait? 'portrait' : 'landscape';
      _highResDisplay = window.devicePixelRatio > 1;
  }
}
