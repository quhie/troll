import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/sound_model.dart';
import '../viewmodels/sound_viewmodel.dart';
import '../widgets/sound_card.dart';

/// Widget hiển thị danh sách kết quả tìm kiếm
class SearchResults extends StatelessWidget {
  final List<SoundModel> results;
  final String query;
  final Function() onRefresh;

  const SearchResults({
    Key? key,
    required this.results,
    required this.query,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SoundViewModel>(context);
    final currentPlayingSoundId = viewModel.currentPlayingSoundId;
    
    return RefreshIndicator(
      onRefresh: () async {
        await onRefresh();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: results.length + 1, // +1 for header
        itemBuilder: (context, index) {
          // Header
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 4),
              child: Text(
                'results_for'.tr() + ' "$query" (${results.length})',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ).animate().fade(duration: 300.ms);
          }
          
          final resultIndex = index - 1;
          final sound = results[resultIndex];
          final isPlaying = currentPlayingSoundId == sound.id;
          
          // Kiểm tra trạng thái yêu thích thực tế
          final isFavorite = viewModel.favoriteSounds.any((s) => s.id == sound.id);
          final soundWithUpdatedFavorite = sound.copyWith(isFavorite: isFavorite);
          
          // Improved sound card with animation
          return SoundCard(
            sound: soundWithUpdatedFavorite,
            isPlaying: isPlaying,
            onPlay: () => _playSound(context, soundWithUpdatedFavorite),
            onDownload: () => _downloadSound(context, soundWithUpdatedFavorite),
            onFavorite: () => _toggleFavorite(context, soundWithUpdatedFavorite),
            showCategory: true,
            showDownloadButton: true, // Hiển thị nút tải về
          ).animate().fade(
            duration: 300.ms,
            delay: (50 * resultIndex).ms,
          ).moveY(
            begin: 20, 
            end: 0,
            duration: 300.ms, 
            delay: (50 * resultIndex).ms,
            curve: Curves.easeOutQuad,
          );
        },
      ),
    );
  }
  
  // Phát âm thanh được chọn
  void _playSound(BuildContext context, SoundModel sound) {
    final viewModel = Provider.of<SoundViewModel>(context, listen: false);
    final theme = Theme.of(context);
    
    // Hiển thị dialog loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Dialog(
          backgroundColor: theme.cardColor,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'play_preparing'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  sound.name,
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
            ).animate().fade(duration: 300.ms),
          ),
        ),
      ),
    );
    
    // Phát âm thanh
    viewModel.playSound(sound).then((success) {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      
      if (success) {
        _showSuccessSnackbar(
          context,
          'play_now'.tr() + ': ${sound.name}',
          action: SnackBarAction(
            label: 'stop'.tr(),
            textColor: Colors.white,
            onPressed: () {
              viewModel.stopSound();
            },
          ),
        );
      } else {
        _showErrorSnackbar(context, 'play_error'.tr());
      }
    }).catchError((error) {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      _showErrorSnackbar(context, 'play_error'.tr());
    });
  }
  
  // Tải xuống âm thanh
  void _downloadSound(BuildContext context, SoundModel sound) async {
    final viewModel = Provider.of<SoundViewModel>(context, listen: false);
    
    try {
      await viewModel.downloadSound(sound);
      _showSuccessSnackbar(context, 'download_success'.tr());
    } catch (e) {
      _showErrorSnackbar(context, 'download_failed'.tr());
    }
  }
  
  // Thêm/xóa yêu thích
  void _toggleFavorite(BuildContext context, SoundModel sound) {
    final viewModel = Provider.of<SoundViewModel>(context, listen: false);
    viewModel.toggleFavorite(sound);
    
    final isFavorite = viewModel.favoriteSounds.any((s) => s.id == sound.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isFavorite ? 'favorite_added'.tr() : 'favorite_removed'.tr()
        ),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isFavorite ? Colors.pink : Colors.grey,
      ),
    );
  }
  
  // Hiển thị thông báo lỗi
  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.red.shade700,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  // Hiển thị thông báo thành công
  void _showSuccessSnackbar(BuildContext context, String message, {SnackBarAction? action}) {
    final theme = Theme.of(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.colorScheme.primary,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
        action: action,
      ),
    );
  }
} 