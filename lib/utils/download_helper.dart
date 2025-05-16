import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'toast_helper.dart';

/// Helper class để hiển thị tiến trình tải xuống đẹp và chuyên nghiệp
class DownloadHelper {
  /// Hiển thị Dialog tiến trình tải xuống
  static Future<void> showDownloadProgress({
    required BuildContext context,
    required String title,
    required Future<bool> Function() downloadTask,
  }) async {
    // Hiển thị dialog tiến trình
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return DownloadProgressDialog(
          title: title,
          downloadTask: downloadTask,
        );
      },
    );
  }
}

/// Dialog hiển thị tiến trình tải xuống
class DownloadProgressDialog extends StatefulWidget {
  final String title;
  final Future<bool> Function() downloadTask;

  const DownloadProgressDialog({
    Key? key,
    required this.title,
    required this.downloadTask,
  }) : super(key: key);

  @override
  State<DownloadProgressDialog> createState() => _DownloadProgressDialogState();
}

class _DownloadProgressDialogState extends State<DownloadProgressDialog> {
  bool _isDownloading = true;
  bool _isCompleted = false;
  bool _hasError = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _startDownload();
  }
  
  Future<void> _startDownload() async {
    try {
      final success = await widget.downloadTask();
      
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isCompleted = success;
          _hasError = !success;
        });
        
        // Nếu thành công, đóng dialog sau 1.5 giây
        if (success) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.of(context).pop();
              
              // Hiển thị toast thành công
              ToastHelper().showSuccessToast(
                context: context,
                message: 'Tải xuống thành công',
                details: widget.title,
              );
            }
          });
        } else {
          // Nếu lỗi, hiển thị nút "Đóng"
          setState(() {
            _errorMessage = 'Không thể tải xuống. Vui lòng thử lại sau.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _hasError = true;
          _errorMessage = 'Lỗi: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildContent(),
            const SizedBox(height: 16),
            if (_hasError) _buildErrorButton(),
          ],
        ),
      ),
    ).animate().scale(
      duration: 400.ms,
      curve: Curves.easeOutBack,
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
    );
  }
  
  Widget _buildHeader() {
    return Row(
      children: [
        Icon(
          _isDownloading
              ? Icons.download_rounded
              : (_isCompleted ? Icons.check_circle : Icons.error),
          color: _isDownloading
              ? Theme.of(context).primaryColor
              : (_isCompleted ? Colors.green : Colors.red),
          size: 28,
        ).animate(
          onPlay: (controller) => _isDownloading ? controller.repeat() : null,
        ).rotate(
          duration: 1.seconds,
          begin: 0,
          end: _isDownloading ? 1.0 : 0,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isDownloading
                    ? 'Đang tải xuống...'
                    : (_isCompleted ? 'Tải xuống thành công!' : 'Tải xuống thất bại'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildContent() {
    if (_isDownloading) {
      return Column(
        children: [
          LinearProgressIndicator(
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 10),
          Text(
            'please_wait'.tr(),
            style: const TextStyle(fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else if (_isCompleted) {
      return Column(
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 48,
          ).animate().scale(
            duration: 400.ms,
            curve: Curves.elasticOut,
            begin: const Offset(0.5, 0.5),
            end: const Offset(1.0, 1.0),
          ),
          const SizedBox(height: 10),
          Text(
            'download_completed'.tr(),
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      );
    } else {
      return Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ).animate().shake(
            duration: 400.ms,
            curve: Curves.easeOut,
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage,
            style: const TextStyle(fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
  }
  
  Widget _buildErrorButton() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text('close'.tr()),
    );
  }
} 