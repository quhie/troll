import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/feature.dart';
import '../../utils/app_theme.dart';
import '../../utils/haptic_feedback_helper.dart';
import '../../screens/settings_screen.dart';

/// Factory class for creating tools and utilities features group
class ToolsGroup {
  /// Create a feature group containing all tool and utility features
  static FeatureGroup create(BuildContext context) {
    return FeatureGroup(
      title: 'Tools & Settings',
      icon: Icons.build,
      color: Colors.grey.shade800,
      features: [
        // Settings
        Feature(
          name: 'Settings',
          icon: Icons.settings,
          onTap: () {
            HapticFeedbackHelper.selectionFeedback();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          description: 'Customize app appearance and behavior',
          color: Colors.grey.shade700,
        ),

        // Help & Support
        Feature(
          name: 'Help & Support',
          icon: Icons.help_outline,
          onTap: () {
            HapticFeedbackHelper.selectionFeedback();
            _showHelpDialog(context);
          },
          description: 'Get assistance with using the app',
        ),

        // Rate App
        Feature(
          name: 'Rate App',
          icon: Icons.star_border,
          onTap: () {
            HapticFeedbackHelper.successFeedback();
            _launchAppStore();
          },
          description: 'Rate us on the App Store',
          tag: 'Support Us',
          color: Colors.amber,
        ),

        // About
        Feature(
          name: 'About',
          icon: Icons.info_outline,
          onTap: () {
            HapticFeedbackHelper.selectionFeedback();
            _showAboutDialog(context);
          },
          description: 'Information about this app',
        ),

        // Share App
        Feature(
          name: 'Share App',
          icon: Icons.share,
          onTap: () {
            HapticFeedbackHelper.selectionFeedback();
            _shareApp();
          },
          description: 'Share with friends',
          color: Colors.blue,
        ),
      ],
    );
  }

  /// Show help and support dialog
  static void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Help & Support'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How to use TrollPro Max:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Tap any sound or prank to activate it'),
                  const Text('• Save favorites for quick access'),
                  const Text('• Customize settings to your preference'),
                  const SizedBox(height: 16),
                  const Text(
                    'Having issues?',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.email_outlined),
                    label: const Text('Contact Support'),
                    onPressed: () {
                      _launchEmail('support@trollpromax.com');
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  /// Show about dialog
  static void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AboutDialog(
            applicationName: 'TrollPro Max',
            applicationVersion: '1.0.0',
            applicationIcon: Image.asset(
              'assets/images/app_icon.png',
              width: 48,
              height: 48,
            ),
            applicationLegalese: '© 2023 TrollPro Max Inc.',
            children: [
              const SizedBox(height: 16),
              const Text(
                'TrollPro Max is the ultimate prank app featuring hilarious sounds, visual effects, and harmless tricks to play on friends and family.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Made with ❤️ by TrollPro Max Team',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
    );
  }

  /// Launch app store
  static Future<void> _launchAppStore() async {
    const String appStoreUrl = 'https://apps.apple.com/app/trollsounds';
    final Uri url = Uri.parse(appStoreUrl);

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      // Could not launch URL
    }
  }

  /// Launch email app
  static Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Troll Sounds Support Request',
        'body': 'App version: 1.0.0\nDevice: \nIssue: ',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      // Could not launch email
    }
  }

  /// Share app with friends
  static Future<void> _shareApp() async {
    const String shareText =
        'Check out Troll Sounds - the ultimate prank app! Get it now at https://apps.apple.com/app/trollsounds';

    // This would normally use the share package
    // For now, just copy to clipboard
    await Clipboard.setData(const ClipboardData(text: shareText));

    // Share text copied to clipboard
  }
}
