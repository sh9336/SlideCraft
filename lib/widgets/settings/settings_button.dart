import 'package:flutter/material.dart';

/// Japandi "Ghost" action button — no background, monoline icon.
/// Touch target exceeds 44px (WCAG AA).
class SettingsButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SettingsButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: 'Video Settings',
      child: IconButton(
        icon: Icon(
          Icons.tune_rounded,
          color: theme.colorScheme.onSurface,
          size: 24,
        ),
        onPressed: onPressed,
        splashRadius: 24,
        constraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
      ),
    );
  }
}

