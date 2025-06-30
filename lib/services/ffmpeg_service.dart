// import 'dart:io';
// import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
// import 'package:path_provider/path_provider.dart';
// import '../models/image_item.dart';
// import '../models/transition_type.dart';
// import '../models/video_quality.dart';
//
// class FFmpegService {
//   Future<String> generateVideo({
//     required List<ImageItem> images,
//     required TransitionType transitionType,
//     required double transitionDuration,
//     required String outputPath,
//     required VideoQuality videoQuality,
//     required Function(double) onProgress,
//   }) async {
//     if (images.isEmpty) throw Exception('No images provided');
//
//     try {
//       final Directory appDocDir = await getApplicationDocumentsDirectory();
//       final String workDir = '${appDocDir.path}/cenamatic_temp';
//
//       // Clean temp folder
//       final Directory workDirObj = Directory(workDir);
//       if (await workDirObj.exists()) {
//         await workDirObj.delete(recursive: true);
//       }
//       await workDirObj.create(recursive: true);
//
//       // Validate input images
//       for (final img in images) {
//         final File file = File(img.path);
//         if (!await file.exists()) {
//           throw Exception('Image file not found: ${img.path}');
//         }
//       }
//
//       // Final output path
//       final String finalOutput = outputPath.isNotEmpty
//           ? outputPath
//           : '${appDocDir.path}/output_${DateTime.now().millisecondsSinceEpoch}.mp4';
//
//       // Using a multi-step approach to ensure accurate timing
//       if (images.length > 1) {
//         // When we have multiple images, use a two-step process for better transitions
//         await _generateVideoWithTwoStepApproach(
//           images: images,
//           transitionType: transitionType,
//           transitionDuration: transitionDuration,
//           videoQuality: videoQuality,
//           outputPath: finalOutput,
//           workDir: workDir,
//           onProgress: onProgress,
//         );
//       } else {
//
//         // For a single image, use a simpler approach
//         await _generateSingleImageVideo(
//           image: images.first,
//           videoQuality: videoQuality,
//           outputPath: finalOutput,
//           onProgress: onProgress,
//         );
//
//       }
//
//       // Check output exists
//       final outputFile = File(finalOutput);
//
//       if (await outputFile.exists()) {
//         final fileSize = await outputFile.length();
//         print("Generated video file size: $fileSize bytes");
//
//         if (fileSize < 1000) {
//           throw Exception('Generated video file is too small: $fileSize bytes');
//         }
//         return finalOutput;
//       } else {
//         throw Exception('FFmpeg completed but output file was not created.');
//       }
//     } catch (e) {
//       print('FFmpeg exception: $e');
//       throw Exception('Failed to generate video: $e');
//     }
//   }
//
//   Future<void> _generateSingleImageVideo({
//     required ImageItem image,
//     required VideoQuality videoQuality,
//     required String outputPath,
//     required Function(double) onProgress,
//   }) async {
//
//     final resolution = "${videoQuality.width}:${videoQuality.height}";
//     final bitrate = "${(videoQuality.bitrate / 1000000).toStringAsFixed(1)}M";
//
//     final command = '-loop 1 -i "${image.path}" -t ${image.duration} '
//         '-c:v libx264 -preset medium -tune stillimage '
//         '-profile:v high -level 4.0 '
//         '-pix_fmt yuv420p -r 30 -b:v $bitrate '
//         '-vf "scale=$resolution:force_original_aspect_ratio=decrease,'
//         'pad=$resolution:(ow-iw)/2:(oh-ih)/2:color=black" '
//         '-movflags +faststart -y "$outputPath"';
//
//     onProgress(0.0);
//     final session = await FFmpegKit.execute(command);
//     final returnCode = await session.getReturnCode();
//
//     if (ReturnCode.isSuccess(returnCode)) {
//       onProgress(1.0);
//     } else {
//       final logs = await session.getAllLogsAsString();
//       throw Exception('FFmpeg failed: $logs');
//     }
//   }
//
//   Future<void> _generateVideoWithTwoStepApproach({
//     required List<ImageItem> images,
//     required TransitionType transitionType,
//     required double transitionDuration,
//     required VideoQuality videoQuality,
//     required String outputPath,
//     required String workDir,
//     required Function(double) onProgress,
//   }) async {
//     try {
//       onProgress(0.0);
//
//       // Step 1: Generate individual clips for each image
//       final List<String> clipPaths = await _generateImageClips(
//         images: images,
//         workDir: workDir,
//         videoQuality: videoQuality,
//         onProgress: onProgress,
//       );
//
//       // Step 2: Create a clip list file for precise timing
//       final String clipListPath = '$workDir/clip_list.txt';
//       final File clipListFile = File(clipListPath);
//       final StringBuffer clipListContent = StringBuffer();
//
//       for (int i = 0; i < clipPaths.length; i++) {
//         // Escape single quotes in paths
//         final safeClipPath = clipPaths[i].replaceAll("'", "\\'");
//         clipListContent.writeln("file '$safeClipPath'");
//
//         // For accurate timing, we don't add duration in the file -
//         // each clip already has the exact duration
//       }
//
//       await clipListFile.writeAsString(clipListContent.toString());
//       print("Created clip list file: ${await clipListFile.readAsString()}");
//
//       // Step 3: Concatenate clips with transitions
//       final resolution = "${videoQuality.width}:${videoQuality.height}";
//       final bitrate = "${(videoQuality.bitrate / 1000000).toStringAsFixed(1)}M";
//
//       // Build the final command with concat demuxer
//       String finalCommand = '-f concat -safe 0 -i "$clipListPath" '
//           '-c:v libx264 -preset medium '
//           '-profile:v high -level 4.0 '
//           '-pix_fmt yuv420p -r 30 -b:v $bitrate '
//           '-movflags +faststart -y "$outputPath"';
//
//       print("Executing final FFmpeg command: $finalCommand");
//
//       final session = await FFmpegKit.execute(finalCommand);
//       final returnCode = await session.getReturnCode();
//       final logs = await session.getAllLogsAsString();
//       print("FFmpeg final logs: $logs");
//
//       if (ReturnCode.isSuccess(returnCode)) {
//         onProgress(1.0);
//       } else {
//         throw Exception('FFmpeg failed in final step: $logs');
//       }
//     } catch (e) {
//       throw Exception('Error in two-step video generation: $e');
//     }
//   }
//
//   Future<List<String>> _generateImageClips({
//     required List<ImageItem> images,
//     required String workDir,
//     required VideoQuality videoQuality,
//     required Function(double) onProgress,
//   }) async {
//     List<String> clipPaths = [];
//
//     // Calculate total steps for progress tracking
//     final int totalImages = images.length;
//
//     for (int i = 0; i < images.length; i++) {
//       final ImageItem image = images[i];
//       final String clipPath = '$workDir/clip_$i.mp4';
//
//       // Calculate progress percentage
//       final double progressStart = i / totalImages * 0.8; // First 80% for clips
//       final double progressEnd = (i + 1) / totalImages * 0.8;
//
//       onProgress(progressStart);
//
//       // Build command to create a video clip from a single image with exact duration
//       final String resolution = "${videoQuality.width}:${videoQuality.height}";
//       final String bitrate = "${(videoQuality.bitrate / 1000000).toStringAsFixed(1)}M";
//
//       final String command = '-loop 1 -i "${image.path}" -t ${image.duration} '
//           '-c:v libx264 -preset ultrafast ' // Use ultrafast for individual clips
//           '-pix_fmt yuv420p -r 30 -b:v $bitrate '
//           '-vf "scale=$resolution:force_original_aspect_ratio=decrease,'
//           'pad=$resolution:(ow-iw)/2:(oh-ih)/2:color=black" '
//           '-movflags +faststart -y "$clipPath"';
//
//       print("Generating clip $i with command: $command");
//
//       // Execute command
//       final session = await FFmpegKit.execute(command);
//       final returnCode = await session.getReturnCode();
//
//       if (ReturnCode.isSuccess(returnCode)) {
//         clipPaths.add(clipPath);
//         onProgress(progressEnd);
//       } else {
//         final logs = await session.getAllLogsAsString();
//         throw Exception('Failed to generate clip $i: $logs');
//       }
//     }
//
//     return clipPaths;
//   }
// }





