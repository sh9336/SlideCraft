import 'package:flutter/material.dart';
import '../../models/video_quality.dart';

class QualityDropdown extends StatelessWidget {
  final VideoQuality value;
  final ValueChanged<VideoQuality> onChanged;

  const QualityDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<VideoQuality>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(8),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          onChanged: (newValue) => onChanged(newValue!),
          items: VideoQuality.values.map((quality) {
            return DropdownMenuItem<VideoQuality>(
              value: quality,
              child: Text(quality.displayName),
            );
          }).toList(),
        ),
      ),
    );
  }
}
