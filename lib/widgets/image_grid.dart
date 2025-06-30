import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/editor_provider.dart';
import '../models/image_item.dart';
import 'image_detail_dialog.dart';

class ImageGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<EditorProvider>(
      builder: (context, provider, child) {
        final images = provider.images;

        if (images.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.image_not_supported, size: 64, color: theme.colorScheme.secondary),
                const SizedBox(height: 16),
                Text(
                  'No images added yet',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add images',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: ReorderableListView.builder(
            shrinkWrap: true,
            physics: const BouncingScrollPhysics(),
            itemCount: images.length,
            onReorder: (oldIndex, newIndex) {
              provider.reorderImages(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final image = images[index];

              return Card(
                key: ValueKey(image.id),
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16.0),
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Preview
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        // Image with Hero animation for smooth transition
                        Hero(
                          tag: 'image_${image.id}',
                          child: GestureDetector(
                            onTap: () => _showImageDetail(context, image),
                            child: Image.file(
                              File(image.path),
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Control Panel
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Row(
                            children: [
                              // Edit Button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  tooltip: 'Edit Image',
                                  onPressed: () => _showImageDetail(context, image),
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Delete Button
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.white),
                                  tooltip: 'Remove Image',
                                  onPressed: () {
                                    _confirmDeleteImage(context, provider, image);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Position indicator
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Image Controls
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Duration Label
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Display Duration',
                                    style: theme.textTheme.labelLarge,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${image.duration.toStringAsFixed(1)} seconds',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              // Reorder Handle
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.drag_handle,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Duration Slider
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: theme.colorScheme.primary,
                              inactiveTrackColor: theme.colorScheme.surfaceVariant,
                              thumbColor: theme.colorScheme.primary,
                              overlayColor: theme.colorScheme.primary.withOpacity(0.2),
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8,
                              ),
                            ),
                            child: Slider(
                              value: image.duration,
                              min: 1.0,
                              max: 30.0,
                              divisions: 29,
                              label: '${image.duration.toStringAsFixed(1)}s',
                              onChanged: (value) {
                                provider.updateImageDuration(image.id, value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showImageDetail(BuildContext context, ImageItem image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImageDetailDialog(image: image);
      },
    );
  }

  void _confirmDeleteImage(BuildContext context, EditorProvider provider, ImageItem image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Image'),
          content: const Text('Are you sure you want to remove this image?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                provider.removeImage(image.id);
                Navigator.of(context).pop();
              },
              child: const Text('REMOVE'),
            ),
          ],
        );
      },
    );
  }
}