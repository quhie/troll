import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Widget tùy chỉnh cho trường tìm kiếm với thiết kế hiện đại
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final Function(String) onSubmitted;
  final VoidCallback? onClear;
  final VoidCallback? onTap;
  final bool autofocus;
  final bool disabled;
  final String? hint;

  const SearchField({
    Key? key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    this.onClear,
    this.onTap,
    this.autofocus = false,
    this.disabled = false,
    this.hint,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        enabled: !disabled,
        decoration: InputDecoration(
          hintText: hint ?? 'search_hint'.tr(),
          hintStyle: TextStyle(
            color: disabled ? theme.disabledColor : theme.hintColor,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: disabled ? theme.disabledColor : theme.colorScheme.primary,
          ),
          suffixIcon: controller.text.isNotEmpty && !disabled
            ? IconButton(
                icon: const Icon(Icons.clear_rounded),
                onPressed: () {
                  if (onClear != null) {
                    onClear!();
                  } else {
                    controller.clear();
                    onChanged('');
                  }
                },
                splashRadius: 20,
              )
            : null,
          filled: true,
          fillColor: disabled ? theme.disabledColor.withOpacity(0.1) : theme.cardColor,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: theme.colorScheme.primary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: theme.disabledColor.withOpacity(0.1),
              width: 1.0,
            ),
          ),
        ),
        textInputAction: TextInputAction.search,
        onSubmitted: (text) {
          onSubmitted(text);
        },
        onChanged: (text) {
          onChanged(text);
        },
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
        },
        keyboardType: TextInputType.text,
        style: TextStyle(
          fontSize: 16,
          color: disabled ? theme.disabledColor : theme.textTheme.bodyLarge?.color,
        ),
      ),
    );
  }
} 