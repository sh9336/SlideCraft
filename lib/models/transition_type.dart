enum TransitionType {
  fade,
  slideleft,
  slideright,
  circleopen,
  circleclose,
  dissolve,
  wipeleft,
  wipedown,
  smoothleft,
  pixelize,
}

extension TransitionTypeExtension on TransitionType {
  String get displayName {
    switch (this) {
      case TransitionType.fade:
        return 'Fade';
      case TransitionType.slideleft:
        return 'Slide Left';
      case TransitionType.slideright:
        return 'Slide Right';
      case TransitionType.circleopen:
        return 'Circle Open';
      case TransitionType.circleclose:
        return 'Circle Close';
      case TransitionType.dissolve:
        return 'Dissolve';
      case TransitionType.wipeleft:
        return 'Wipe Left';
      case TransitionType.wipedown:
        return 'Wipe Down';
      case TransitionType.smoothleft:
        return 'Smooth Left';
      case TransitionType.pixelize:
        return 'Pixelize';
      default:
        return 'Unknown';
    }
  }

  String get ffmpegFilter {
    switch (this) {
      case TransitionType.fade:
        return 'fade';
      case TransitionType.slideleft:
        return 'slideleft';
      case TransitionType.slideright:
        return 'slideright';
      case TransitionType.circleopen:
        return 'circleopen';
      case TransitionType.circleclose:
        return 'circleclose';
      case TransitionType.dissolve:
        return 'dissolve';
      case TransitionType.wipeleft:
        return 'wipeleft';
      case TransitionType.wipedown:
        return 'wipedown';
      case TransitionType.smoothleft:
        return 'smoothleft';
      case TransitionType.pixelize:
        return 'pixelize';
      default:
        return 'fade'; // Default fallback
    }
  }
}