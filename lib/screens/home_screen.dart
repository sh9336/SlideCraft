import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/editor_provider.dart';
import '../widgets/image_grid.dart';
import '../widgets/transition_selector.dart';
import '../models/video_quality.dart';
import 'video_preview_screen.dart';
import 'dart:io';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isSettingsExpanded = false;

  Future<void> _pickImages() async {
    try {
      final List<XFile> selectedImages = await _picker.pickMultiImage(
        imageQuality: 100,
      );

      if (selectedImages.isNotEmpty) {
        final List<String> imagePaths = selectedImages.map((img) => img.path).toList();
        Provider.of<EditorProvider>(context, listen: false).addImages(imagePaths);
      }
    } catch (e) {
      print('Error picking images: $e');
      _showErrorSnackBar('Error selecting images');
    }
  }

  Future<void> _captureImage() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );

      if (photo != null) {
        Provider.of<EditorProvider>(context, listen: false).addImages([photo.path]);
      }
    } catch (e) {
      print('Error capturing image: $e');
      _showErrorSnackBar('Error capturing image');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(12),
      ),
    );
  }

  Future<void> _generateVideo() async {
    final provider = Provider.of<EditorProvider>(context, listen: false);

    if (provider.images.isEmpty) {
      _showErrorSnackBar('Please add at least one image');
      return;
    }

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
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
                        valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    SizedBox(width: 16),
                    Text('Creating Your Video', style: TextStyle(fontSize: 18)),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please wait while we generate your video...',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    SizedBox(height: 24),
                    LinearProgressIndicator(
                      value: provider.generationProgress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(provider.generationProgress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              );
            },
          );
        },
      );

      // Generate video
      await provider.generateVideo();

      // Close loading dialog
      Navigator.of(context).pop();

      // Navigate to preview screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoPreviewScreen(),
        ),
      );
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Show error
      _showErrorSnackBar('Error generating video: $e');
    }
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear All Images'),
          content: Text('Are you sure you want to remove all images? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('CANCEL'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
              ),
            ),
            TextButton(
              onPressed: () {
                Provider.of<EditorProvider>(context, listen: false).clearAll();
                Navigator.of(context).pop();
              },
              child: Text('CLEAR ALL'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(16),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.slideshow,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Image Video Editor',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: _isSettingsExpanded
                  ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.7)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Tooltip(
              message: 'Video Generation Settings',
              child: IconButton(
                icon: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      _isSettingsExpanded ? Icons.tune : Icons.tune_outlined,
                      color: _isSettingsExpanded
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    if (!_isSettingsExpanded)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  setState(() {
                    _isSettingsExpanded = !_isSettingsExpanded;
                  });
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 4.0),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Tooltip(
                message: 'Remove All Images',
                child: IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  color: Theme.of(context).colorScheme.error,
                  onPressed: _confirmClearAll,
                ),
              ),
            ),
          ),
        ],
      ),
      // Using a LayoutBuilder to get the available height
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Consumer<EditorProvider>(
              builder: (context, provider, child) {
                return CustomScrollView(
                  slivers: [
                    // Settings Panel
                    SliverToBoxAdapter(
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        height: _isSettingsExpanded ? null : 0,
                        child: AnimatedOpacity(
                          opacity: _isSettingsExpanded ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 200),
                          child: Card(
                            margin: EdgeInsets.all(12),
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Video Settings',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  Divider(height: 24),

                                  // Image Duration
                                  _buildSettingSection(
                                    icon: Icons.timer,
                                    title: 'Image Duration',
                                    subtitle: '${provider.imageDuration.toStringAsFixed(1)} seconds',
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor: theme.colorScheme.primary,
                                        inactiveTrackColor: theme.colorScheme.primary.withOpacity(0.2),
                                        thumbColor: theme.colorScheme.primary,
                                        overlayColor: theme.colorScheme.primary.withOpacity(0.2),
                                      ),
                                      child: Slider(
                                        value: provider.imageDuration,
                                        min: 1.0,
                                        max: 30.0,
                                        divisions: 29,
                                        label: provider.imageDuration.toStringAsFixed(1),
                                        onChanged: provider.setImageDuration,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 16),

                                  // Transition Duration
                                  _buildSettingSection(
                                    icon: Icons.compare_arrows,
                                    title: 'Transition Duration',
                                    subtitle: '${provider.transitionDuration.toStringAsFixed(1)} seconds',
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor: theme.colorScheme.secondary,
                                        inactiveTrackColor: theme.colorScheme.secondary.withOpacity(0.2),
                                        thumbColor: theme.colorScheme.secondary,
                                        overlayColor: theme.colorScheme.secondary.withOpacity(0.2),
                                      ),
                                      child: Slider(
                                        value: provider.transitionDuration,
                                        min: 0.1,
                                        max: 1.0,
                                        divisions: 9,
                                        label: provider.transitionDuration.toStringAsFixed(1),
                                        onChanged: provider.setTransitionDuration,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 16),

                                  // Transition Type
                                  _buildSettingSection(
                                    icon: Icons.animation,
                                    title: 'Transition Type',
                                    subtitle: 'Select a transition effect',
                                    child: TransitionSelector(),
                                  ),

                                  SizedBox(height: 16),

                                  // Video Quality
                                  _buildSettingSection(
                                    icon: Icons.high_quality,
                                    title: 'Video Quality',
                                    subtitle: provider.videoQuality.displayName,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.shade300),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<VideoQuality>(
                                          value: provider.videoQuality,
                                          isExpanded: true,
                                          borderRadius: BorderRadius.circular(8),
                                          padding: EdgeInsets.symmetric(horizontal: 12),
                                          onChanged: (newValue) => provider.setVideoQuality(newValue!),
                                          items: VideoQuality.values.map((quality) {
                                            return DropdownMenuItem<VideoQuality>(
                                              value: quality,
                                              child: Text(quality.displayName),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Image Grid or Empty State
                    provider.images.isEmpty
                        ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(),
                    )
                        : SliverToBoxAdapter(
                      child: SizedBox(
                        // height: constraints.maxHeight - (_isSettingsExpanded ? 400 : 0),
                        height: (_isSettingsExpanded)?(constraints.maxHeight -  400).clamp(0.0, double.infinity):constraints.maxHeight,
                        child: ImageGrid(),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  Widget _buildSettingSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(24),
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
            ),
            SizedBox(height: 24),
            Text(
              'No Images Added Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Add images from your gallery or take a new photo to create a video',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 32),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.add_photo_alternate),
                  label: Text('Add Images'),
                  onPressed: _pickImages,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  icon: Icon(Icons.camera_alt),
                  label: Text('Take Photo'),
                  onPressed: _captureImage,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    return Consumer<EditorProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (provider.images.isNotEmpty) ...[
                FloatingActionButton(
                  onPressed: _captureImage,
                  heroTag: 'camera',
                  mini: true,
                  child: Icon(Icons.camera_alt),
                  tooltip: 'Take Photo',
                ),
                SizedBox(height: 16),
                FloatingActionButton(
                  onPressed: _pickImages,
                  heroTag: 'gallery',
                  mini: true,
                  child: Icon(Icons.photo_library),
                  tooltip: 'Select Images',
                ),
                SizedBox(height: 16),
              ],
              FloatingActionButton.extended(
                onPressed: provider.images.isEmpty ? null : _generateVideo,
                heroTag: 'generate',
                icon: Icon(Icons.movie_creation),
                label: Text('Create Video'),
                backgroundColor: provider.images.isEmpty
                    ? Colors.grey.shade400
                    : Colors.green.shade400,
                elevation: provider.images.isEmpty ? 2 : 4,
              ),
            ],
          ),
        );
      },
    );
  }
}