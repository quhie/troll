import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sound_model.dart';
import '../services/download_service.dart';

/// A modern button for downloading sounds with progress indication
class DownloadButton extends StatefulWidget {
  final SoundModel sound;
  final Color? color;
  final VoidCallback? onDownloaded;

  const DownloadButton({
    super.key,
    required this.sound,
    this.color,
    this.onDownloaded,
  });

  @override
  State<DownloadButton> createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton>
    with SingleTickerProviderStateMixin {
  late DownloadService _downloadService;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  DownloadStatus _status = DownloadStatus.notStarted;
  double _progress = 0.0;
  StreamSubscription? _progressSubscription;

  @override
  void initState() {
    super.initState();
    _downloadService = DownloadService();

    // Initialize animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Check initial download status
    _checkDownloadStatus();

    // Listen for download progress updates
    _progressSubscription = _downloadService.downloadProgressStream.listen((
      event,
    ) {
      if (event.id == widget.sound.id) {
        setState(() {
          _status = event.status;
          _progress = event.progress;

          if (_status == DownloadStatus.completed &&
              widget.onDownloaded != null) {
            widget.onDownloaded!();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressSubscription?.cancel();
    super.dispose();
  }

  // Check if the sound is already downloaded
  Future<void> _checkDownloadStatus() async {
    final isDownloaded = await _downloadService.isDownloaded(widget.sound.id);
    if (isDownloaded) {
      setState(() {
        _status = DownloadStatus.completed;
        _progress = 1.0;
      });
    } else {
      setState(() {
        _status = _downloadService.getDownloadStatus(widget.sound.id);
      });
    }
  }

  // Start download process
  Future<void> _download() async {
    if (_status == DownloadStatus.inProgress) return;

    // Animate button press
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    if (_status == DownloadStatus.completed) {
      // If already downloaded, show options dialog
      _showDownloadOptions();
    } else {
      // Start download
      await _downloadService.downloadSound(widget.sound);
    }
  }

  // Show options for downloaded sound
  void _showDownloadOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Delete download'),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteDownload();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text('Share sound'),
                  onTap: () {
                    Navigator.pop(context);
                    // Share functionality to be implemented
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Share functionality coming soon'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
    );
  }

  // Delete the downloaded sound
  Future<void> _deleteDownload() async {
    final result = await _downloadService.deleteDownloadedSound(
      widget.sound.id,
    );
    if (result) {
      setState(() {
        _status = DownloadStatus.notStarted;
        _progress = 0.0;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Download deleted')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _download,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getButtonColor(context),
          ),
          child: Center(child: _buildButtonContent()),
        ),
      ),
    );
  }

  // Get the button color based on status
  Color _getButtonColor(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.color != null) return widget.color!;

    switch (_status) {
      case DownloadStatus.completed:
        return theme.colorScheme.primary;
      case DownloadStatus.failed:
        return theme.colorScheme.error;
      case DownloadStatus.inProgress:
        return theme.colorScheme.secondary.withOpacity(0.7);
      case DownloadStatus.notStarted:
        return theme.colorScheme.surfaceVariant;
    }
  }

  // Build the button content based on status
  Widget _buildButtonContent() {
    switch (_status) {
      case DownloadStatus.notStarted:
        return const Icon(Icons.download, color: Colors.white, size: 20);

      case DownloadStatus.inProgress:
        return Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: _progress > 0 ? _progress : null,
              strokeWidth: 2,
              color: Colors.white,
            ),
            const Icon(Icons.download, color: Colors.white, size: 16),
          ],
        );

      case DownloadStatus.completed:
        return const Icon(Icons.check, color: Colors.white, size: 20);

      case DownloadStatus.failed:
        return const Icon(Icons.error_outline, color: Colors.white, size: 20);
    }
  }
}
