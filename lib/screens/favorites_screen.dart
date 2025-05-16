import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../models/sound_model.dart';
import '../models/sound_category.dart';
import '../services/sound_service.dart';
import '../widgets/sound_card.dart';
import '../widgets/category_header.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_tooltip.dart';

/// Favorites screen that displays saved favorite sounds
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with WidgetsBindingObserver {
  String? _currentPlayingSoundId;
  StreamSubscription? _audioStreamSubscription;

  @override
  void initState() {
    super.initState();

    // Register observer for app lifecycle events
    WidgetsBinding.instance.addObserver(this);

    // Listen for audio state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final soundService = Provider.of<SoundService>(context, listen: false);
        _audioStreamSubscription = soundService.audioStateStream.listen((
          state,
        ) {
          if (mounted) {
            setState(() {
              _currentPlayingSoundId = state.currentSoundId;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    // Stop any playing sound when navigating away
    _stopCurrentSound();

    // Cancel subscription to prevent memory leaks
    _audioStreamSubscription?.cancel();

    // Remove observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Stop sound when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _stopCurrentSound();
    }
  }

  /// Stop the currently playing sound if any
  void _stopCurrentSound() {
    if (_currentPlayingSoundId != null) {
      final soundService = Provider.of<SoundService>(context, listen: false);
      soundService.stopSound();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'manage_favorites'.tr(),
        centerTitle: true,
        showBackButton: true,
        actions: [_buildHelpButton(context)],
      ),
      body: Consumer<SoundService>(
        builder: (context, soundService, _) {
          // Get favorite sounds grouped by category
          final favoritesByCategory = _getFavoritesByCategory(soundService);
          _currentPlayingSoundId = soundService.currentPlayingSoundId;

          // Check if there are any favorites
          if (favoritesByCategory.isEmpty) {
            return _buildEmptyState();
          }

          return _buildFavoritesList(favoritesByCategory, soundService);
        },
      ),
    );
  }

  /// Group favorites by their category
  Map<CategoryType, List<SoundModel>> _getFavoritesByCategory(
    SoundService soundService,
  ) {
    final favorites = soundService.favoriteSounds;
    final Map<CategoryType, List<SoundModel>> result = {};

    for (final sound in favorites) {
      result.putIfAbsent(sound.category, () => []).add(sound);
    }

    return result;
  }

  /// Builds the empty state for when there are no favorites
  Widget _buildEmptyState() {
    return Center(
      child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 84,
                color: Colors.grey.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                'no_favorites'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'add_to_favorites_hint'.tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),
              _buildReturnButton(),
            ],
          )
          .animate()
          .fade(duration: 600.ms)
          .scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
            duration: 600.ms,
          ),
    );
  }

  /// Builds a button to return to the home page
  Widget _buildReturnButton() {
    return ElevatedButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          label: Text('back_to_home'.tr()),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        )
        .animate()
        .fade(delay: 200.ms, duration: 400.ms)
        .moveY(begin: 20, end: 0, delay: 200.ms, duration: 400.ms);
  }

  /// Builds the list of favorites grouped by category
  Widget _buildFavoritesList(
    Map<CategoryType, List<SoundModel>> favoritesByCategory,
    SoundService soundService,
  ) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        const SliverPadding(padding: EdgeInsets.only(top: 16)),

        // For each category that has favorites
        ...favoritesByCategory.entries.map((entry) {
          final category = entry.key;
          final sounds = entry.value;

          if (sounds.isEmpty)
            return const SliverToBoxAdapter(child: SizedBox.shrink());

          return SliverMainAxisGroup(
            slivers: [
              // Category header
              SliverToBoxAdapter(
                child: CategoryHeader(
                  title: category.name,
                  icon: category.icon,
                  color: category.color,
                  itemCount: sounds.length,
                ),
              ),

              // Sounds grid for this category
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final sound = sounds[index];
                    final isPlaying = sound.id == _currentPlayingSoundId;

                    return SoundCard(
                          sound: sound,
                          isPlaying: isPlaying,
                          showCategory: false,
                          onLongPress: () => soundService.toggleFavorite(sound),
                        )
                        .animate()
                        .fade(duration: 300.ms, delay: (50 * index).ms)
                        .moveY(
                          begin: 20,
                          end: 0,
                          duration: 300.ms,
                          delay: (50 * index).ms,
                          curve: Curves.easeOutQuad,
                        );
                  }, childCount: sounds.length),
                ),
              ),
            ],
          );
        }).toList(),

        // Bottom padding for better scrolling experience
        const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
      ],
    );
  }

  /// Builds the help button for the app bar
  Widget _buildHelpButton(BuildContext context) {
    return CustomTooltip(
      message: 'help'.tr(),
      child: IconButton(
        icon: const Icon(Icons.info_outline),
        onPressed: () {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text('manage_favorites'.tr()),
                  content: const SingleChildScrollView(
                    child: ListBody(
                      children: [
                        Text('• Nhấn vào âm thanh để phát'),
                        SizedBox(height: 8),
                        Text('• Giữ lâu để xóa khỏi danh sách yêu thích'),
                        SizedBox(height: 8),
                        Text(
                          '• Các âm thanh được phân loại theo danh mục để dễ tìm kiếm',
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
                ),
          );
        },
      ),
    );
  }
}
