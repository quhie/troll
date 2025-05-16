import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Helper class để hiển thị các toast thông báo đẹp và tinh tế
class ToastHelper {
  // Singleton instance
  static final ToastHelper _instance = ToastHelper._internal();
  factory ToastHelper() => _instance;
  ToastHelper._internal();

  // Toast FToast instance
  FToast? _fToast;
  
  /// Khởi tạo FToast với context
  void init(BuildContext context) {
    _fToast = FToast();
    _fToast?.init(context);
  }

  /// Hiển thị toast thành công với icon và animation
  void showSuccessToast({
    required BuildContext context,
    required String message,
    String? details,
    Duration duration = const Duration(seconds: 2),
  }) {
    _ensureFToastInitialized(context);
    
    _fToast?.removeQueuedCustomToasts();
    _fToast?.showToast(
      child: _buildToast(
        context: context,
        message: message,
        details: details,
        icon: Icons.check_circle,
        iconColor: Colors.green,
        backgroundColor: Colors.white,
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: duration,
    );
  }

  /// Hiển thị toast lỗi với icon và animation
  void showErrorToast({
    required BuildContext context,
    required String message,
    String? details,
    Duration duration = const Duration(seconds: 3),
  }) {
    _ensureFToastInitialized(context);
    
    _fToast?.removeQueuedCustomToasts();
    _fToast?.showToast(
      child: _buildToast(
        context: context,
        message: message,
        details: details,
        icon: Icons.error_outline,
        iconColor: Colors.red,
        backgroundColor: Colors.white,
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: duration,
    );
  }

  /// Hiển thị toast thông tin với icon và animation
  void showInfoToast({
    required BuildContext context,
    required String message,
    String? details,
    Duration duration = const Duration(seconds: 2),
  }) {
    _ensureFToastInitialized(context);
    
    _fToast?.removeQueuedCustomToasts();
    _fToast?.showToast(
      child: _buildToast(
        context: context,
        message: message,
        details: details,
        icon: Icons.info_outline,
        iconColor: Colors.blue,
        backgroundColor: Colors.white,
      ),
      gravity: ToastGravity.BOTTOM,
      toastDuration: duration,
    );
  }

  /// Đảm bảo FToast đã được khởi tạo
  void _ensureFToastInitialized(BuildContext context) {
    _fToast ??= FToast()..init(context);
  }

  /// Build custom toast widget với animation
  Widget _buildToast({
    required BuildContext context,
    required String message,
    String? details,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDarkMode ? Colors.grey.shade800 : backgroundColor;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final detailsColor = isDarkMode ? Colors.white70 : Colors.black54;
    
    return Card(
      elevation: 6.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 28,
            ).animate().scale(
              duration: 400.ms,
              curve: Curves.elasticOut,
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.0, 1.0),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (details != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      details,
                      style: TextStyle(
                        color: detailsColor,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms)
      .slideY(
        begin: 0.5, 
        end: 0, 
        duration: 300.ms, 
        curve: Curves.easeOutQuad
      );
  }
} 