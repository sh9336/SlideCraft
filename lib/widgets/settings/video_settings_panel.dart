import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/editor_provider.dart';
import '../../models/video_quality.dart';
import '../../constants/ui_constants.dart';
import '../transition_selector.dart';
import 'duration_slider.dart';
import 'quality_dropdown.dart';

/// Japandi settings panel — editorial layout, generous whitespace.
class VideoSettingsPanel extends StatelessWidget {
  const VideoSettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(UIConstants.space6),
      child: Consumer<EditorProvider>(
        builder: (context, provider, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Serif editorial title
                  Text(
                    'Settings',
                    style: theme.textTheme.headlineMedium,
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: UIConstants.space4),
              // Tonal divider — background shift, not a line
              Container(
                height: 1,
                color: theme.colorScheme.surfaceContainerHigh,
              ),
              const SizedBox(height: UIConstants.space6),
              SettingSection(
                icon: Icons.timer_outlined,
                title: 'Image Duration',
                subtitle:
                    '${provider.imageDuration.toStringAsFixed(1)} SECONDS',
                child: DurationSlider(
                  value: provider.imageDuration,
                  min: 1.0,
                  max: 30.0,
                  divisions: 29,
                  onChanged: provider.setImageDuration,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: UIConstants.space6),
              SettingSection(
                icon: Icons.compare_arrows_outlined,
                title: 'Transition Duration',
                subtitle:
                    '${provider.transitionDuration.toStringAsFixed(1)} SECONDS',
                child: DurationSlider(
                  value: provider.transitionDuration,
                  min: 0.1,
                  max: 1.0,
                  divisions: 9,
                  onChanged: provider.setTransitionDuration,
                  color: theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(height: UIConstants.space6),
              SettingSection(
                icon: Icons.animation_outlined,
                title: 'Transition Type',
                subtitle: 'SELECT EFFECT',
                child: TransitionSelector(),
              ),
              const SizedBox(height: UIConstants.space6),
              SettingSection(
                icon: Icons.high_quality_outlined,
                title: 'Video Quality',
                subtitle: provider.videoQuality.displayName.toUpperCase(),
                child: QualityDropdown(
                  value: provider.videoQuality,
                  onChanged: provider.setVideoQuality,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Japandi setting section — monoline icon, functional text hierarchy.
class SettingSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  const SettingSection({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.secondary),
            const SizedBox(width: UIConstants.space2),
            Text(
              title,
              style: theme.textTheme.titleSmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: UIConstants.space2),
        child,
      ],
    );
  }
}
