import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/image_item.dart';
import '../models/transition_type.dart';
import '../models/video_quality.dart';
import '../services/ffmpeg_service.dart';
import 'dart:io';
import 'dart:math';
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
  FFmpegService? _ffmpegService;

  // Getters
  List<ImageItem> get images => _images;
  TransitionType get transitionType => _transitionType;
  double get transitionDuration => _transitionDuration;
  double get imageDuration => _imageDuration;
  VideoQuality get videoQuality => _videoQuality;
  String? get generatedVideoPath => _generatedVideoPath;
  bool get isGenerating => _isGenerating;
  double get generationProgress => _generationProgress;

  // Helper method to generate unique IDs
  String _generateUniqueId() {
    final random = Random();
    return DateTime.now().millisecondsSinceEpoch.toString() +
        random.nextInt(100000).toString().padLeft(5, '0');
  }

  // Methods
  void addImages(List<String> imagePaths) {
    try {
      int startIndex = _images.length;

      for (var i = 0; i < imagePaths.length; i++) {
        // Validate file exists before adding
        final file = File(imagePaths[i]);
        if (!file.existsSync()) {
          print('Warning: Image file not found: ${imagePaths[i]}');
          continue; // Skip invalid files
        }

        _images.add(
          ImageItem(
            id: _generateUniqueId(),
            path: imagePaths[i],
            duration: _imageDuration,
          ),
        );
      }

      notifyListeners();
    } catch (e) {
      print('Error adding images: $e');
      // Re-throw to allow UI to handle the error
      rethrow;
    }
  }

  void removeImage(String id) {
    try {
      _images.removeWhere((image) => image.id == id);
      notifyListeners();
    } catch (e) {
      print('Error removing image: $e');
    }
  }

  void reorderImages(int oldIndex, int newIndex) {
    try {
      // Ensure indices are within bounds
      if (oldIndex < 0 ||
          oldIndex >= _images.length ||
          newIndex < 0 ||
          newIndex >= _images.length) {
        print(
            'Invalid reorder indices: oldIndex=$oldIndex, newIndex=$newIndex, listLength=${_images.length}');
        return;
      }

      // For ReorderableListView, when dragging down, newIndex is the position
      // where the item should be placed. No adjustment needed.
      final ImageItem item = _images.removeAt(oldIndex);
      _images.insert(newIndex, item);

      notifyListeners();
      print('Reordered image from position $oldIndex to $newIndex');
    } catch (e) {
      print('Error reordering images: $e');
    }
  }

  void updateImageDuration(String id, double duration) {
    try {
      final index = _images.indexWhere((image) => image.id == id);
      if (index != -1) {
        _images[index] = _images[index].copyWith(duration: duration);
        notifyListeners();
      }
    } catch (e) {
      print('Error updating image duration: $e');
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

  void cancelVideoGeneration() {
    if (_isGenerating && _ffmpegService != null) {
      print('Cancelling video generation...');
      _ffmpegService!.cancel();
      _isGenerating = false;
      _generationProgress = 0.0;
      _generatedVideoPath = null; // Clear any partial video path
      _ffmpegService = null; // Clear the service reference
      notifyListeners();
      print('Video generation cancelled successfully');
    }
  }

  Future<void> generateVideo() async {
    if (_images.isEmpty) {
      throw Exception('No images added');
    }

    _isGenerating = true;
    _generationProgress = 0.0;
    notifyListeners();

    try {
      _ffmpegService = FFmpegService();

      // Create temporary directory for output
      final Directory tempDir = await getTemporaryDirectory();
      final String outputPath =
          '${tempDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // Generate video
      await _ffmpegService!.generateVideo(
        images: _images,
        transitionType: _transitionType,
        transitionDuration: _transitionDuration,
        outputPath: outputPath,
        videoQuality: _videoQuality,
        onProgress: updateGenerationProgress,
      );

      // Check if generation was cancelled before setting the path
      if (_isGenerating) {
        _generatedVideoPath = outputPath;
      }
    } catch (e) {
      print('Error generating video: $e');
      // Check if the error is due to cancellation
      if (e.toString().contains('cancelled')) {
        print('Video generation was cancelled by user');
        // Don't set generatedVideoPath for cancelled operations
        return; // Don't rethrow cancellation errors
      }
      rethrow;
    } finally {
      _isGenerating = false;
      _ffmpegService = null;
      notifyListeners();
    }
  }

  void clearAll() {
    // Cancel any ongoing video generation
    if (_isGenerating && _ffmpegService != null) {
      _ffmpegService!.cancel();
    }

    _images.clear();
    _generatedVideoPath = null;
    _generationProgress = 0.0;
    _isGenerating = false;
    _ffmpegService = null;
    notifyListeners();
  }
}
