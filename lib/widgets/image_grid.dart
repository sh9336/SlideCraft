import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/editor_provider.dart';
import '../models/image_item.dart';
import '../constants/ui_constants.dart';
import 'image_detail_dialog.dart';

class ImageGrid extends StatelessWidget {
  const ImageGrid({super.key});

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
                Icon(Icons.image_not_supported,
                    size: 64, color: theme.colorScheme.secondary),
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
          padding: const EdgeInsets.all(UIConstants.space4),
          child: images.length == 1
              ? _buildSingleImageList(context, images, provider)
              : _buildReorderableList(context, images, provider),
        );
      },
    );
  }

  Widget _buildSingleImageList(
    BuildContext context,
    List<ImageItem> images,
    EditorProvider provider,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return _buildImageCard(context, images[index], index, provider);
      },
    );
  }

  Widget _buildReorderableList(
    BuildContext context,
    List<ImageItem> images,
    EditorProvider provider,
  ) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: images.length,
      onReorder: (oldIndex, newIndex) {
        provider.reorderImages(oldIndex, newIndex);
      },
      itemBuilder: (context, index) {
        return _buildImageCard(context, images[index], index, provider);
      },
    );
  }

  Widget _buildImageCard(
    BuildContext context,
    ImageItem image,
    int index,
    EditorProvider provider,
  ) {
    final theme = Theme.of(context);

    return Card(
      key: ValueKey(image.id),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: UIConstants.space5),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
      ),
      color: theme.colorScheme.surfaceContainerLowest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Preview with Controls
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image with Hero animation
                Hero(
                  tag: 'image_${image.id}',
                  child: GestureDetector(
                    onTap: () => _showImageDetail(context, image),
                    child: Image.file(
                      File(image.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Gradient overlay for better control visibility
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black54,
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Controls overlay
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Position indicator
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Action buttons
                      Row(
                        children: [
                          _buildActionButton(
                            icon: Icons.edit,
                            onPressed: () => _showImageDetail(context, image),
                            theme: theme,
                          ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.delete,
                            onPressed: () =>
                                _confirmDeleteImage(context, provider, image),
                            theme: theme,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Duration Controls
          // Duration controls — tonal shift, no border
          Container(
            padding: const EdgeInsets.all(UIConstants.space4),
            color: theme.colorScheme.surfaceContainerLowest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Duration information
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Display Duration',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
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

                    // Drag handle indicator (only show for multiple images)
                    if (provider.images.length > 1)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.drag_indicator,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Drag to reorder',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Enhanced Duration Slider
                SliderTheme(
                data: SliderTheme.of(context).copyWith(
                    activeTrackColor: theme.colorScheme.secondary,
                    inactiveTrackColor: theme.colorScheme.secondaryContainer,
                    thumbColor: theme.colorScheme.secondary,
                    overlayColor: theme.colorScheme.secondary.withOpacity(0.2),
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                      elevation: 2,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 16,
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
  }

  void _showImageDetail(BuildContext context, ImageItem image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ImageDetailDialog(image: image);
      },
    );
  }

  // Custom action button widget for consistent styling
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color    : theme.colorScheme.onSurface.withOpacity(0.55),
        borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius),
      ),
      child: IconButton(
        icon: Icon(icon, color: theme.colorScheme.surface, size: 20),
        tooltip: icon == Icons.edit ? 'Edit Image' : 'Remove Image',
        onPressed: onPressed,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 36,
          minHeight: 36,
        ),
      ),
    );
  }

  void _confirmDeleteImage(
      BuildContext context, EditorProvider provider, ImageItem image) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.dialogBorderRadius),
          ),
          title: Text('Remove Image', style: theme.textTheme.headlineSmall),
          content: Text(
            'Are you sure you want to remove this image?',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurface,
              ),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                provider.removeImage(image.id);
                Navigator.of(dialogContext).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              child: const Text('REMOVE'),
            ),
          ],
        );
      },
    );
  }
}
