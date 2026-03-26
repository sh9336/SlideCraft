import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../providers/editor_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'dart:typed_data';

class VideoPreviewScreen extends StatefulWidget {
  @override
  _VideoPreviewScreenState createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _analyzeVideoFile();
    _initializePlayer();
  }

  void _analyzeVideoFile() {
    final provider = Provider.of<EditorProvider>(context, listen: false);
    final videoPath = provider.generatedVideoPath;

    if (videoPath != null) {
      final file = File(videoPath);
      if (file.existsSync()) {
        print('Video exists at: $videoPath');
        print('File size: ${file.lengthSync()} bytes');
        try {
          final bytes = file.readAsBytesSync().take(50).toList();
          print('First bytes: $bytes');
        } catch (e) {
          print('Error reading file: $e');
        }
      } else {
        print('Video file does not exist!');
      }
    }
  }

  Future<void> _initializePlayer() async {
    final provider = Provider.of<EditorProvider>(context, listen: false);
    final videoPath = provider.generatedVideoPath;

    if (videoPath != null && videoPath.isNotEmpty) {
      final file = File(videoPath);

      if (!file.existsSync()) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Video file not found';
        });
        return;
      }

      await _videoPlayerController?.dispose();
      _chewieController?.dispose();

      _videoPlayerController = VideoPlayerController.file(file);

      try {
        await _videoPlayerController!.initialize();

        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: true,
          looping: true,
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          errorBuilder: (context, errorMessage) => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 48),
                SizedBox(height: 16),
                // Text('Failed to load video: $errorMessage',
                //     style: TextStyle(color: Colors.white),
                //     textAlign: TextAlign.center),
                Text('Failed to load Video,RETRY',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        );

        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      } catch (e) {
        setState(() {
          _hasError = true;
          //_errorMessage = 'Failed to load video: $e';
          _errorMessage = 'Failed to load video for Preview. RETRY';
        });
      }
    } else {
      setState(() {
        _hasError = true;
        //_errorMessage = 'Video path is null or empty';
        _errorMessage = 'Something went WRONG. Rebuild Video!!';
      });
    }
  }

  Future<void> _saveVideoAs() async {
    final provider = Provider.of<EditorProvider>(context, listen: false);
    final videoPath = provider.generatedVideoPath;

    if (videoPath == null || videoPath.isEmpty) {
      _showSnackBar('No video available to save', isError: true);
      return;
    }

    try {
      final File sourceFile = File(videoPath);
      if (!await sourceFile.exists()) {
        _showSnackBar('Video file not found', isError: true);
        return;
      }

      // Validate file size
      final fileSize = await sourceFile.length();
      if (fileSize < 1000) {
        _showSnackBar('Video file appears to be corrupted or empty',
            isError: true);
        return;
      }

      // Request permissions for Android
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          // For Android 13+, try videos permission
          status = await Permission.videos.request();
          if (!status.isGranted) {
            _showSnackBar('Storage or video permission denied', isError: true);
            return;
          }
        }
      }

      // Read the source file's bytes
      final Uint8List videoBytes = await sourceFile.readAsBytes();

      // Default file name from the original path
      String defaultFileName = videoPath.split('/').last;
      if (!defaultFileName.toLowerCase().endsWith('.mp4')) {
        defaultFileName = 'my_video.mp4';
      }

      // Show dialog to let user rename the file
      String? newFileName = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          final TextEditingController fileNameController =
              TextEditingController(text: defaultFileName);

          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Save Video As',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            content: TextField(
              controller: fileNameController,
              decoration: InputDecoration(
                labelText: 'File Name',
                hintText: 'Enter file name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.3),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
              FilledButton(
                onPressed: () {
                  String name = fileNameController.text.trim();
                  if (name.isEmpty) {
                    name = defaultFileName;
                  }
                  if (!name.toLowerCase().endsWith('.mp4')) {
                    name += '.mp4';
                  }
                  Navigator.of(context).pop(name);
                },
                child: Text('Save'),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          );
        },
      );

      if (newFileName == null) {
        // User cancelled the dialog
        return;
      }

      // For Android and iOS, we need to use a different approach
      if (Platform.isAndroid || Platform.isIOS) {
        // Use FilePicker with bytes parameter
        String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Save video as "$newFileName"',
          fileName: newFileName,
          bytes: videoBytes,
          type: FileType.video,
        );

        if (outputPath != null) {
          _showSnackBar('Video saved successfully');
        }
      } else {
        // For desktop platforms, use regular file picking approach
        String? outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Choose where to save "$newFileName"',
          fileName: newFileName,
          type: FileType.video,
          allowedExtensions: ['mp4'],
        );

        if (outputPath == null) {
          // User cancelled the file picker
          return;
        }

        // Ensure the output file has the .mp4 extension
        if (!outputPath.toLowerCase().endsWith('.mp4')) {
          outputPath += '.mp4';
        }

        // Write the bytes to the chosen location
        await File(outputPath).writeAsBytes(videoBytes);

        _showSnackBar('Video saved successfully to: $outputPath');
      }
    } catch (e) {
      print('Save as error: $e');
      _showSnackBar('Failed to save video: $e', isError: true);
    }
  }

  Future<void> _shareVideo() async {
    final provider = Provider.of<EditorProvider>(context, listen: false);
    final videoPath = provider.generatedVideoPath;

    if (videoPath != null) {
      await Share.shareXFiles([XFile(videoPath)],
          text: 'Check out my video created with Image Video Editor!');
    } else {
      _showSnackBar('No video available to share', isError: true);
    }
  }

  Future<void> _saveToGallery() async {
    final provider = Provider.of<EditorProvider>(context, listen: false);
    final videoPath = provider.generatedVideoPath;

    if (videoPath == null || videoPath.isEmpty) {
      _showSnackBar('No video available to save', isError: true);
      return;
    }

    final sourceFile = File(videoPath);

    if (!await sourceFile.exists()) {
      _showSnackBar('Video file not found', isError: true);
      return;
    }

    // Validate file size
    final fileSize = await sourceFile.length();
    if (fileSize < 1000) {
      _showSnackBar('Video file appears to be corrupted or empty',
          isError: true);
      return;
    }

    try {
      // Request permission on Android 10 and below
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          _showSnackBar('Storage permission denied', isError: true);
          return;
        }
      }

      // Get the Downloads directory
      Directory? downloadsDir;

      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else {
        downloadsDir = await getDownloadsDirectory();
      }

      if (downloadsDir == null || !(await downloadsDir.exists())) {
        throw 'Downloads directory not found';
      }

      final fileName = videoPath.split('/').last;
      final newFilePath = '${downloadsDir.path}/$fileName';

      await sourceFile.copy(newFilePath);

      _showSnackBar('Saved to Downloads: $fileName');
    } catch (e) {
      print('Error saving to Downloads: $e');
      _showSnackBar('Failed to save to Downloads: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(8),
      ),
    );
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EditorProvider>(context);
    final videoPath = provider.generatedVideoPath;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Video Preview',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: videoPath != null ? _shareVideo : null,
            tooltip: 'Share',
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primary.withOpacity(0.05),
                colorScheme.surface,
              ],
            ),
          ),
          child: Column(
            children: [
              // Video player container - wrapped in Expanded to take available space
              Expanded(
                child: Container(
                  margin: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Center(
                    child: videoPath == null
                        ? _buildPlaceholder('No video available')
                        : _hasError
                            ? _buildErrorDisplay()
                            : !_isInitialized
                                ? _buildLoadingDisplay()
                                : Chewie(controller: _chewieController!),
                  ),
                ),
              ),
              // Action buttons - made non-expandable, fixed height
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String message) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.videocam_off,
          color: Colors.white.withOpacity(0.7),
          size: 64,
        ),
        SizedBox(height: 16),
        Text(
          message,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorDisplay() {
    final isDecoderError = _errorMessage.toLowerCase().contains('preview') ||
        _errorMessage.toLowerCase().contains('load');

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDecoderError ? Icons.videocam_off_outlined : Icons.error_outline,
              color: Colors.white.withOpacity(0.7),
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              isDecoderError
                  ? 'Preview Unavailable'
                  : 'Something went wrong',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isDecoderError
                  ? 'Your device\'s video decoder couldn\'t load the preview. '
                    'Don\'t worry — saving or sharing the video will work perfectly.'
                  : _errorMessage,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _errorMessage = '';
                });
                _initializePlayer();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.15),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingDisplay() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 3,
        ),
        SizedBox(height: 24),
        Text(
          'Loading video...',
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Share or Save Your Video',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.save_alt,
                label: 'Downloads',
                color: colorScheme.primary,
                onPressed: _saveToGallery,
              ),
              _buildActionButton(
                icon: Icons.download,
                label: 'Save As',
                color: colorScheme.secondary,
                onPressed: _saveVideoAs,
              ),
              _buildActionButton(
                icon: Icons.share,
                label: 'Share',
                color: colorScheme.tertiary,
                onPressed: _shareVideo,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
                SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
