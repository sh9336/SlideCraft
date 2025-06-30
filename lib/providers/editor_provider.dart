import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/image_item.dart';
import '../models/transition_type.dart';
import '../models/video_quality.dart';
import '../services/ffmpeg_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class EditorProvider with ChangeNotifier {
  final List<ImageItem> _images = [];
  // Update to use one of the new transition types
  TransitionType _transitionType = TransitionType.fade;
  double _transitionDuration = 1.0; // in seconds
  double _imageDuration = 3.0; // in seconds
  VideoQuality _videoQuality = VideoQuality.high;
  String? _generatedVideoPath;
  bool _isGenerating = false;
  double _generationProgress = 0.0;

  // Getters
  List<ImageItem> get images => _images;
  TransitionType get transitionType => _transitionType;
  double get transitionDuration => _transitionDuration;
  double get imageDuration => _imageDuration;
  VideoQuality get videoQuality => _videoQuality;
  String? get generatedVideoPath => _generatedVideoPath;
  bool get isGenerating => _isGenerating;
  double get generationProgress => _generationProgress;

  // Methods
  void addImages(List<String> imagePaths) {
    int startIndex = _images.length;

    for (var i = 0; i < imagePaths.length; i++) {
      _images.add(
        ImageItem(
          id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
          path: imagePaths[i],
          duration: _imageDuration,
        ),
      );
    }

    notifyListeners();
  }

  void removeImage(String id) {
    _images.removeWhere((image) => image.id == id);
    notifyListeners();
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final ImageItem item = _images.removeAt(oldIndex);
    _images.insert(newIndex, item);

    notifyListeners();
  }

  void updateImageDuration(String id, double duration) {
    final index = _images.indexWhere((image) => image.id == id);
    if (index != -1) {
      _images[index] = _images[index].copyWith(duration: duration);
      notifyListeners();
    }
  }

  void setTransitionType(TransitionType type) {
    _transitionType = type;
    notifyListeners();
  }

  void setTransitionDuration(double duration) {
    _transitionDuration = duration;
    notifyListeners();
  }

  void setImageDuration(double duration) {
    _imageDuration = duration;

    // Update all images with new default duration
    for (int i = 0; i < _images.length; i++) {
      _images[i] = _images[i].copyWith(duration: duration);
    }

    notifyListeners();
  }

  void setVideoQuality(VideoQuality quality) {
    _videoQuality = quality;
    notifyListeners();
  }

  void updateGenerationProgress(double progress) {
    _generationProgress = progress;
    notifyListeners();
  }

  Future<void> generateVideo() async {
    if (_images.isEmpty) {
      throw Exception('No images added');
    }

    _isGenerating = true;
    _generationProgress = 0.0;
    notifyListeners();

    try {
      final FFmpegService ffmpegService = FFmpegService();

      // Create temporary directory for output
      final Directory tempDir = await getTemporaryDirectory();
      final String outputPath = '${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // Generate video
      await ffmpegService.generateVideo(
        images: _images,
        transitionType: _transitionType,
        transitionDuration: _transitionDuration,
        outputPath: outputPath,
        videoQuality: _videoQuality,
        onProgress: updateGenerationProgress,
      );

      _generatedVideoPath = outputPath;
    } catch (e) {
      print('Error generating video: $e');
      rethrow;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  void clearAll() {
    _images.clear();
    _generatedVideoPath = null;
    _generationProgress = 0.0;
    notifyListeners();
  }
}