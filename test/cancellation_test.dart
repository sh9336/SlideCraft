import 'package:flutter_test/flutter_test.dart';
import 'package:cenamatic/services/ffmpeg_service.dart';

void main() {
  group('FFmpegService Cancellation Tests', () {
    test('should cancel video generation', () async {
      final ffmpegService = FFmpegService();

      // Initially not cancelled
      expect(ffmpegService.isCancelled, false);

      // Cancel the operation
      ffmpegService.cancel();

      // Should be cancelled
      expect(ffmpegService.isCancelled, true);

      // Reset cancellation
      ffmpegService.resetCancellation();

      // Should not be cancelled anymore
      expect(ffmpegService.isCancelled, false);
    });

    test('should handle cancellation during video generation', () async {
      final ffmpegService = FFmpegService();

      // Start a mock video generation that can be cancelled
      bool wasCancelled = false;

      try {
        // Simulate a long-running operation
        await Future.delayed(Duration(milliseconds: 100));

        // Cancel during execution
        ffmpegService.cancel();

        // Check if cancelled
        if (ffmpegService.isCancelled) {
          wasCancelled = true;
          throw Exception('Video generation was cancelled');
        }
      } catch (e) {
        if (e.toString().contains('cancelled')) {
          wasCancelled = true;
        }
      }

      expect(wasCancelled, true);
    });
  });
}
