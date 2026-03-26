import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/editor_provider.dart';
import '../../constants/ui_constants.dart';

class GenerationDialog extends StatelessWidget {
  const GenerationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<EditorProvider>(
      builder: (context, provider, child) {
        return AlertDialog(
          title: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                ),
              ),
              const SizedBox(width: UIConstants.space4),
              Text('Creating Your Video', style: theme.textTheme.headlineSmall),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please wait while we generate your video...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: UIConstants.space6),
              LinearProgressIndicator(
                value: provider.generationProgress,
                backgroundColor: theme.colorScheme.surfaceContainerHigh,
                valueColor:
                    AlwaysStoppedAnimation<Color>(theme.colorScheme.secondary),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: UIConstants.space3),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${(provider.generationProgress * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                provider.cancelVideoGeneration();
                await Future.delayed(const Duration(milliseconds: 100));
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              child: const Text('Cancel'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.dialogBorderRadius),
          ),
        );
      },
    );
  }
}
