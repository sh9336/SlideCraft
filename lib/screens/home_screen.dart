import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/editor_provider.dart';
import '../widgets/image_grid.dart';
import '../widgets/settings/settings_button.dart';
import '../widgets/settings/clear_all_button.dart';
import '../widgets/settings/video_settings_panel.dart';
import '../widgets/bottom_bar/bottom_bar_button.dart';
import '../widgets/dialogs/generation_dialog.dart';
import '../widgets/dialogs/clear_all_dialog.dart';
import '../widgets/empty_state.dart';
import '../constants/ui_constants.dart';
import 'video_preview_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> selectedImages = await _picker.pickMultiImage(
        imageQuality: UIConstants.imageQuality.toInt(),
      );

      if (selectedImages.isNotEmpty && mounted) {
        final List<String> imagePaths =
            selectedImages.map((img) => img.path).toList();
        Provider.of<EditorProvider>(context, listen: false)
            .addImages(imagePaths);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error selecting images: ${e.toString()}');
      }
    }
  }

  Future<void> _captureImage() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: UIConstants.imageQuality.toInt(),
      );

      if (photo != null && mounted) {
        Provider.of<EditorProvider>(context, listen: false)
            .addImages([photo.path]);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error capturing image: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: UIConstants.space2),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.cardBorderRadius),
        ),
        margin: UIConstants.defaultPadding,
      ),
    );
  }

  Future<void> _generateVideo() async {
    final provider = Provider.of<EditorProvider>(context, listen: false);

    if (provider.images.isEmpty) {
      _showErrorSnackBar('Please add at least one image');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const GenerationDialog(),
    );

    try {
      await provider.generateVideo();

      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        if (provider.generatedVideoPath != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => VideoPreviewScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }

        if (!e.toString().contains('cancelled')) {
          _showErrorSnackBar('Error generating video: ${e.toString()}');
        }
      }
    }
  }

  void _confirmClearAll() {
    showDialog(
      context: context,
      builder: (BuildContext context) => ClearAllDialog(
        onConfirm: () {
          Provider.of<EditorProvider>(context, listen: false).clearAll();
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.dialogBorderRadius),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: SingleChildScrollView(
            child: VideoSettingsPanel(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      bottomNavigationBar: _buildBottomBar(),
      body: SafeArea(
        bottom: false,
        child: Consumer<EditorProvider>(
          builder: (context, provider, child) {
            return CustomScrollView(
              slivers: [
                provider.images.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyState(
                          onPickImages: _pickImages,
                          onCaptureImage: _captureImage,
                        ),
                      )
                    : SliverToBoxAdapter(
                        child: Container(
                          margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom + 80,
                          ),
                          child: ImageGrid(),
                        ),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── AppBar: Flat, no rounding, tonal surface ───
  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          // Logo container — soft organic shape
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(UIConstants.iconBorderRadius),
            ),
            child: Image.asset(
              'assets/app_icon.png',
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: UIConstants.space3),
          // Title — Noto Serif editorial voice
          Text(
            'SlideCraft',
            style: theme.textTheme.headlineMedium,
          ),
        ],
      ),
      actions: [
        SettingsButton(
          onPressed: _showSettingsDialog,
        ),
        ClearAllButton(onPressed: _confirmClearAll),
        const SizedBox(width: UIConstants.space2),
      ],
    );
  }

  // ─── Bottom Bar: No borders, tonal shift only (The "No-Line" Rule) ───
  Widget _buildBottomBar() {
    return Consumer<EditorProvider>(
      builder: (context, provider, child) {
        final theme = Theme.of(context);
        return Container(
          // Tonal shift creates boundary — no lines
          color: theme.colorScheme.surfaceContainer,
          child: SafeArea(
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: UIConstants.space4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: BottomBarButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'CAMERA',
                      onPressed: _captureImage,
                    ),
                  ),
                  Expanded(
                    child: BottomBarButton(
                      icon: Icons.photo_library_rounded,
                      label: 'GALLERY',
                      onPressed: _pickImages,
                    ),
                  ),
                  Expanded(
                    child: BottomBarButton(
                      icon: Icons.movie_creation_rounded,
                      label: 'CREATE',
                      onPressed:
                          provider.images.isEmpty ? null : _generateVideo,
                      isActive: provider.images.isNotEmpty,
                      highlight: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
