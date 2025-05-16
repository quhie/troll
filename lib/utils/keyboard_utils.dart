import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Lớp tiện ích để quản lý bàn phím
class KeyboardUtils {
  static const String _logTag = 'KeyboardUtils';

  /// Ẩn bàn phím
  static void hideKeyboard(FocusNode? focusNode) {
    
    if (focusNode != null && focusNode.hasFocus) {
      focusNode.unfocus();
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    }
  }
  
  /// Hiển thị bàn phím với focus nút
  static void showKeyboardWithFocus(FocusNode? focusNode) {
    
    if (focusNode == null) {
      return;
    }
    
    if (!focusNode.hasFocus) {
      focusNode.requestFocus();
      
      // Hiển thị bàn phím ngay lập tức
      Future.microtask(() {
        SystemChannels.textInput.invokeMethod('TextInput.show');
      });
      
      // Đảm bảo bàn phím hiện sau một khoảng thời gian
      Future.delayed(const Duration(milliseconds: 100), () {
        if (focusNode.hasFocus) {
          SystemChannels.textInput.invokeMethod('TextInput.show');
        }
      });
    } else {
      SystemChannels.textInput.invokeMethod('TextInput.show');
    }
  }
} 