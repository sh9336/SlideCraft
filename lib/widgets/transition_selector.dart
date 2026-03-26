import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../models/transition_type.dart';
import '../constants/ui_constants.dart';

/// Japandi transition selector — tonal layering, no hard borders.
class TransitionSelector extends StatelessWidget {
  const TransitionSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<EditorProvider>(
      builder: (context, provider, child) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0, // Square cells — prevents overflow
          ),
          itemCount: TransitionType.values.length,
          itemBuilder: (context, index) {
            final transition = TransitionType.values[index];
            final isSelected = provider.transitionType == transition;

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  provider.setTransitionType(transition);
                },
                borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
                child: Ink(
                  decoration: BoxDecoration(
                    // Tonal layering — no borders
                    color: isSelected
                        ? theme.colorScheme.secondaryContainer
                        : theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon — monoline, no extra padding
                          _buildTransitionIcon(transition, theme, isSelected),
                          const SizedBox(height: 4),
                          // Label — all-caps functional
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              transition.displayName.toUpperCase(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected
                                    ? theme.colorScheme.secondary
                                    : theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      // Selected check — secondary accent
                      if (isSelected)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: theme.colorScheme.onSecondary,
                              size: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTransitionIcon(TransitionType type, ThemeData theme, bool isSelected) {
    final iconColor = isSelected
        ? theme.colorScheme.secondary
        : theme.colorScheme.onSurface.withOpacity(0.6);
    const iconSize = 22.0;

    switch (type) {
      case TransitionType.fade:
        return Icon(Icons.blur_on_outlined, color: iconColor, size: iconSize);
      case TransitionType.slideleft:
        return Icon(Icons.arrow_back, color: iconColor, size: iconSize);
      case TransitionType.slideright:
        return Icon(Icons.arrow_forward, color: iconColor, size: iconSize);
      case TransitionType.circleopen:
        return Icon(Icons.circle_outlined, color: iconColor, size: iconSize);
      case TransitionType.circleclose:
        return Icon(Icons.radio_button_checked, color: iconColor, size: iconSize);
      case TransitionType.dissolve:
        return Icon(Icons.blur_circular_outlined, color: iconColor, size: iconSize);
      case TransitionType.wipeleft:
        return Icon(Icons.west, color: iconColor, size: iconSize);
      case TransitionType.wipedown:
        return Icon(Icons.arrow_downward, color: iconColor, size: iconSize);
      case TransitionType.smoothleft:
        return Icon(Icons.trending_flat, color: iconColor, size: iconSize);
      case TransitionType.pixelize:
        return Icon(Icons.grid_view_outlined, color: iconColor, size: iconSize);
      default:
        return Icon(Icons.blur_on_outlined, color: iconColor, size: iconSize);
    }
  }
}