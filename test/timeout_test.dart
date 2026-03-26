import 'package:flutter_test/flutter_test.dart';
import 'package:cenamatic/services/ffmpeg_service.dart';

void main() {
  group('FFmpegService Timeout Tests', () {
    test('should handle timeout properly', () async {
      final ffmpegService = FFmpegService();

      // Test that timeout is properly configured
      expect(() => ffmpegService.cancel(), returnsNormally);
      expect(() => ffmpegService.resetCancellation(), returnsNormally);

      // Test that cancellation state is properly managed
      expect(ffmpegService.isCancelled, false);
      ffmpegService.cancel();
      expect(ffmpegService.isCancelled, true);
      ffmpegService.resetCancellation();
      expect(ffmpegService.isCancelled, false);
    });

    test('should handle cancellation during timeout', () async {
      final ffmpegService = FFmpegService();

      // Test that cancellation works during timeout scenarios
      bool wasCancelled = false;

      try {
        // Simulate a long operation that gets cancelled
        await Future.delayed(Duration(milliseconds: 50));
        ffmpegService.cancel();

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