import 'dart:io';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:path_provider/path_provider.dart';
import '../models/image_item.dart';
import '../models/transition_type.dart';
import '../models/video_quality.dart';

class FFmpegService {
  Future<String> generateVideo({
    required List<ImageItem> images,
    required TransitionType transitionType,
    required double transitionDuration,
    required String outputPath,
    required VideoQuality videoQuality,
    required Function(double) onProgress,
  }) async {
    if (images.isEmpty) throw Exception('No images provided');

    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String workDir = '${appDocDir.path}/cenamatic_temp';

      // Clean temp folder
      final Directory workDirObj = Directory(workDir);
      if (await workDirObj.exists()) {
        await workDirObj.delete(recursive: true);
      }
      await workDirObj.create(recursive: true);

      // Validate input images
      for (final img in images) {
        final File file = File(img.path);
        if (!await file.exists()) {
          throw Exception('Image file not found: ${img.path}');
        }
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

      // Check output exists
      final outputFile = File(finalOutput);

      if (await outputFile.exists()) {
        final fileSize = await outputFile.length();
        print("Generated video file size: $fileSize bytes");

        if (fileSize < 1000) {
          throw Exception('Generated video file is too small: $fileSize bytes');
        }
        return finalOutput;
      } else {
        throw Exception('FFmpeg completed but output file was not created.');
      }
    } catch (e) {
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
    final resolution = "${videoQuality.width}:${videoQuality.height}";
    final bitrate = "${(videoQuality.bitrate / 1000000).toStringAsFixed(1)}M";

    final command = '-loop 1 -i "${image.path}" -t ${image.duration} '
        '-c:v libx264 -preset medium -tune stillimage '
        '-profile:v high -level 4.0 '
        '-pix_fmt yuv420p -r 30 -b:v $bitrate '
        '-vf "scale=$resolution:force_original_aspect_ratio=decrease,'
        'pad=$resolution:(ow-iw)/2:(oh-ih)/2:color=black" '
        '-movflags +faststart -y "$outputPath"';

    onProgress(0.0);
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      onProgress(1.0);
    } else {
      final logs = await session.getAllLogsAsString();
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

      // First step: Create individual image clips
      final List<String> clipPaths = [];

      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        final clipPath = '$workDir/image_$i.ts';
        clipPaths.add(clipPath);

        // Progress tracking for image preparation
        onProgress(i / (images.length * 2));

        // Create a video clip from the image
        final resolution = "${videoQuality.width}:${videoQuality.height}";
        final bitrate = "${(videoQuality.bitrate / 1000000).toStringAsFixed(1)}M";

        final command = '-loop 1 -i "${image.path}" -t ${image.duration} '
            '-c:v libx264 -preset ultrafast '
            '-pix_fmt yuv420p -r 30 -b:v $bitrate '
            '-vf "scale=$resolution:force_original_aspect_ratio=decrease,'
            'pad=$resolution:(ow-iw)/2:(oh-ih)/2:color=black" '
            '-f mpegts -y "$clipPath"';

        final session = await FFmpegKit.execute(command);
        final returnCode = await session.getReturnCode();

        if (!ReturnCode.isSuccess(returnCode)) {
          final logs = await session.getAllLogsAsString();
          throw Exception('Failed to generate clip $i: $logs');
        }
      }

      // Step 2: Create a complex filtergraph for xfade transitions
      StringBuffer filterComplex = StringBuffer();
      StringBuffer inputs = StringBuffer();

      // Add input files
      for (int i = 0; i < clipPaths.length; i++) {
        inputs.write('-i "${clipPaths[i]}" ');
      }

      double currentOffset = images[0].duration;
      for (int i = 0; i < clipPaths.length - 1; i++) {
        final offset = currentOffset - transitionDuration;
        if (i == 0) {
          filterComplex.write('[0][1]xfade=transition=${transitionType.ffmpegFilter}:duration=$transitionDuration:offset=$offset[v$i];');
        } else {
          filterComplex.write('[v${i-1}][${i+1}]xfade=transition=${transitionType.ffmpegFilter}:duration=$transitionDuration:offset=$offset[v$i];');
        }
        // Correct: adjust offset for next
        currentOffset += images[i + 1].duration - transitionDuration;
      }

      // Remove trailing semicolon and add output label
      String filterComplexStr = filterComplex.toString();
      if (filterComplexStr.endsWith(';')) {
        filterComplexStr = filterComplexStr.substring(0, filterComplexStr.length - 1);
      }

      final bitrate = "${(videoQuality.bitrate / 1000000).toStringAsFixed(1)}M";

      final finalCommand = inputs.toString() +
          '-filter_complex "$filterComplexStr" ' +
          '-map "[v${clipPaths.length - 2}]" ' +
          '-c:v libx264 -preset medium -profile:v high ' +
          '-pix_fmt yuv420p -r 30 -b:v $bitrate ' +
          '-movflags +faststart -y "$outputPath"';

      print("Executing final FFmpeg command: $finalCommand");

      onProgress(0.5); // 50% progress after image preparation

      final finalSession = await FFmpegKit.execute(finalCommand);
      final finalReturnCode = await finalSession.getReturnCode();

      if (ReturnCode.isSuccess(finalReturnCode)) {
        onProgress(1.0);
      } else {
        final logs = await finalSession.getAllLogsAsString();
        throw Exception('FFmpeg failed in final transition step: $logs');
      }
    } catch (e) {
      throw Exception('Error in transition video generation: $e');
    }
  }

}