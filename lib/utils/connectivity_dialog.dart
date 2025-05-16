import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/connectivity_service.dart';

/// Hiển thị dialog thông báo khi mất kết nối internet
class ConnectivityDialog {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  /// Hiển thị thông báo mất kết nối
  static void showNoConnectionMessage(BuildContext context) {
    if (_isVisible) return;
    
    _isVisible = true;

    // Tạo overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) => _buildNoConnectionWidget(context),
    );

    // Thêm vào overlay
    Overlay.of(context).insert(_overlayEntry!);
  }

  /// Ẩn thông báo mất kết nối
  static void hideNoConnectionMessage() {
    if (!_isVisible) return;
    
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isVisible = false;
  }

  /// Xây dựng widget hiển thị thông báo mất kết nối
  static Widget _buildNoConnectionWidget(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          offset: const Offset(0, 0),
          curve: Curves.easeOut,
          child: Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            color: Colors.red,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'no_internet_connection'.tr(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      // Kiểm tra lại kết nối khi người dùng nhấn nút làm mới
                      await ConnectivityService().checkRealConnectivity();
                      
                      // Nếu đã có kết nối, ẩn thông báo
                      if (ConnectivityService().isConnected) {
                        hideNoConnectionMessage();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.refresh,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'refresh'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 