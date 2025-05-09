import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../widgets/menu_grid_card.dart';
import '../utils/constants.dart';
import '../utils/app_theme.dart';
import '../views/sound_flash_view.dart';
import '../views/fake_error_view.dart';
import '../views/unclickable_button_view.dart';
import '../views/terminal_emulator_view.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../models/sound_model.dart';

class MainMenuView extends StatefulWidget {
  const MainMenuView({Key? key}) : super(key: key);

  @override
  State<MainMenuView> createState() => _MainMenuViewState();
}

class _MainMenuViewState extends State<MainMenuView> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Random _random = Random();
  final GlobalKey<_AnimatedPatternBackgroundState> _animatedPatternBackgroundKey = GlobalKey<_AnimatedPatternBackgroundState>();
  
  @override
  void initState() {
    super.initState();
    // Khởi tạo animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Preload danh sách âm thanh để tránh lặp lại việc lấy danh sách
    _soundsList = Constants.getSoundsList();
    
    // Thêm future delayed để bắt đầu các animation sau khi build hoàn tất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
      
      // Di chuyển precacheImage vào đây để tránh sử dụng context trong initState
      precacheImage(const AssetImage('assets/images/splash_logo.png'), context);
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Hoặc chúng ta có thể đặt precacheImage ở đây, đây là nơi an toàn để truy cập context
    // và được gọi lại khi dependencies thay đổi
  }
  
  List<SoundModel> _soundsList = [];
  late final AnimationController _controller;
  
  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          Constants.appName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 28,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Color(0x66000000),
                offset: Offset(0, 3),
                blurRadius: 5,
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              themeViewModel.toggleTheme();
            },
          ),
        ],
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          // Quản lý performance khi scroll
          if (notification is ScrollUpdateNotification && notification.dragDetails != null) {
            if (_animatedPatternBackgroundKey.currentState != null) {
              _animatedPatternBackgroundKey.currentState!._pauseAnimation();
            }
          } else if (notification is ScrollEndNotification) {
            Future.delayed(const Duration(milliseconds: 300), () {
              if (_animatedPatternBackgroundKey.currentState != null) {
                _animatedPatternBackgroundKey.currentState!._resumeAnimation();
              }
            });
          }
          return false;
        },
        child: Stack(
          children: [
            // Background with animated gradient - sử dụng const để tránh rebuild
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    isDark ? AppTheme.darkPrimaryColor : AppTheme.primaryColor,
                    isDark ? AppTheme.darkBackgroundColor : Color.lerp(AppTheme.backgroundColor, AppTheme.accentColor, 0.05)!,
                  ],
                ),
              ),
            ),
            
            // Animated background pattern
            Opacity(
              opacity: 0.07,
              child: AnimatedPatternBackground(
                key: _animatedPatternBackgroundKey,
                isDark: isDark
              ),
            ),
            
            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title banner - sử dụng const cho các widget tĩnh
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            isDark ? AppTheme.darkHighlightColor : AppTheme.highlightColor,
                            isDark ? AppTheme.darkHighlightColor.withOpacity(0.7) : AppTheme.highlightColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: (isDark ? AppTheme.darkHighlightColor : AppTheme.highlightColor).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.emoji_emotions,
                            color: Colors.white,
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Choose your troll:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Color(0x4D000000),
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Grid of sound items - tối ưu hóa GridView.builder
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          // Khi đang vuốt, tắt các animation không cần thiết
                          if (notification is ScrollUpdateNotification) {
                            if (notification.dragDetails != null) {
                              _controller.stop();
                            } else if (notification is ScrollEndNotification) {
                              _controller.forward();
                            }
                          }
                          return false;
                        },
                        child: GridView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.0,
                          ),
                          itemCount: _soundsList.length + 3, // Sound items + 3 extra buttons
                          cacheExtent: 1000, // Tăng cache để mượt hơn khi vuốt
                          addAutomaticKeepAlives: false, // Tắt keepAlive để giảm bộ nhớ
                          addRepaintBoundaries: false, // Tắt repaintBoundaries mặc định vì chúng ta đã thêm thủ công
                          itemBuilder: (context, index) {
                            // Sử dụng key để tối ưu hóa việc rebuild
                            final key = ValueKey('grid_item_$index');
                            
                            if (index < _soundsList.length) {
                              // Sound items
                              return RepaintBoundary(
                                child: _buildOptimizedGridItem(
                                  index,
                                  _soundsList[index].name,
                                  IconData(
                                    int.parse(_soundsList[index].iconName),
                                    fontFamily: 'MaterialIcons',
                                  ),
                                  _getColorForIndex(index),
                                  () {
                                    HapticFeedback.mediumImpact();
                                    Navigator.of(context).push(
                                      _createPageRoute(
                                        SoundFlashView(
                                          title: _soundsList[index].name,
                                          soundPath: _soundsList[index].soundPath,
                                          iconName: _soundsList[index].iconName,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else if (index == _soundsList.length) {
                              // Fake error button
                              return RepaintBoundary(
                                child: _buildOptimizedGridItem(
                                  index,
                                  'Fake System Error',
                                  Constants.errorIcon,
                                  AppTheme.errorColor,
                                  () {
                                    HapticFeedback.mediumImpact();
                                    Navigator.of(context).push(
                                      _createPageRoute(const FakeErrorView()),
                                    );
                                  },
                                  isHighlighted: true,
                                ),
                              );
                            } else if (index == _soundsList.length + 1) {
                              // Unclickable button
                              return RepaintBoundary(
                                child: _buildOptimizedGridItem(
                                  index,
                                  'Unclickable Button',
                                  Constants.unclickableIcon,
                                  isDark ? AppTheme.darkAccentColor : AppTheme.accentColor,
                                  () {
                                    HapticFeedback.mediumImpact();
                                    Navigator.of(context).push(
                                      _createPageRoute(const UnclickableButtonView()),
                                    );
                                  },
                                ),
                              );
                            } else {
                              // Terminal Emulator button
                              return RepaintBoundary(
                                child: _buildOptimizedGridItem(
                                  index,
                                  'Terminal Emulator',
                                  Constants.terminalIcon,
                                  Colors.grey[800]!,
                                  () {
                                    HapticFeedback.mediumImpact();
                                    Navigator.of(context).push(
                                      _createPageRoute(const TerminalEmulatorView()),
                                    );
                                  },
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Custom page route with fun animations
  PageRouteBuilder<dynamic> _createPageRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 750),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Pick a random transition effect
        final effectIndex = _random.nextInt(5);
        
        switch (effectIndex) {
          case 0:
            // Zoom transition
            return ScaleTransition(
              alignment: _random.nextBool() ? Alignment.center : Alignment.topCenter,
              scale: Tween<double>(begin: 0.2, end: 1.0)
                .chain(CurveTween(curve: Curves.elasticOut))
                .animate(animation),
              child: child,
            );
          case 1:
            // Rotate and slide
            return RotationTransition(
              turns: Tween<double>(begin: _random.nextBool() ? 0.1 : -0.1, end: 0.0)
                .chain(CurveTween(curve: Curves.easeOutBack))
                .animate(animation),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(_random.nextBool() ? 1 : -1, 0), 
                  end: Offset.zero
                )
                  .chain(CurveTween(curve: Curves.easeOutCubic))
                  .animate(animation),
                child: child,
              ),
            );
          case 2:
            // Flip transition
            return AnimatedBuilder(
              animation: animation,
              child: child,
              builder: (context, child) {
                final rotateAnim = Tween(begin: pi, end: 0.0)
                  .chain(CurveTween(curve: Curves.easeOutBack))
                  .animate(animation);
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(rotateAnim.value),
                  child: child,
                );
              },
            );
          case 3:
            // Bounce transition with fade
            return AnimatedBuilder(
              animation: animation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
              builder: (context, child) {
                final bounce = sin(animation.value * pi * 3) * (1 - animation.value) * 30;
                return Transform.translate(
                  offset: Offset(0, bounce),
                  child: child,
                );
              }
            );
          default:
            // Fade transition with bounce
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutBack))
                  .animate(animation),
                child: child,
              ),
            );
        }
      },
    );
  }
  
  // Tối ưu version của _buildGridItem cho scrolling mượt mà hơn
  Widget _buildOptimizedGridItem(int index, String title, IconData icon, Color color, VoidCallback onTap, {bool isHighlighted = false}) {
    // Sử dụng builder thay vì auto-play để kiểm soát animations
    return MenuGridCard(
      key: ValueKey('menu_card_$index'),
      title: title,
      icon: icon,
      color: color,
      onTap: onTap,
      isHighlighted: isHighlighted,
    );
  }

  // Giữ nguyên _buildGridItem cho các item cần animation - sử dụng cho các mục tĩnh
  Widget _buildGridItem(int index, String title, IconData icon, Color color, VoidCallback onTap, {bool isHighlighted = false}) {
    return Animate(
      controller: _controller,
      effects: [
        FadeEffect(
          duration: const Duration(milliseconds: 600),
          delay: Duration(milliseconds: 200 + (index * 100)),
        ),
        ScaleEffect(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1.0, 1.0),
          duration: const Duration(milliseconds: 600),
          delay: Duration(milliseconds: 200 + (index * 100)),
          curve: Curves.easeOutBack,
        ),
      ],
      child: MenuGridCard(
        title: title,
        icon: icon,
        color: color,
        onTap: onTap,
        isHighlighted: isHighlighted,
      ),
    );
  }

  // Returns a color based on index from our theme
  Color _getColorForIndex(int index) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      AppTheme.highlightColor,
      AppTheme.energyColor,
    ];
    
    // Use modulo to cycle through colors
    return colors[index % colors.length];
  }
}

