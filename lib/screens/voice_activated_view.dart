import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../widgets/glitch_text.dart';
import '../widgets/neon_border.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';
import '../models/sound_model.dart';

class VoiceActivatedView extends StatefulWidget {
  const VoiceActivatedView({Key? key}) : super(key: key);

  @override
  State<VoiceActivatedView> createState() => _VoiceActivatedViewState();
}

class _VoiceActivatedViewState extends State<VoiceActivatedView>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<SoundModel> _soundsList = [];
  final Random _random = Random();

  late AnimationController _animationController;
  final List<VoiceCommand> _commands = [];

  bool _isListening = false;
  String _transcription = '';
  String _lastPlayedSound = '';
  int _confidenceLevel = 0;
  Timer? _listenTimer;

  int _consecutiveMatches = 0;
  bool _showRippleEffect = false;

  @override
  void initState() {
    super.initState();
    _loadSounds();
    _setupCommands();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  void _loadSounds() {
    setState(() {
      _soundsList.addAll(Constants.getSoundsList());
    });
  }

  void _setupCommands() {
    // In a real app, we would use a speech recognition library here.
    // For demonstration purposes, we'll simulate voice commands.

    // Add commands for each sound type
    for (final sound in _soundsList) {
      _commands.add(
        VoiceCommand(
          trigger: sound.name.toLowerCase(),
          action: () => _playSound(sound.soundPath),
          soundName: sound.name,
        ),
      );
    }

    // Add some special triggers
    _commands.add(
      VoiceCommand(
        trigger: 'random',
        action: () => _playRandomSound(),
        soundName: 'Random Sound',
      ),
    );

    _commands.add(
      VoiceCommand(
        trigger: 'stop',
        action: () => _stopSound(),
        soundName: 'Stop Sound',
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    _listenTimer?.cancel();
    super.dispose();
  }

  void _toggleListening() {
    // In a real app, we would start/stop the speech recognition here
    if (_isListening) {
      _stopListening();
    } else {
      _startListening();
    }
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _transcription = 'Listening...';
      _showRippleEffect = true;
    });

    // Simulate speech recognition with timer
    _listenTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      // Simulate a random voice command for demo purposes
      if (_random.nextDouble() > 0.6) {
        final command = _commands[_random.nextInt(_commands.length)];
        _simulateCommandRecognition(command);
      } else {
        _simulateBackgroundNoise();
      }
    });
  }

  void _stopListening() {
    _listenTimer?.cancel();

    setState(() {
      _isListening = false;
      _transcription = 'Tap mic to start';
      _confidenceLevel = 0;
      _showRippleEffect = false;
    });
  }

  void _simulateCommandRecognition(VoiceCommand command) {
    setState(() {
      _transcription = command.trigger;
      _confidenceLevel = 70 + _random.nextInt(30); // 70-100%

      // Execute the command if confidence is high enough
      if (_confidenceLevel > 75) {
        command.action();
        _lastPlayedSound = command.soundName;
        _consecutiveMatches++;

        // Haptic feedback on successful match
        HapticFeedback.mediumImpact();
      }
    });
  }

  void _simulateBackgroundNoise() {
    final noiseWords = [
      'background noise',
      'hmm...',
      'not sure',
      'what was that?',
      'can you repeat?',
      '...',
    ];

    setState(() {
      _transcription = noiseWords[_random.nextInt(noiseWords.length)];
      _confidenceLevel = 20 + _random.nextInt(40); // 20-60%
      _consecutiveMatches = 0;
    });
  }

  Future<void> _playSound(String soundPath) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(soundPath));
    } catch (e) {
      // Xử lý lỗi khi phát âm thanh
    }
  }

  Future<void> _playRandomSound() async {
    if (_soundsList.isEmpty) return;

    final randomSound = _soundsList[_random.nextInt(_soundsList.length)];
    await _playSound(randomSound.soundPath);

    setState(() {
      _lastPlayedSound = 'Random: ${randomSound.name}';
    });
  }

  Future<void> _stopSound() async {
    await _audioPlayer.stop();

    setState(() {
      _lastPlayedSound = 'Sound stopped';
    });
  }

  Color _getConfidenceColor() {
    if (_confidenceLevel >= 80) {
      return Colors.green;
    } else if (_confidenceLevel >= 60) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor =
        isDark ? AppTheme.primaryColor.withOpacity(0.9) : AppTheme.primaryColor;
    final accentColor =
        isDark ? AppTheme.accentColor.withOpacity(0.9) : AppTheme.accentColor;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: GlitchText(
          'Voice Activation',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              isDark ? Colors.black : AppTheme.primaryColor.withOpacity(0.8),
              isDark
                  ? Colors.black.withOpacity(0.8)
                  : AppTheme.secondaryColor.withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Voice recognition status
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: NeonBorder(
                    color: _isListening ? accentColor : primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'NEURAL INTERFACE',
                        style: TextStyle(
                          color: _isListening ? accentColor : primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Speech transcription display
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.spatial_audio,
                              color:
                                  _isListening ? Colors.white : Colors.white54,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _transcription,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight:
                                      _isListening
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ),
                            if (_confidenceLevel > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getConfidenceColor().withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _getConfidenceColor(),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '$_confidenceLevel%',
                                  style: TextStyle(
                                    color: _getConfidenceColor(),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Last played sound
                      if (_lastPlayedSound.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.music_note,
                                color: primaryColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Played: $_lastPlayedSound',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // Microphone activation button
                Expanded(
                  child: Center(
                    child: AvatarGlow(
                      glowColor: _isListening ? accentColor : primaryColor,
                      glowRadiusFactor: 0.7,
                      duration: const Duration(milliseconds: 2000),
                      repeat: true,
                      animate: _showRippleEffect,
                      child: Container(
                        decoration: NeonBorder(
                          color: _isListening ? accentColor : primaryColor,
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Material(
                          elevation: 8.0,
                          shape: const CircleBorder(),
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _toggleListening,
                            customBorder: const CircleBorder(),
                            child: Container(
                              padding: const EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black54,
                                gradient: RadialGradient(
                                  colors: [
                                    (_isListening ? accentColor : primaryColor)
                                        .withOpacity(0.3),
                                    Colors.black54,
                                  ],
                                ),
                              ),
                              child: Icon(
                                _isListening ? Icons.mic : Icons.mic_none,
                                color:
                                    _isListening ? accentColor : primaryColor,
                                size: 50,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Command list
                Container(
                  height: 200,
                  margin: const EdgeInsets.only(top: 24),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          'VOICE COMMANDS',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _commands.length,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemBuilder: (context, index) {
                            final command = _commands[index];
                            final isActive =
                                _transcription.toLowerCase() == command.trigger;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isActive
                                        ? primaryColor.withOpacity(0.2)
                                        : Colors.black12,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      isActive ? primaryColor : Colors.white24,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.record_voice_over,
                                    color:
                                        isActive
                                            ? primaryColor
                                            : Colors.white54,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '"${command.trigger}"',
                                      style: TextStyle(
                                        color:
                                            isActive
                                                ? primaryColor
                                                : Colors.white,
                                        fontWeight:
                                            isActive
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '→ ${command.soundName}',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VoiceCommand {
  final String trigger;
  final VoidCallback action;
  final String soundName;

  VoiceCommand({
    required this.trigger,
    required this.action,
    required this.soundName,
  });
}
