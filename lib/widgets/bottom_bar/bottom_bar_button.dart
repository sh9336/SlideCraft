import 'package:flutter/material.dart';

/// Japandi bottom bar action — tonal layering, all-caps labels.
/// Highlight mode uses `secondary` (sage green) as "The Hearth" accent.
class BottomBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isActive;
  final bool highlight;

  const BottomBarButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isActive = true,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Japandi tonal hierarchy
    Color iconColor;
    Color bgColor;

    if (!isActive) {
      iconColor = theme.colorScheme.onSurface.withOpacity(0.3);
      bgColor = Colors.transparent;
    } else if (highlight) {
      iconColor = theme.colorScheme.onSecondary;
      bgColor = theme.colorScheme.secondary; // sage green — "The Hearth"
    } else {
      iconColor = theme.colorScheme.onSurface;
      bgColor = theme.colorScheme.surfaceContainerHigh;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          constraints: const BoxConstraints(minWidth: 64, minHeight: 44),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isActive
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.3),
                  fontWeight: highlight && isActive
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
