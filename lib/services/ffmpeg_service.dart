import 'dart:io';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:ffmpeg_kit_flutter_new/session.dart';
import 'package:path_provider/path_provider.dart';
import '../models/image_item.dart';
import '../models/transition_type.dart';
import '../models/video_quality.dart';

class FFmpegService {
  // Constants for FFmpeg settings
  static const int _frameRate = 30;
  static const int _minFileSize = 1000;
  static const String _presetMedium = 'medium';
  static const String _presetUltrafast = 'ultrafast';

  // Cancellation flag
  bool _isCancelled = false;
  Session? _currentSession;

  // Method to cancel ongoing operations
  void cancel() {
    _isCancelled = true;
    _currentSession?.cancel();
  }

  // Method to reset cancellation flag
  void resetCancellation() {
    _isCancelled = false;
    _currentSession = null;
  }

  // Check if operation was cancelled
  bool get isCancelled => _isCancelled;

  String _getFFmpegBaseParams(VideoQuality quality) {
    final resolution = "${quality.width}:${quality.height}";
    final bitrate = "${(quality.bitrate / 1000000).toStringAsFixed(1)}M";
    return '-pix_fmt yuv420p -r $_frameRate -b:v $bitrate '
        '-profile:v baseline -level 3.0 -tune fastdecode '
        '-vf "scale=$resolution:force_original_aspect_ratio=decrease,'
        'pad=$resolution:(ow-iw)/2:(oh-ih)/2:color=black"';
  }

