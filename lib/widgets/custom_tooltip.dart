import 'package:flutter/material.dart';

/// CustomTooltip widget để thay thế Tooltip mặc định
/// Giải quyết vấn đề "TooltipState is a SingleTickerProviderStateMixin but multiple tickers were created"
class CustomTooltip extends StatelessWidget {
  final Widget child;
  final String message;
  final bool preferBelow;
  
  const CustomTooltip({
    Key? key,
    required this.child,
    required this.message,
    this.preferBelow = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Nếu message rỗng, chỉ trả về child mà không thêm tooltip
    if (message.isEmpty) {
      return child;
    }
    
    return Tooltip(
      message: message,
      preferBelow: preferBelow,
      child: child,
    );
  }
} 