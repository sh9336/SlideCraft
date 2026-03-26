import 'package:flutter/material.dart';
import 'dart:io';
import '../models/image_item.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../constants/ui_constants.dart';

class ImageDetailDialog extends StatefulWidget {
  final ImageItem image;

  const ImageDetailDialog({Key? key, required this.image}) : super(key: key);

  @override
  State<ImageDetailDialog> createState() => _ImageDetailDialogState();
}

class _ImageDetailDialogState extends State<ImageDetailDialog> {
  late double currentDuration;

  @override
  void initState() {
    super.initState();
    currentDuration = widget.image.duration;
  }

  @override
  void didUpdateWidget(ImageDetailDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image.duration != widget.image.duration) {
      currentDuration = widget.image.duration;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.dialogBorderRadius),
      ),
      elevation: 0,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with close button
          // Header — tonal shift, no colored wash
          Container(
            color: theme.colorScheme.surfaceContainerHigh,
            padding: const EdgeInsets.symmetric(horizontal: UIConstants.space4, vertical: UIConstants.space2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Image Details',
                  style: theme.textTheme.headlineSmall,
                ),
                IconButton(
                  icon: Icon(Icons.close, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),

          // Image
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
              ),
              margin: const EdgeInsets.all(16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Hero(
                      tag: 'image-${widget.image.id}',
                      child: Image.file(
                        File(widget.image.path),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.zoom_out_map,
                              color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'Pinch to zoom',
                            style: theme.textTheme.bodySmall
                                ?.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Duration Controls
          // Duration controls — no shadow, tonal surface
          Container(
            padding: const EdgeInsets.all(UIConstants.space6),
            color: theme.colorScheme.surface,
            child: Consumer<EditorProvider>(
              builder: (context, provider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Duration Header with Value
                    Row(
                      children: [
                        Icon(Icons.timer_outlined,
                            size: 22, color: theme.colorScheme.secondary),
                        const SizedBox(width: UIConstants.space3),
                        Text(
                          'Duration',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: UIConstants.space4, vertical: UIConstants.space2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius),
                          ),
                          child: Text(
                            '${currentDuration.toStringAsFixed(1)}s',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: UIConstants.space6),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: theme.colorScheme.secondary,
                        inactiveTrackColor: theme.colorScheme.secondaryContainer,
                        thumbColor: theme.colorScheme.secondary,
                        overlayColor:
                            theme.colorScheme.secondary.withOpacity(0.12),
                        valueIndicatorColor: theme.colorScheme.onSurface,
                        valueIndicatorTextStyle: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                        trackHeight: 4.0,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6.0,
                          elevation: 2.0,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 16.0,
                        ),
                      ),
                      child: Slider(
                        value: currentDuration,
                        min: 1.0,
                        max: 30.0,
                        divisions: 29,
                        label: '${currentDuration.toStringAsFixed(1)}s',
                        onChanged: (value) {
                          setState(() {
                            currentDuration = value;
                          });
                          provider.updateImageDuration(widget.image.id, value);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '1.0s',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '30.0s',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: UIConstants.space8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Ghost button — reset
                        OutlinedButton.icon(
                          icon: Icon(
                            Icons.restart_alt_rounded,
                            color: theme.colorScheme.onSurface,
                          ),
                          label: Text('Reset'),
                          style: OutlinedButton.styleFrom(
                            padding: UIConstants.buttonPadding,
                            foregroundColor: theme.colorScheme.onSurface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius),
                            ),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              currentDuration = 5.0;
                            });
                            provider.updateImageDuration(
                                widget.image.id, 5.0);
                          },
                        ),
                        const SizedBox(width: UIConstants.space3),
                        // Primary pill button — apply
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.onSurface,
                            foregroundColor: theme.colorScheme.surface,
                            padding: UIConstants.buttonPadding,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
