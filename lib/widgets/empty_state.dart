import 'package:flutter/material.dart';
import '../constants/ui_constants.dart';

/// Empty state — Japandi editorial layout.
/// Generous whitespace, serif headline, pill buttons.
class EmptyState extends StatelessWidget {
  final VoidCallback onPickImages;
  final VoidCallback onCaptureImage;

  const EmptyState({
    super.key,
    required this.onPickImages,
    required this.onCaptureImage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(UIConstants.space10),
        margin: const EdgeInsets.all(UIConstants.space6),
        // Tonal layering — no shadow, no border
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon — organic circle with secondary accent
            Container(
              padding: const EdgeInsets.all(UIConstants.space6),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_library_outlined,
                size: 48,
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: UIConstants.space8),
            // Headline — Noto Serif editorial voice
            Text(
              'Begin Your Story',
              style: theme.textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: UIConstants.space3),
            // Subtitle — label-sm all-caps
            Text(
              'CURATE YOUR MEMORIES',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: UIConstants.space4),
            // Body — Plus Jakarta Sans
            Text(
              'Select images from your gallery or capture new moments to craft a cinematic video.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.6,
              ),
            ),
            const SizedBox(height: UIConstants.space10),
            // Primary CTA — "The Hearth" pill button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: const Text('Add Images'),
                onPressed: onPickImages,
                style: ElevatedButton.styleFrom(
                  padding: UIConstants.buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius),
                  ),
                  backgroundColor: theme.colorScheme.onSurface,
                  foregroundColor: theme.colorScheme.surface,
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: UIConstants.space3),
            // Secondary CTA — Ghost button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Take Photo'),
                onPressed: onCaptureImage,
                style: OutlinedButton.styleFrom(
                  padding: UIConstants.buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(UIConstants.buttonBorderRadius),
                  ),
                  side: BorderSide(
                    color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                  ),
                  foregroundColor: theme.colorScheme.onSurface,
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
