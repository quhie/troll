import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/preferences_service.dart';
import '../screens/app_container.dart';
import 'package:easy_localization/easy_localization.dart';
import 'dart:developer' as developer;

/// Onboarding screen shown to first-time users - optimized for performance
class OnboardingView extends StatefulWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  // Map dịch thuật trực tiếp cho tiếng Anh
  final Map<String, String> _enTexts = {
    'welcome_title': 'Welcome to Troll Sounds',
    'welcome_desc': 'Your ultimate prank sound effects app, packed with fun sounds to surprise your friends!',
    'categories_title': 'Sound Categories',
    'categories_desc': 'Explore sounds organized in categories: Phone, Game, Horror, Meme and more!',
    'favorites_title': 'Save Favorites',
    'favorites_desc': 'Long press any sound to add it to your favorites for quick access.',
    'ready_title': 'Ready to Troll?',
    'ready_desc': 'Time to have fun and surprise everyone with amazing sound effects!',
    'skip': 'Skip',
  };

  // Map dịch thuật trực tiếp cho tiếng Việt
  final Map<String, String> _viTexts = {
    'welcome_title': 'Chào mừng đến với Âm Thanh Troll',
    'welcome_desc': 'Ứng dụng âm thanh dùng để chọc ghẹo bạn bè với các hiệu ứng âm thanh vui nhộn!',
    'categories_title': 'Danh mục âm thanh',
    'categories_desc': 'Khám phá âm thanh được tổ chức theo danh mục: Điện thoại, Game, Kinh dị, Meme và nhiều hơn nữa!',
    'favorites_title': 'Lưu âm thanh yêu thích',
    'favorites_desc': 'Nhấn giữ âm thanh bất kỳ để thêm vào danh sách yêu thích để truy cập nhanh.',
    'ready_title': 'Sẵn sàng troll chưa?',
    'ready_desc': 'Đã đến lúc vui vẻ và tạo bất ngờ cho mọi người với các hiệu ứng âm thanh thú vị!',
    'skip': 'Bỏ qua',
  };

  // Hàm lấy text theo ngôn ngữ hiện tại
  String getLocalizedText(String key) {
    final locale = context.locale.languageCode;
    if (locale == 'vi') {
      return _viTexts[key] ?? key;
    }
    return _enTexts[key] ?? key;
  }

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'welcome_title',
      description: 'welcome_desc',
      icon: Icons.emoji_emotions,
      color: Colors.blue.shade700,
    ),
    OnboardingPage(
      title: 'categories_title',
      description: 'categories_desc',
      icon: Icons.category,
      color: Colors.green.shade700,
    ),
    OnboardingPage(
      title: 'favorites_title',
      description: 'favorites_desc',
      icon: Icons.favorite,
      color: Colors.pink.shade700,
    ),
    OnboardingPage(
      title: 'ready_title',
      description: 'ready_desc',
      icon: Icons.celebration,
      color: Colors.orange.shade700,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Log ngôn ngữ hiện tại khi khởi tạo màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      developer.log('Current locale: ${context.locale}');
      developer.log('Supported locales: ${context.supportedLocales}');
      developer.log('Welcome title raw: welcome_title');
      developer.log('Welcome title localized: ${getLocalizedText('welcome_title')}');
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _completeOnboarding() {
    Provider.of<PreferencesService>(context, listen: false)
        .setOnboardingCompleted();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AppContainer()),
    );
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  _pages[_currentPage].color,
                  _pages[_currentPage].color.withOpacity(0.7),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      getLocalizedText('skip'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // Page content
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return _buildPage(_pages[index]);
                    },
                  ),
                ),

                // Bottom navigation
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page indicator
                      Row(
                        children: List.generate(
                          _totalPages,
                          (index) => Container(
                            margin: const EdgeInsets.only(right: 6),
                            height: 8,
                            width: index == _currentPage ? 24 : 8,
                            decoration: BoxDecoration(
                              color: index == _currentPage
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),

                      // Next button
                      ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _pages[_currentPage].color,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          shape: const CircleBorder(),
                        ),
                        child: Icon(
                          _currentPage < _totalPages - 1
                              ? Icons.arrow_forward
                              : Icons.check,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    // Log quá trình dịch trong mỗi lần build page
    developer.log('Building page with title key: ${page.title}');
    developer.log('Title translated directly: ${getLocalizedText(page.title)}');
    developer.log('Description key: ${page.description}');
    developer.log('Description translated directly: ${getLocalizedText(page.description)}');
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white,
            child: Icon(
              page.icon,
              size: 45,
              color: page.color,
            ),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            getLocalizedText(page.title),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Description
          Container(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              getLocalizedText(page.description),
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                height: 1.4,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple data class for onboarding pages
class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