// Animated background pattern
class AnimatedPatternBackground extends StatefulWidget {
  final bool isDark;
  
  const AnimatedPatternBackground({
    Key? key,
    required this.isDark,
  }) : super(key: key);

  @override
  State<AnimatedPatternBackground> createState() => _AnimatedPatternBackgroundState();
}

class _AnimatedPatternBackgroundState extends State<AnimatedPatternBackground> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isPaused = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _pauseAnimation() {
    if (!_isPaused) {
      _isPaused = true;
      _animationController.stop();
    }
  }
  
  void _resumeAnimation() {
    if (_isPaused) {
      _isPaused = false;
      _animationController.repeat();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          if (notification.dragDetails != null) {
            // Khi đang vuốt, tạm dừng animation để giảm tải GPU
            _pauseAnimation();
          }
        } else if (notification is ScrollEndNotification) {
          // Khi dừng vuốt, tiếp tục animation
          Future.delayed(const Duration(milliseconds: 300), _resumeAnimation);
        }
        return false;
      },
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return CustomPaint(
              painter: PatternBackgroundPainter(
                animation: _animationController.value,
                isDark: widget.isDark,
              ),
              child: Container(),
            );
          },
        ),
      ),
    );
  }
}

class PatternBackgroundPainter extends CustomPainter {
  final double animation;
  final bool isDark;
  final Random random = Random(42);
  
