import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../widgets/glitch_text.dart';
import '../widgets/neon_border.dart';
import '../widgets/cyberpunk_bottom_sheet.dart';
import '../utils/app_theme.dart';
import '../utils/haptic_feedback_helper.dart';
import '../models/sound_model.dart';
import '../utils/constants.dart';
import '../viewmodels/troll_alarm_viewmodel.dart';
import '../viewmodels/theme_viewmodel.dart';
import '../widgets/animated_troll_button.dart';
import '../widgets/adaptive_card.dart';

class TrollAlarmView extends StatefulWidget {
  const TrollAlarmView({Key? key}) : super(key: key);

  @override
  State<TrollAlarmView> createState() => _TrollAlarmViewState();
}

class _TrollAlarmViewState extends State<TrollAlarmView>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Animations
  late AnimationController _pulseController;
  late AnimationController _glitchController;
  late AnimationController _timerAnimationController;
  late Animation<double> _timerAnimation;

  // Timer related variables
  Timer? _countdownTimer;
  int _secondsRemaining = 0;
  bool _isTimerRunning = false;
  bool _isTimerComplete = false;
  bool _isPlaying = false;

  // Sound selection
  List<SoundModel> _allSounds = [];
  SoundModel? _selectedSound;
  final Random _random = Random();

  // Presets
  final List<int> _presetTimes = [10, 30, 60, 300, 600]; // in seconds
  final List<String> _presetLabels = [
    '10 sec',
    '30 sec',
    '1 min',
    '5 min',
    '10 min',
  ];

  // Target options
  final List<String> _targets = [
    'Phone',
    'Friend\'s Phone',
    'Room Speaker',
    'Secret',
  ];
  String _selectedTarget = 'Phone';

  // Custom time selection
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 10;

  late AnimationController _backgroundAnimationController;
  final TextEditingController _timeController = TextEditingController();
  TimeOfDay? _selectedTime;
  DateTime? _selectedDateTime;
  bool _isExpanded = false;
  final List<String> _sounds = [
    "Fart Sound",
    "Air Horn",
    "Scream",
    "Evil Laugh",
    "Police Siren",
    "Mosquito",
    "Rooster",
    "Baby Crying",
  ];
  String _selectedSoundName = "Fart Sound";

  @override
  void initState() {
    super.initState();
    _loadSounds();

    // Initialize animation controllers
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _timerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _timerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _timerAnimationController, curve: Curves.linear),
    );

    // Set up periodic glitch effects
    _setupGlitchEffects();

    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Set default time to 5 minutes from now
    final now = DateTime.now();
    _selectedDateTime = now.add(const Duration(minutes: 5));
    _selectedTime = TimeOfDay.fromDateTime(_selectedDateTime!);
    _timeController.text = '${_selectedTime!.format(context)} (in 5 minutes)';
  }

  void _loadSounds() {
    _allSounds = Constants.getSoundsList();
    if (_allSounds.isNotEmpty) {
      _selectedSound = _allSounds[_random.nextInt(_allSounds.length)];
    }
  }

  void _setupGlitchEffects() {
    // Randomly trigger glitch effects
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        if (_random.nextDouble() < 0.5) {
          _triggerGlitchEffect();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _triggerGlitchEffect() {
    _glitchController.forward(from: 0).then((_) {
      _glitchController.reverse();
    });
    HapticFeedbackHelper.lightImpact();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glitchController.dispose();
    _timerAnimationController.dispose();
    _audioPlayer.dispose();
    _countdownTimer?.cancel();
    _backgroundAnimationController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _startTimer() {
    // Calculate total seconds
    final totalSeconds = (_hours * 3600) + (_minutes * 60) + _seconds;

    if (totalSeconds <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set a valid time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedSound == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a sound'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _secondsRemaining = totalSeconds;
      _isTimerRunning = true;
      _isTimerComplete = false;
    });

    // Update animation duration
    _timerAnimationController.duration = Duration(seconds: totalSeconds);
    _timerAnimationController.forward(from: 0);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        _timerComplete();
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });

    // Show start message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Timer started: ${_formatTime(totalSeconds)}'),
        backgroundColor: AppTheme.primaryColor.withOpacity(0.8),
      ),
    );

    HapticFeedbackHelper.mediumImpact();
  }

  void _timerComplete() {
    setState(() {
      _isTimerRunning = false;
      _isTimerComplete = true;
    });

    // Play selected sound
    _playSound();

    // Show completion message with random fun messages
    final messages = [
      'Gotcha! Troll activated!',
      'Surprise! Your troll has been deployed!',
      'Mission accomplished: Troll delivered!',
      'Troll attack successful!',
      'Target trolled successfully!',
    ];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(messages[_random.nextInt(messages.length)]),
        backgroundColor: AppTheme.secondaryColor.withOpacity(0.8),
        duration: const Duration(seconds: 5),
      ),
    );

    HapticFeedbackHelper.heavyImpact();

    // Trigger multiple glitch effects
    for (int i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: 200 * i), _triggerGlitchEffect);
    }
  }

  void _playSound() {
    if (_selectedSound == null) return;

    _audioPlayer.play(AssetSource(_selectedSound!.soundPath));
    setState(() {
      _isPlaying = true;
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
      }
    });
  }

  void _cancelTimer() {
    _countdownTimer?.cancel();
    _timerAnimationController.stop();

    setState(() {
      _isTimerRunning = false;
      _isTimerComplete = false;
      _secondsRemaining = 0;
    });

    HapticFeedbackHelper.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Timer cancelled'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _selectPresetTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    setState(() {
      _hours = hours;
      _minutes = minutes;
      _seconds = remainingSeconds;
    });

    HapticFeedbackHelper.selectionClick();
  }

  void _showSoundSelectionDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.black87,
            title: const Text(
              'Select Sound',
              style: TextStyle(color: Colors.white),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: _allSounds.length,
                itemBuilder: (context, index) {
                  final sound = _allSounds[index];
                  final isSelected = _selectedSoundName == sound.name;

                  return ListTile(
                    leading: Icon(
                      IconData(
                        int.parse(sound.iconName),
                        fontFamily: 'MaterialIcons',
                      ),
                      color: isSelected ? AppTheme.primaryColor : Colors.white,
                    ),
                    title: Text(
                      sound.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    trailing:
                        isSelected
                            ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            )
                            : null,
                    onTap: () {
                      setState(() {
                        _selectedSoundName = sound.name;
                      });
                      Navigator.pop(context);

                      // Preview the sound
                      _audioPlayer.play(AssetSource(sound.soundPath));
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              TextButton(
                onPressed: () {
                  // Select a random sound
                  setState(() {
                    _selectedSoundName =
                        _allSounds[_random.nextInt(_allSounds.length)].name;
                  });
                  Navigator.pop(context);

                  // Preview the sound
                  _audioPlayer.play(
                    AssetSource(
                      _allSounds[_random.nextInt(_allSounds.length)].soundPath,
                    ),
                  );
                },
                child: const Text(
                  'RANDOM',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ),
            ],
          ),
    );
  }

  String _formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainingSeconds = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${remainingSeconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${remainingSeconds}s';
    } else {
      return '${remainingSeconds}s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLightMode = theme.brightness == Brightness.light;
    final viewModel = Provider.of<TrollAlarmViewModel>(context);
    final themeViewModel = Provider.of<ThemeViewModel>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Troll Alarm",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              return CustomPaint(
                painter: AlarmBackgroundPainter(
                  animation: _backgroundAnimationController.value,
                  isDarkMode: themeViewModel.isDarkMode,
                  isAlarmSet: viewModel.isAlarmSet,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Main content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // Alarm clock visualization
                _buildClockVisualization(viewModel),

                const SizedBox(height: 20),

                // Countdown timer (only shown if alarm is set)
                if (viewModel.isAlarmSet) _buildCountdownTimer(viewModel),

                const SizedBox(height: 30),

                // Alarm setup card
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AdaptiveCard(
                      padding: const EdgeInsets.all(20),
                      borderRadius: BorderRadius.circular(20),
                      elevation: 4,
                      showGlow: true,
                      useGradientBackground: true,
                      backgroundGradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors:
                            themeViewModel.isDarkMode
                                ? [
                                  Colors.black.withOpacity(0.7),
                                  Colors.black.withOpacity(0.9),
                                ]
                                : [
                                  Colors.white.withOpacity(0.8),
                                  Colors.white.withOpacity(0.95),
                                ],
                      ),
                      borderColor:
                          viewModel.isAlarmSet
                              ? AppTheme.accentColor
                              : themeViewModel.isDarkMode
                              ? Colors.white24
                              : Colors.black12,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Card title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                viewModel.isAlarmSet
                                    ? "Alarm Set!"
                                    : "Set Prank Alarm",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      themeViewModel.isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                ),
                              ),

                              // Expand/collapse button
                              if (!viewModel.isAlarmSet)
                                IconButton(
                                  icon: Icon(
                                    _isExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: AppTheme.accentColor,
                                  ),
                                  onPressed: _toggleExpanded,
                                ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Time picker
                          GestureDetector(
                            onTap: () => _selectTime(context),
                            child: AbsorbPointer(
                              child: TextField(
                                controller: _timeController,
                                style: TextStyle(
                                  fontSize: 18,
                                  color:
                                      themeViewModel.isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Alarm Time',
                                  labelStyle: TextStyle(
                                    color:
                                        themeViewModel.isDarkMode
                                            ? Colors.white70
                                            : Colors.black54,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.access_time,
                                    color: AppTheme.accentColor,
                                  ),
                                  filled: true,
                                  fillColor:
                                      themeViewModel.isDarkMode
                                          ? Colors.white.withOpacity(0.1)
                                          : Colors.black.withOpacity(0.05),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabled: !viewModel.isAlarmSet,
                                ),
                              ),
                            ),
                          ),

                          // Sound selector (collapsed by default)
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 300),
                            crossFadeState:
                                _isExpanded
                                    ? CrossFadeState.showSecond
                                    : CrossFadeState.showFirst,
                            firstChild: const SizedBox(height: 10),
                            secondChild: Container(
                              margin: const EdgeInsets.only(top: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Select Sound",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          themeViewModel.isDarkMode
                                              ? Colors.white70
                                              : Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    height: 140,
                                    decoration: BoxDecoration(
                                      color:
                                          themeViewModel.isDarkMode
                                              ? Colors.white.withOpacity(0.1)
                                              : Colors.black.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color:
                                            themeViewModel.isDarkMode
                                                ? Colors.white24
                                                : Colors.black12,
                                        width: 1,
                                      ),
                                    ),
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      child: ListView.builder(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        itemCount: _sounds.length,
                                        itemBuilder: (context, index) {
                                          final isSelected =
                                              _selectedSoundName ==
                                              _sounds[index];
                                          return ListTile(
                                            title: Text(
                                              _sounds[index],
                                              style: TextStyle(
                                                color:
                                                    isSelected
                                                        ? AppTheme.accentColor
                                                        : themeViewModel
                                                            .isDarkMode
                                                        ? Colors.white70
                                                        : Colors.black87,
                                                fontWeight:
                                                    isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                              ),
                                            ),
                                            leading: Icon(
                                              isSelected
                                                  ? Icons.check_circle
                                                  : Icons.music_note,
                                              color:
                                                  isSelected
                                                      ? AppTheme.accentColor
                                                      : AppTheme.secondaryColor
                                                          .withOpacity(0.6),
                                            ),
                                            onTap: () {
                                              HapticFeedbackHelper.selectionClick();
                                              setState(() {
                                                _selectedSoundName =
                                                    _sounds[index];
                                              });
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Set/Cancel alarm button
                          AnimatedTrollButton(
                            text:
                                viewModel.isAlarmSet
                                    ? "Cancel Alarm"
                                    : "Set Alarm",
                            icon:
                                viewModel.isAlarmSet
                                    ? Icons.alarm_off
                                    : Icons.alarm_on,
                            onTap: _toggleAlarm,
                            color:
                                viewModel.isAlarmSet
                                    ? Colors.red
                                    : AppTheme.accentColor,
                            width: double.infinity,
                            useGradient: true,
                          ),

                          const SizedBox(height: 10),

                          // Return button
                          AnimatedTrollButton(
                            text: "Return to Menu",
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.pop(context),
                            width: double.infinity,
                            color: AppTheme.secondaryColor,
                            useGradient: false,
                            elevated: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClockVisualization(TrollAlarmViewModel viewModel) {
    return SizedBox(
      height: 200,
      width: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Clock face
          Container(
            height: 180,
            width: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  viewModel.isAlarmSet
                      ? AppTheme.accentColor.withOpacity(0.2)
                      : Colors.white.withOpacity(0.1),
              border: Border.all(
                color:
                    viewModel.isAlarmSet
                        ? AppTheme.accentColor
                        : Colors.white30,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color:
                      viewModel.isAlarmSet
                          ? AppTheme.accentColor.withOpacity(0.3)
                          : Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

          // Clock markings
          ...List.generate(12, (index) {
            final angle = (index * 30) * pi / 180;
            final isQuarterHour = index % 3 == 0;

            return Transform(
              alignment: Alignment.center,
              transform:
                  Matrix4.identity()
                    ..translate(0.0, 0.0, 0.0)
                    ..rotateZ(angle),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: isQuarterHour ? 15 : 8,
                  width: isQuarterHour ? 3 : 2,
                  margin: const EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                    color:
                        isQuarterHour
                            ? (viewModel.isAlarmSet
                                ? AppTheme.accentColor
                                : Colors.white70)
                            : Colors.white54,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            );
          }),

          // Hour hand
          if (_selectedTime != null)
            Transform(
              alignment: Alignment.center,
              transform:
                  Matrix4.identity()..rotateZ(
                    (_selectedTime!.hour * 30 + _selectedTime!.minute * 0.5) *
                        pi /
                        180,
                  ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 40,
                  width: 4,
                  margin: const EdgeInsets.only(top: 50),
                  decoration: BoxDecoration(
                    color:
                        viewModel.isAlarmSet
                            ? AppTheme.accentColor
                            : Colors.white,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),

          // Minute hand
          if (_selectedTime != null)
            Transform(
              alignment: Alignment.center,
              transform:
                  Matrix4.identity()
                    ..rotateZ(_selectedTime!.minute * 6 * pi / 180),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 60,
                  width: 3,
                  margin: const EdgeInsets.only(top: 30),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                ),
              ),
            ),

          // Center dot
          Container(
            height: 12,
            width: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: viewModel.isAlarmSet ? AppTheme.accentColor : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),

          // Alarm indicator if alarm is set
          if (viewModel.isAlarmSet)
            Positioned(
              top: 50,
              child: Icon(
                Icons.notifications_active,
                color: AppTheme.accentColor,
                size: 28,
              ).animate(
                onPlay: (controller) => controller.repeat(reverse: true),
                effects: [
                  ShakeEffect(
                    duration: const Duration(milliseconds: 2000),
                    curve: Curves.easeInOut,
                    hz: 3,
                    offset: const Offset(2, 0),
                  ),
                  ScaleEffect(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(1.2, 1.2),
                    duration: const Duration(milliseconds: 1000),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCountdownTimer(TrollAlarmViewModel viewModel) {
    // Get countdown data from view model
    final timeLeft = viewModel.timeUntilAlarm;
    final hours = timeLeft.inHours;
    final minutes = timeLeft.inMinutes % 60;
    final seconds = timeLeft.inSeconds % 60;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.accentColor.withOpacity(0.6),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer, color: AppTheme.accentColor, size: 20),
          const SizedBox(width: 8),
          Text(
            "Time until alarm: ",
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),

          // Countdown timer
          Text(
            "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              fontSize: 16,
            ),
          ).animate(
            onPlay: (controller) => controller.repeat(reverse: true),
            effects: const [
              ColorEffect(
                begin: Colors.white,
                end: Color(0xFFFF9800),
                duration: Duration(seconds: 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final viewModel = Provider.of<TrollAlarmViewModel>(context, listen: false);

    // If we already have an alarm set, don't allow changing it
    if (viewModel.isAlarmSet) {
      HapticFeedbackHelper.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cancel the current alarm to set a new one'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.accentColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    // Show time picker
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: AppTheme.darkSurfaceColor,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      HapticFeedbackHelper.selectionClick();

      // Calculate the date time
      final now = DateTime.now();
      DateTime selectedDT = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      // If the selected time is before current time, add 1 day
      if (selectedDT.isBefore(now)) {
        selectedDT = selectedDT.add(const Duration(days: 1));
      }

      // Calculate minutes until alarm
      final minutesUntil = selectedDT.difference(now).inMinutes;
      String timeUntil;

      if (minutesUntil < 60) {
        timeUntil = 'in $minutesUntil minutes';
      } else if (minutesUntil < 60 * 24) {
        final hours = (minutesUntil / 60).floor();
        final mins = minutesUntil % 60;
        timeUntil =
            'in $hours ${hours == 1 ? 'hour' : 'hours'}${mins > 0 ? ' $mins mins' : ''}';
      } else {
        timeUntil = 'tomorrow';
      }

      setState(() {
        _selectedTime = picked;
        _selectedDateTime = selectedDT;
        _timeController.text = '${picked.format(context)} ($timeUntil)';
      });
    }
  }

  void _toggleExpanded() {
    HapticFeedbackHelper.lightImpact();
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _toggleAlarm() {
    if (_selectedDateTime == null) return;

    final viewModel = Provider.of<TrollAlarmViewModel>(context, listen: false);

    if (viewModel.isAlarmSet) {
      // Cancel the alarm
      viewModel.cancelAlarm();
      HapticFeedbackHelper.mediumImpact();
    } else {
      // Set the alarm
      viewModel.setAlarm(_selectedDateTime!, _selectedSoundName);
      HapticFeedbackHelper.heavyImpact();

      // Collapse the expanded view when setting alarm
      setState(() {
        _isExpanded = false;
      });
    }
  }
}

class AlarmBackgroundPainter extends CustomPainter {
  final double animation;
  final bool isDarkMode;
  final bool isAlarmSet;

  AlarmBackgroundPainter({
    required this.animation,
    required this.isDarkMode,
    required this.isAlarmSet,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Base background gradient
    final Rect rect = Offset.zero & size;

    // Create different gradient colors based on alarm state and theme
    final List<Color> gradientColors =
        isAlarmSet
            ? [
              const Color(0xFF6A11CB), // Purple
              const Color(0xFF2575FC), // Blue
            ]
            : isDarkMode
            ? [Colors.black, const Color(0xFF192028)]
            : [const Color(0xFF5E81AC), const Color(0xFF4C566A)];

    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: gradientColors,
    );

    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Draw animated star pattern
    final starPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    const int starCount = 50;
    final random = Random(42); // Fixed seed for consistent randomness

    for (int i = 0; i < starCount; i++) {
      final x = (random.nextDouble() * size.width);
      final y = (random.nextDouble() * size.height);
      final radius = 1 + random.nextDouble() * 2;

      // Make stars twinkle with the animation value
      final twinkle = 0.5 + sin(animation * 2 * pi + i) * 0.5;
      starPaint.color = Colors.white.withOpacity(0.1 + (twinkle * 0.3));

      canvas.drawCircle(Offset(x, y), radius * twinkle, starPaint);
    }

    // Draw animated clock patterns
    if (isAlarmSet) {
      const double maxRadius = 300;
      final circlePaint =
          Paint()
            ..color = AppTheme.accentColor.withOpacity(0.1)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;

      // Draw concentric circles from center
      for (int i = 0; i < 5; i++) {
        final progress = (animation + (i * 0.2)) % 1.0;
        final radius = progress * maxRadius;

        circlePaint.color = AppTheme.accentColor.withOpacity(
          0.3 - (progress * 0.3),
        );

        canvas.drawCircle(
          Offset(size.width / 2, size.height / 2),
          radius,
          circlePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant AlarmBackgroundPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.isDarkMode != isDarkMode ||
        oldDelegate.isAlarmSet != isAlarmSet;
  }
}
