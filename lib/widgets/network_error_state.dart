import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/connectivity_service.dart';

/// A widget that displays when internet connectivity is lost
class NetworkErrorState extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;
  final String? customSubMessage;
  final bool showRetryButton;

  const NetworkErrorState({
    Key? key,
    this.onRetry,
    this.customMessage,
    this.customSubMessage,
    this.showRetryButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Network icon with animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: const Duration(seconds: 1),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Icon(
                Icons.wifi_off_rounded,
                size: 72,
                color: isDark ? Colors.white38 : Colors.grey[400],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Main message
            Text(
              customMessage ?? 'no_internet_connection'.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Sub message
            Text(
              customSubMessage ?? 'check_connection'.tr(),
              style: TextStyle(
                fontSize: 15,
                color: isDark ? Colors.white54 : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            if (showRetryButton) ...[
              const SizedBox(height: 40),
              
              // Check connection button
              ElevatedButton.icon(
                onPressed: () async {
                  // Show connecting indicator
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('connection_check'.tr()),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  
                  // Try to check connectivity
                  await ConnectivityService().checkRealConnectivity();
                  
                  // If there's a custom retry callback, call it
                  if (onRetry != null) {
                    onRetry!();
                  }
                  
                  // Check if connection is restored
                  if (ConnectivityService().isConnected && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('connection_restored'.tr()),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.refresh),
                label: Text('retry'.tr()),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  backgroundColor: isDark ? Colors.blueGrey[700] : Colors.blue,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 