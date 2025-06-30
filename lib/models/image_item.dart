class ImageItem {
  final String id;
  final String path;
  final double duration;

  ImageItem({
    required this.id,
    required this.path,
    required this.duration,
  });

  ImageItem copyWith({
    String? id,
    String? path,
    double? duration,
  }) {
    return ImageItem(
      id: id ?? this.id,
      path: path ?? this.path,
      duration: duration ?? this.duration,
    );
  }

  @override
  String toString() => 'ImageItem(id: $id, path: $path, duration: $duration)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}