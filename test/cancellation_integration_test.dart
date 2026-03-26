import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:cenamatic/providers/editor_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EditorProvider Cancellation Integration Tests', () {
    test('should handle cancellation state properly', () async {
      final provider = EditorProvider();

      // Initially not generating
      expect(provider.isGenerating, false);
      expect(provider.generationProgress, 0.0);
      expect(provider.generatedVideoPath, null);

      // Test cancellation when not generating (should not cause issues)
      provider.cancelVideoGeneration();
      expect(provider.isGenerating, false);
      expect(provider.generationProgress, 0.0);
      expect(provider.generatedVideoPath, null);
    });

    test('should clear all properly', () async {
      final provider = EditorProvider();

      // Initially empty
      expect(provider.images.isEmpty, true);
      expect(provider.isGenerating, false);
      expect(provider.generationProgress, 0.0);
      expect(provider.generatedVideoPath, null);

      // Clear all (should not cause issues even when nothing to clear)
      provider.clearAll();
      expect(provider.images.isEmpty, true);
      expect(provider.isGenerating, false);
      expect(provider.generationProgress, 0.0);
      expect(provider.generatedVideoPath, null);
    });

    test('should handle cancellation method calls', () async {
      final provider = EditorProvider();

      // Test that cancellation methods exist and can be called
      expect(() => provider.cancelVideoGeneration(), returnsNormally);
      expect(() => provider.clearAll(), returnsNormally);

      // Verify state after cancellation
      expect(provider.isGenerating, false);
      expect(provider.generationProgress, 0.0);
      expect(provider.generatedVideoPath, null);
    });
  });
}
