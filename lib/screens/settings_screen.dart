import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../services/preferences_service.dart';
import '../services/localization_service.dart';
import '../utils/app_theme.dart';
import '../utils/haptic_feedback_helper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/custom_app_bar.dart';

/// Modern settings screen with clean UI
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // Set transparent status bar for better UI integration
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (context) => SettingsViewModel(
            Provider.of<PreferencesService>(context, listen: false),
          ),
      child: const _SettingsContent(),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent();

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          appBar: CustomAppBar(
            title: 'settings'.tr(),
            centerTitle: true,
            showBackButton: false,
            elevation: 2,
            actions: [_buildHelpButton(context)],
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildGeneralSection(context, viewModel),
                  _buildLanguageSection(context),
                  _buildSoundSection(context, viewModel),
                  _buildAboutSection(context, viewModel),

                  // Reset settings button
                  const SizedBox(height: 32),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed:
                          () => _showResetConfirmation(context, viewModel),
                      icon: const Icon(Icons.restore),
                      label: Text('reset_settings'.tr()),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build the general settings section
  Widget _buildGeneralSection(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    return _buildSettingsSection(
      context: context,
      title: 'general'.tr(),
      icon: Icons.settings,
      color: Colors.blue,
      children: [
        _buildSwitchTile(
          context: context,
          title: 'dark_mode'.tr(),
          subtitle: 'dark_mode_desc'.tr(),
          value: viewModel.darkModeEnabled,
          onChanged: (value) {
            HapticFeedbackHelper.selectionClick();
            viewModel.toggleDarkMode();
          },
          icon: Icons.dark_mode,
          iconColor: Colors.indigo,
        ),

        _buildSwitchTile(
          context: context,
          title: 'haptic_feedback'.tr(),
          subtitle: 'haptic_feedback_desc'.tr(),
          value: viewModel.hapticFeedbackEnabled,
          onChanged: (value) {
            HapticFeedbackHelper.selectionClick();
            viewModel.toggleHapticFeedback();
          },
          icon: Icons.vibration,
          iconColor: Colors.deepPurple,
        ),

        _buildSwitchTile(
          context: context,
          title: 'vibrate_on_tap'.tr(),
          subtitle: 'vibrate_on_tap_desc'.tr(),
          value: viewModel.vibrateOnTapEnabled,
          onChanged: (value) {
            HapticFeedbackHelper.selectionClick();
            viewModel.toggleVibrateOnTap();
          },
          icon: Icons.touch_app,
          iconColor: Colors.teal,
        ),
      ],
    );
  }

  /// Build the language settings section
  Widget _buildLanguageSection(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    final languages = localizationService.availableLanguages;
    final currentLocale = context.locale;

    return _buildSettingsSection(
      context: context,
      title: 'language'.tr(),
      icon: Icons.language,
      color: Colors.purple,
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.2), width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children:
                  languages.map((language) {
                    final Locale locale = language['locale'];
                    final bool isSelected =
                        locale.languageCode == currentLocale.languageCode;

                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            locale.languageCode.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  isSelected
                                      ? Theme.of(context).primaryColor
                                      : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      title: Text(language['name']),
                      trailing:
                          isSelected
                              ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                              )
                              : null,
                      onTap: () {
                        HapticFeedbackHelper.selectionClick();
                        localizationService.changeLocale(context, locale);
                      },
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Build the sound settings section
  Widget _buildSoundSection(BuildContext context, SettingsViewModel viewModel) {
    return _buildSettingsSection(
      context: context,
      title: 'sound'.tr(),
      icon: Icons.volume_up,
      color: Colors.orange,
      children: [
        _buildSwitchTile(
          context: context,
          title: 'ui_sound_effects'.tr(),
          subtitle: 'ui_sound_effects_desc'.tr(),
          value: viewModel.soundEffectsEnabled,
          onChanged: (value) {
            HapticFeedbackHelper.selectionClick();
            viewModel.toggleSoundEffects();
          },
          icon: Icons.music_note,
          iconColor: Colors.amber,
        ),

        _buildSwitchTile(
          context: context,
          title: 'high_quality_audio'.tr(),
          subtitle: 'high_quality_audio_desc'.tr(),
          value: viewModel.highQualityAudio,
          onChanged: (value) {
            HapticFeedbackHelper.selectionClick();
            viewModel.toggleHighQualityAudio();
          },
          icon: Icons.high_quality,
          iconColor: Colors.deepOrange,
        ),
      ],
    );
  }

  /// Build the about section
  Widget _buildAboutSection(BuildContext context, SettingsViewModel viewModel) {
    return _buildSettingsSection(
      context: context,
      title: 'about'.tr(),
      icon: Icons.info_outline,
      color: Colors.green,
      children: [
        _buildMenuTile(
          context: context,
          title: 'rate_app'.tr(),
          subtitle: 'rate_app_desc'.tr(),
          icon: Icons.star_rate,
          iconColor: Colors.amber,
          onTap: () {
            // Implement app rating action here
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Rating feature would go here'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),

        _buildMenuTile(
          context: context,
          title: 'send_feedback'.tr(),
          subtitle: 'send_feedback_desc'.tr(),
          icon: Icons.feedback,
          iconColor: Colors.lightBlue,
          onTap: () async {
            // Launch email app for feedback
            final Uri emailUri = Uri(
              scheme: 'mailto',
              path: 'feedback@example.com',
              query: 'subject=Troll Sounds Feedback',
            );

            try {
              await launchUrl(emailUri);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Could not open email app'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
          },
        ),

        _buildMenuTile(
          context: context,
          title: 'privacy_policy'.tr(),
          subtitle: 'privacy_policy_desc'.tr(),
          icon: Icons.privacy_tip,
          iconColor: Colors.teal,
          onTap: () {
            // Implement privacy policy action here
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Privacy policy would go here'),
                duration: Duration(seconds: 2),
              ),
            );
          },
        ),

        _buildVersionTile(context),
      ],
    );
  }

  /// Build a switch settings tile
  Widget _buildSwitchTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
    Color? iconColor,
  }) {
    final effectiveIconColor = iconColor ?? Theme.of(context).primaryColor;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: effectiveIconColor.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: effectiveIconColor.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: effectiveIconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: effectiveIconColor,
      ),
    );
  }

  /// Build a menu settings tile
  Widget _buildMenuTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    final effectiveIconColor = iconColor ?? Theme.of(context).primaryColor;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: effectiveIconColor.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: effectiveIconColor.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: effectiveIconColor),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: Icon(
        Icons.chevron_right,
        color: effectiveIconColor.withOpacity(0.7),
      ),
      onTap: () {
        HapticFeedbackHelper.selectionClick();
        onTap();
      },
    );
  }

  /// Build a version info tile
  Widget _buildVersionTile(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.info, color: Colors.grey),
      ),
      title: Text(
        'version'.tr(),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: const Text('1.0.1'),
    );
  }

  /// Build a section with a title and children
  Widget _buildSettingsSection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
    Color? color,
  }) {
    final effectiveColor = color ?? Theme.of(context).primaryColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 4),
          child: Row(
            children: [
              Icon(icon, size: 20, color: effectiveColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: effectiveColor,
                ),
              ),
            ],
          ),
        ),

        // Card containing settings
        Card(
          elevation: 3,
          shadowColor: effectiveColor.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms);
  }

  /// Show confirmation dialog for resetting settings
  void _showResetConfirmation(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('reset_confirm_title'.tr()),
            content: Text('reset_confirm_message'.tr()),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('cancel'.tr().toUpperCase()),
              ),
              TextButton(
                onPressed: () {
                  viewModel.resetSettings();
                  Navigator.of(context).pop();

                  // Show confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('settings_reset'.tr()),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('reset'.tr().toUpperCase()),
              ),
            ],
          ),
    );
  }

  /// Builds the help button for the app bar
  Widget _buildHelpButton(BuildContext context) {
    return IconButton(
          icon: Icon(
            Icons.help_outline,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => _showHelpDialog(context),
          tooltip: 'help'.tr(),
        )
        .animate()
        .fade(duration: 300.ms)
        .scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: 300.ms,
        );
  }

  /// Shows the help dialog with information about settings
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('settings'.tr() + ' ' + 'help'.tr()),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHelpSection(
                    context,
                    'dark_mode'.tr(),
                    'dark_mode_desc'.tr(),
                    Icons.dark_mode,
                  ),
                  const SizedBox(height: 16),
                  _buildHelpSection(
                    context,
                    'haptic_feedback'.tr(),
                    'haptic_feedback_desc'.tr(),
                    Icons.vibration,
                  ),
                  const SizedBox(height: 16),
                  _buildHelpSection(
                    context,
                    'reset_settings'.tr(),
                    'reset_confirm_message'.tr(),
                    Icons.restore,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('ok'.tr()),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
    );
  }

  /// Builds a section for the help dialog
  Widget _buildHelpSection(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
