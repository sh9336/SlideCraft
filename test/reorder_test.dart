import 'package:flutter_test/flutter_test.dart';
import 'package:cenamatic/providers/editor_provider.dart';
import 'package:cenamatic/models/image_item.dart';
import 'dart:io';

void main() {
  group('EditorProvider Reorder Tests', () {
    test('should reorder images correctly when moving up', () async {
      final provider = EditorProvider();

      // Create temporary test files
      final tempDir = Directory.systemTemp;
      final file1 = File('${tempDir.path}/image1.jpg');
      final file2 = File('${tempDir.path}/image2.jpg');
      final file3 = File('${tempDir.path}/image3.jpg');

      await file1.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);
      await file2.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);
      await file3.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);

      try {
        // Add test images
        provider.addImages([file1.path, file2.path, file3.path]);

        // Verify initial order
        expect(provider.images.length, 3);
        expect(provider.images[0].path, file1.path);
        expect(provider.images[1].path, file2.path);
        expect(provider.images[2].path, file3.path);

        // Move item from position 2 to position 0 (moving up)
        provider.reorderImages(2, 0);

        // Verify new order
        expect(provider.images[0].path, file3.path);
        expect(provider.images[1].path, file1.path);
        expect(provider.images[2].path, file2.path);
      } finally {
        // Clean up test files
        if (await file1.exists()) await file1.delete();
        if (await file2.exists()) await file2.delete();
        if (await file3.exists()) await file3.delete();
      }
    });

    test('should reorder images correctly when moving down', () async {
      final provider = EditorProvider();

      // Create temporary test files
      final tempDir = Directory.systemTemp;
      final file1 = File('${tempDir.path}/image1.jpg');
      final file2 = File('${tempDir.path}/image2.jpg');
      final file3 = File('${tempDir.path}/image3.jpg');

      await file1.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);
      await file2.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);
      await file3.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);

      try {
        // Add test images
        provider.addImages([file1.path, file2.path, file3.path]);

        // Verify initial order
        expect(provider.images.length, 3);
        expect(provider.images[0].path, file1.path);
        expect(provider.images[1].path, file2.path);
        expect(provider.images[2].path, file3.path);

        // Move item from position 0 to position 2 (moving down)
        provider.reorderImages(0, 2);

        // Verify new order
        expect(provider.images[0].path, file2.path);
        expect(provider.images[1].path, file3.path);
        expect(provider.images[2].path, file1.path);
      } finally {
        // Clean up test files
        if (await file1.exists()) await file1.delete();
        if (await file2.exists()) await file2.delete();
        if (await file3.exists()) await file3.delete();
      }
    });

    test('should handle reorder with adjusted indices correctly', () async {
      final provider = EditorProvider();

      // Create temporary test files
      final tempDir = Directory.systemTemp;
      final file1 = File('${tempDir.path}/image1.jpg');
      final file2 = File('${tempDir.path}/image2.jpg');
      final file3 = File('${tempDir.path}/image3.jpg');
      final file4 = File('${tempDir.path}/image4.jpg');

      await file1.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);
      await file2.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);
      await file3.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);
      await file4.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);

      try {
        // Add test images
        provider.addImages([file1.path, file2.path, file3.path, file4.path]);

        // Simulate ReorderableListView behavior for downward drag
        // When dragging item 0 down to position 2, ReorderableListView calls:
        // onReorder(0, 3) - but we need to adjust it to (0, 2)
        int oldIndex = 0;
        int newIndex = 3;

        // Apply the adjustment that ReorderableListView expects
        if (newIndex > oldIndex) {
          newIndex -= 1;
        }

        provider.reorderImages(oldIndex, newIndex);

        // Verify new order: image1 should be at position 2
        expect(provider.images[0].path, file2.path);
        expect(provider.images[1].path, file3.path);
        expect(provider.images[2].path, file1.path);
        expect(provider.images[3].path, file4.path);
      } finally {
        // Clean up test files
        if (await file1.exists()) await file1.delete();
        if (await file2.exists()) await file2.delete();
        if (await file3.exists()) await file3.delete();
        if (await file4.exists()) await file4.delete();
      }
    });

    test('should handle invalid reorder indices gracefully', () async {
      final provider = EditorProvider();

      // Create temporary test files
      final tempDir = Directory.systemTemp;
      final file1 = File('${tempDir.path}/image1.jpg');
      final file2 = File('${tempDir.path}/image2.jpg');

      await file1.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);
      await file2.writeAsBytes([0xFF, 0xD8, 0xFF, 0xE0]);

      try {
        // Add test images
        provider.addImages([file1.path, file2.path]);

        // Try to reorder with invalid indices
        expect(() => provider.reorderImages(-1, 0), returnsNormally);
        expect(() => provider.reorderImages(0, 5), returnsNormally);

        // Verify the list remains unchanged
        expect(provider.images.length, 2);
        expect(provider.images[0].path, file1.path);
        expect(provider.images[1].path, file2.path);
      } finally {
        // Clean up test files
        if (await file1.exists()) await file1.delete();
        if (await file2.exists()) await file2.delete();
      }
    });
  });
}
