import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../services/preferences_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool showBackButton;
  final Color? backgroundColor;
  final double elevation;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final bool showThemeToggle;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.centerTitle = false,
    this.showBackButton = false,
    this.backgroundColor,
    this.elevation = 2,
    this.leading,
    this.bottom,
    this.showThemeToggle = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        backgroundColor ??
        theme.appBarTheme.backgroundColor ??
        theme.colorScheme.surface;

    // Combined actions list that includes theme toggle if requested
    final List<Widget> combinedActions = [
      if (showThemeToggle)
        Consumer<PreferencesService>(
          builder: (context, preferences, _) {
            return IconButton(
                  icon: Icon(
                    preferences.darkModeEnabled
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () {
                    final newValue = !preferences.darkModeEnabled;
                    preferences.setDarkMode(newValue);
                  },
                  tooltip: 'Toggle Theme',
                )
                .animate()
                .fade(duration: 300.ms)
                .scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: 300.ms,
                );
          },
        ),
      if (actions != null) ...actions!,
    ];

    return AppBar(
      title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: 0.2,
              color: theme.colorScheme.onSurface,
              fontFamily: 'Roboto',
            ),
          )
          .animate()
          .fadeIn(duration: 400.ms)
          .moveY(begin: 10, end: 0, duration: 400.ms),
      centerTitle: centerTitle,
      backgroundColor: bgColor,
      elevation: elevation,
      shadowColor: isDark ? Colors.black38 : Colors.black12,
      automaticallyImplyLeading: showBackButton,
      leading: leading ?? (showBackButton ? IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new,
          size: 20,
          color: theme.colorScheme.onSurface,
        ),
        onPressed: () => Navigator.of(context).pop(),
        tooltip: 'Back',
      ) : null),
      actions: combinedActions,
      bottom: bottom,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
      titleSpacing: showBackButton ? 0 : 16,
      toolbarHeight: 56,
      iconTheme: IconThemeData(
        size: 22,
        color: theme.colorScheme.onSurface,
      ),
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 18,
        letterSpacing: 0.2,
        color: theme.colorScheme.onSurface,
        fontFamily: 'Roboto',
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    bottom != null
        ? kToolbarHeight + bottom!.preferredSize.height
        : kToolbarHeight,
  );
}
