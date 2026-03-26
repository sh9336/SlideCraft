import 'package:flutter/material.dart';

/// Japandi ghost action — no tinted background, just a monoline icon.
class ClearAllButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ClearAllButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: 'Remove All Images',
      child: IconButton(
        icon: Icon(Icons.delete_sweep_outlined),
        color: theme.colorScheme.error,
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
