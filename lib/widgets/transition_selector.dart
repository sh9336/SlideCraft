import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/editor_provider.dart';
import '../models/transition_type.dart';

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
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.2,
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
                borderRadius: BorderRadius.circular(12),
                splashColor: theme.colorScheme.primary.withOpacity(0.3),
                child: Ink(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.15)
                        : theme.colorScheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ] : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Transition Icon with animated container
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withOpacity(0.2)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: _buildTransitionIcon(transition, theme, isSelected),
                          ),
                          const SizedBox(height: 6),

                          // Transition Name
                          Text(
                            transition.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),

                      // Selected Indicator
                      if (isSelected)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
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
    final iconColor = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;
    final iconSize = 24.0;

    switch (type) {
      case TransitionType.fade:
        return Icon(Icons.blur_on, color: iconColor, size: iconSize);
      case TransitionType.slideleft:
        return Icon(Icons.arrow_back, color: iconColor, size: iconSize);
      case TransitionType.slideright:
        return Icon(Icons.arrow_forward, color: iconColor, size: iconSize);
      case TransitionType.circleopen:
        return Icon(Icons.circle_outlined, color: iconColor, size: iconSize);
      case TransitionType.circleclose:
        return Icon(Icons.radio_button_checked, color: iconColor, size: iconSize);
      case TransitionType.dissolve:
        return Icon(Icons.blur_circular, color: iconColor, size: iconSize);
      case TransitionType.wipeleft:
        return Icon(Icons.west, color: iconColor, size: iconSize);
      case TransitionType.wipedown:
        return Icon(Icons.arrow_downward, color: iconColor, size: iconSize);
      case TransitionType.smoothleft:
        return Icon(Icons.trending_flat, color: iconColor, size: iconSize);
      case TransitionType.pixelize:
        return Icon(Icons.grid_view, color: iconColor, size: iconSize);
      default:
        return Icon(Icons.blur_on, color: iconColor, size: iconSize);
    }
  }
}