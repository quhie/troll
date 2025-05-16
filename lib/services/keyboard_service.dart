// import 'package:flutter/services.dart';
// import 'package:flutter/material.dart';

// /// Dịch vụ quản lý bàn phím - đã được tối ưu hóa
// /// Chỉ cung cấp các phương thức cần thiết và an toàn
// class KeyboardService {
//   /// Ẩn bàn phím - dùng khi cần ẩn bàn phím
//   static void hideKeyboard() {
//     SystemChannels.textInput.invokeMethod('TextInput.hide');
//   }
  
//   /// Ẩn bàn phím bằng cách xoá focus
//   static void hideKeyboardWithContext(BuildContext context) {
//     if (context.mounted) {
//       FocusScope.of(context).unfocus();
//       hideKeyboard();
//     }
//   }
  
//   /// Kiểm tra xem bàn phím có đang hiển thị không
//   static bool isKeyboardVisible(BuildContext context) {
//     if (!context.mounted) return false;
//     final viewInsets = MediaQuery.of(context).viewInsets;
//     return viewInsets.bottom > 0;
//   }
  
//   /// Tạo widget để khi nhấn vào nơi khác sẽ tắt bàn phím
//   static Widget keyboardDismisser({
//     required Widget child,
//     required BuildContext context,
//   }) {
//     return GestureDetector(
//       onTap: () => hideKeyboardWithContext(context),
//       behavior: HitTestBehavior.translucent,
//       child: child,
//     );
//   }
// } 