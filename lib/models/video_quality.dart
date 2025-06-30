enum VideoQuality {
  low,
  medium,
  high,
}

extension VideoQualityExtension on VideoQuality {
  String get displayName {
    switch (this) {
      case VideoQuality.low:
        return 'Low (480p)';
      case VideoQuality.medium:
        return 'Medium (720p)';
      case VideoQuality.high:
        return 'High (1080p)';
      default:
        return 'Unknown';
    }
  }

  int get width {
    switch (this) {
      case VideoQuality.low:
        return 854;
      case VideoQuality.medium:
        return 1280;
      case VideoQuality.high:
        return 1920;
      default:
        return 1280;
    }
  }

  int get height {
    switch (this) {
      case VideoQuality.low:
        return 480;
      case VideoQuality.medium:
        return 720;
      case VideoQuality.high:
        return 1080;
      default:
        return 720;
    }
  }

  int get bitrate {
    switch (this) {
      case VideoQuality.low:
        return 1000000; // 1 Mbps
      case VideoQuality.medium:
        return 2500000; // 2.5 Mbps
      case VideoQuality.high:
        return 5000000; // 5 Mbps
      default:
        return 2500000;
    }
  }
}