  PatternBackgroundPainter({
    required this.animation,
    required this.isDark,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    // Giảm số lượng hình vẽ để tăng hiệu suất
    // Draw animated circles - giảm số lượng từ 20 xuống 8
    for (int i = 0; i < 8; i++) {
      final offsetX = random.nextDouble() * size.width;
      final offsetY = random.nextDouble() * size.height;
      final radius = 20 + random.nextDouble() * 40; // Tăng kích thước để giảm số lượng
      
      // Đơn giản hóa animation
      final animatedRadius = radius * (0.7 + 0.3 * sin((animation * pi) + i));
      
      final paint = Paint()
        ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      
      canvas.drawCircle(
        Offset(offsetX, offsetY),
        animatedRadius,
        paint,
      );
    }
    
    // Đơn giản hóa zigzag pattern - vẽ ít đường hơn, tăng khoảng cách
    final path = Path();
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    const zigzagWidth = 60.0; // Tăng khoảng cách từ 30 lên 60
    final zigzagHeight = 15.0; // Cố định chiều cao thay vì dùng animation
    
    // Giảm số lượng đường zigzag - chỉ vẽ cách 150px
    for (double y = 0; y < size.height; y += 150) {
      path.moveTo(0, y);
      
      for (double x = 0; x < size.width; x += zigzagWidth) {
        path.relativeLineTo(zigzagWidth / 2, zigzagHeight);
        path.relativeLineTo(zigzagWidth / 2, -zigzagHeight);
      }
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(covariant PatternBackgroundPainter oldDelegate) {
    // Chỉ vẽ lại khi animation thay đổi đáng kể
    return (oldDelegate.animation - animation).abs() > 0.05;
  }
} 