  Future<String> generateVideo({
    required List<ImageItem> images,
    required TransitionType transitionType,
    required double transitionDuration,
    required String outputPath,
    required VideoQuality videoQuality,
    required Function(double) onProgress,
  }) async {
    if (images.isEmpty) throw Exception('No images provided');

    // Reset cancellation flag at the start
    resetCancellation();

    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String workDir = '${appDocDir.path}/cenamatic_temp';

      // Clean temp folder
      final Directory workDirObj = Directory(workDir);
      if (await workDirObj.exists()) {
        await workDirObj.delete(recursive: true);
      }
      await workDirObj.create(recursive: true);

      // Check for cancellation
      if (_isCancelled) {
        throw Exception('Video generation was cancelled');
      }

      // Validate input images
      for (final img in images) {
        final File file = File(img.path);
        if (!await file.exists()) {
          throw Exception('Image file not found: ${img.path}');
        }
      }

      // Check for cancellation after validation
      if (_isCancelled) {
        throw Exception('Video generation was cancelled');
      }

      // Final output path
      final String finalOutput = outputPath.isNotEmpty
          ? outputPath
          : '${appDocDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4';

      // If there's only one image, generate a simple video
      if (images.length == 1) {
        await _generateSingleImageVideo(
          image: images.first,
          videoQuality: videoQuality,
          outputPath: finalOutput,
          onProgress: onProgress,
        );
      } else {
        // Generate video with transitions
        await _generateVideoWithTransitions(
          images: images,
          transitionType: transitionType,
          transitionDuration: transitionDuration,
          videoQuality: videoQuality,
          outputPath: finalOutput,
          workDir: workDir,
          onProgress: onProgress,
        );
      }

      // Check for cancellation before final validation
      if (_isCancelled) {
        throw Exception('Video generation was cancelled');
      }

      // Check output exists
      final outputFile = File(finalOutput);

      if (await outputFile.exists()) {
        final fileSize = await outputFile.length();
        print("Generated video file size: $fileSize bytes");

        if (fileSize < _minFileSize) {
          throw Exception('Generated video file is too small: $fileSize bytes');
        }
        return finalOutput;
      } else {
        throw Exception('FFmpeg completed but output file was not created.');
      }
    } catch (e) {
      // Check if this is a cancellation exception
      if (e.toString().contains('cancelled')) {
        throw e; // Re-throw cancellation exceptions as-is
      }
      print('FFmpeg exception: $e');
      throw Exception('Failed to generate video: $e');
    }
  }

  Future<void> _generateSingleImageVideo({
    required ImageItem image,
    required VideoQuality videoQuality,
    required String outputPath,
    required Function(double) onProgress,
  }) async {
    final command = '-loop 1 -i "${image.path}" -f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 '
        '-t ${image.duration} '
        '-c:v libx264 -preset $_presetMedium '
        '${_getFFmpegBaseParams(videoQuality)} '
        '-c:a aac -shortest -movflags +faststart -y "$outputPath"';

    onProgress(0.0);

    // Check for cancellation before starting
    if (_isCancelled) {
      throw Exception('Video generation was cancelled');
    }

    _currentSession = await FFmpegKit.execute(command);

    // Add a timeout to prevent hanging
    final returnCode = await _currentSession!.getReturnCode().timeout(
      Duration(seconds: 30),
      onTimeout: () {
        _currentSession?.cancel();
        throw Exception('FFmpeg operation timed out');
      },
    );

    // Check for cancellation after completion
    if (_isCancelled) {
      throw Exception('Video generation was cancelled');
    }

    if (ReturnCode.isSuccess(returnCode)) {
      onProgress(1.0);
    } else {
      final logs = await _currentSession!.getAllLogsAsString();
      throw Exception('FFmpeg failed: $logs');
    }
  }

  Future<void> _generateVideoWithTransitions({
    required List<ImageItem> images,
    required TransitionType transitionType,
    required double transitionDuration,
    required VideoQuality videoQuality,
    required String outputPath,
    required String workDir,
    required Function(double) onProgress,
  }) async {
    try {
      onProgress(0.0);

      // Check for cancellation at the start
      if (_isCancelled) {
        throw Exception('Video generation was cancelled');
      }

      // Calculate the total expected duration
      // Formula: sum of all image durations + (number of transitions * transition duration) - (number of transitions * transition duration)
      // Simplified: sum of all image durations + (transitions * (transition_duration - overlap_duration))
      // For your case: 3 + 3 + 3 + (2 * 1) - (2 * 1) = 9 - 2 = 7 (current result)
      // To get 9 seconds, we need to extend each image duration by the transition duration

      final List<String> clipPaths = [];

      // Step 1: Create extended image clips
      for (int i = 0; i < images.length; i++) {
        // Check for cancellation before each clip generation
        if (_isCancelled) {
          throw Exception('Video generation was cancelled');
        }

        final image = images[i];
        final clipPath = '$workDir/image_$i.ts';
        clipPaths.add(clipPath);

        // Progress tracking for image preparation
        onProgress(i / (images.length * 2));

        // Extend duration for middle images to account for transitions
        double extendedDuration = image.duration;
        if (i > 0 && i < images.length - 1) {
          // Middle images: extend by full transition duration on both sides
          extendedDuration += (2 * transitionDuration);
        } else if (i == 0) {
          // First and last images: extend by transition duration on one side
          extendedDuration += transitionDuration;
        }

        // Create a video clip from the image with extended duration
        final command = '-loop 1 -i "${image.path}" -t $extendedDuration '
            '-c:v libx264 -preset $_presetUltrafast '
            '${_getFFmpegBaseParams(videoQuality)} '
            '-f mpegts -y "$clipPath"';

        _currentSession = await FFmpegKit.execute(command);

        // Add a timeout to prevent hanging
        final returnCode = await _currentSession!.getReturnCode().timeout(
          Duration(seconds: 30),
          onTimeout: () {
            _currentSession?.cancel();
            throw Exception('FFmpeg operation timed out');
          },
        );

        // Check for cancellation after each clip
        if (_isCancelled) {
          throw Exception('Video generation was cancelled');
        }

        if (!ReturnCode.isSuccess(returnCode)) {
          final logs = await _currentSession!.getAllLogsAsString();
          throw Exception('Failed to generate clip $i: $logs');
        }
      }

      // Step 2: Create xfade transitions with correct timing
      StringBuffer filterComplex = StringBuffer();
      StringBuffer inputs = StringBuffer();

      // Add input files
      for (int i = 0; i < clipPaths.length; i++) {
        inputs.write('-i "${clipPaths[i]}" ');
      }

      // Calculate offsets for seamless transitions
      // Each transition should start when we want it to begin
      double currentTime = 0.0;

      for (int i = 0; i < clipPaths.length - 1; i++) {
        // Offset is when the transition should start in the output timeline
        double offset = currentTime + images[i].duration;

        if (i == 0) {
          filterComplex.write(
              '[0][1]xfade=transition=${transitionType.ffmpegFilter}:duration=$transitionDuration:offset=$offset[v$i];');
        } else {
          filterComplex.write(
              '[v${i - 1}][${i + 1}]xfade=transition=${transitionType.ffmpegFilter}:duration=$transitionDuration:offset=$offset[v$i];');
        }

        // Move to next position: current image duration + transition duration
        currentTime += images[i].duration + transitionDuration;
      }

      // Remove trailing semicolon
      String filterComplexStr = filterComplex.toString();
      if (filterComplexStr.endsWith(';')) {
        filterComplexStr =
            filterComplexStr.substring(0, filterComplexStr.length - 1);
      }

      final bitrate = "${(videoQuality.bitrate / 1000000).toStringAsFixed(1)}M";

      final finalCommand = inputs.toString() +
          '-f lavfi -i anullsrc=channel_layout=stereo:sample_rate=44100 ' +
          '-filter_complex "$filterComplexStr" ' +
          '-map "[v${clipPaths.length - 2}]" -map ${clipPaths.length}:a ' +
          '-c:v libx264 -preset medium ' +
          '-pix_fmt yuv420p -r 30 -b:v $bitrate ' +
          '-c:a aac -shortest -movflags +faststart -y "$outputPath"';

      print("Executing final FFmpeg command: $finalCommand");
      print(
          "Expected total duration: ${images.fold(0.0, (sum, img) => sum + img.duration) + ((images.length - 1) * transitionDuration)} seconds");

      onProgress(0.5);

      // Check for cancellation before final step
      if (_isCancelled) {
        throw Exception('Video generation was cancelled');
      }

      _currentSession = await FFmpegKit.execute(finalCommand);

      // Add a timeout to prevent hanging
      final finalReturnCode = await _currentSession!.getReturnCode().timeout(
        Duration(seconds: 60), // Longer timeout for final step
        onTimeout: () {
          _currentSession?.cancel();
          throw Exception('FFmpeg operation timed out');
        },
      );

      // Check for cancellation after final step
      if (_isCancelled) {
        throw Exception('Video generation was cancelled');
      }

      if (ReturnCode.isSuccess(finalReturnCode)) {
        onProgress(1.0);
      } else {
        final logs = await _currentSession!.getAllLogsAsString();
        throw Exception('FFmpeg failed in final transition step: $logs');
      }
    } catch (e) {
      // Check if this is a cancellation exception
      if (e.toString().contains('cancelled')) {
        throw e; // Re-throw cancellation exceptions as-is
      }
      throw Exception('Error in transition video generation: $e');
    }
  }
}
