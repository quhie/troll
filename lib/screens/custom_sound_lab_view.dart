import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/glitch_text.dart';
import '../widgets/neon_border.dart';
import '../widgets/cyberpunk_bottom_sheet.dart';
import '../utils/app_theme.dart';
import '../utils/haptic_feedback_helper.dart';

class CustomSoundLabView extends StatefulWidget {
  const CustomSoundLabView({Key? key}) : super(key: key);

  @override
  State<CustomSoundLabView> createState() => _CustomSoundLabViewState();
}

class _CustomSoundLabViewState extends State<CustomSoundLabView>
    with SingleTickerProviderStateMixin {
  final _audioRecorder = AudioRecorder();
  final _audioPlayer = AudioPlayer();
  late AnimationController _animationController;

  String? _recordedPath;
  bool _isRecording = false;
  bool _isPlaying = false;
  double _pitch = 1.0;
  double _distortion = 0.0;
  double _reverb = 0.0;
  double _volume = 1.0;
  double _visualizerValue = 0.0;
  String _soundName = 'My Sound';

  final List<Map<String, dynamic>> _savedSounds = [];
  final List<String> _effects = [
    'Normal',
    'Robot',
    'Alien',
    'Monster',
    'Chipmunk',
  ];
  String _selectedEffect = 'Normal';

  Timer? _visualizerTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initRecorder();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Start visualizer animation
    _startVisualizer();

    // Load saved sounds
    _loadSavedSounds();
  }

  Future<void> _initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Microphone permission is required for recording'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadSavedSounds() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = Directory(directory.path).listSync();

      final soundFiles =
          files
              .where(
                (file) =>
                    file.path.endsWith('.aac') &&
                    file.path.contains('troll_sound_'),
              )
              .toList();

      if (soundFiles.isNotEmpty) {
        setState(() {
          _savedSounds.clear();
          for (var file in soundFiles) {
            final fileName = file.path.split('/').last;
            final name = fileName
                .replaceAll('troll_sound_', '')
                .replaceAll('.aac', '');
            _savedSounds.add({
              'path': file.path,
              'name': 'Sound ${_savedSounds.length + 1}',
              'date': name,
            });
          }
        });
      }
    } catch (e) {
      // Error loading saved sounds
    }
  }

  void _startVisualizer() {
    _visualizerTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_isRecording || _isPlaying) {
        setState(() {
          _visualizerValue = _random.nextDouble();
        });
      } else {
        setState(() {
          _visualizerValue = _visualizerValue * 0.8;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _animationController.dispose();
    _visualizerTimer?.cancel();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await Permission.microphone.request() == PermissionStatus.granted) {
        final directory = await getTemporaryDirectory();
        final filePath =
            '${directory.path}/custom_sound_${DateTime.now().millisecondsSinceEpoch}.aac';

        await _audioRecorder.start(const RecordConfig(), path: filePath);
        HapticFeedbackHelper.lightImpact();

        _animationController.repeat(reverse: true);

        setState(() {
          _isRecording = true;
          _recordedPath = filePath;
        });
      }
    } catch (e) {
      // Error recording audio
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error recording: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      HapticFeedbackHelper.mediumImpact();

      _animationController.stop();

      setState(() {
        _isRecording = false;
      });

      if (path != null) {
        setState(() {
          _recordedPath = path;
        });
        // Play a preview after recording
        _playSound();
      }
    } catch (e) {
      // Error stopping recording
    }
  }

  Future<void> _playSound() async {
    if (_recordedPath == null) return;

    try {
      await _audioPlayer.stop();

      // Apply effects based on settings
      final playbackRate = _getPlaybackRateForEffect();

      await _audioPlayer.setPlaybackRate(playbackRate);
      await _audioPlayer.setVolume(_volume);

      // In a real app, we would apply more effects here with a more advanced audio processing library
      // For now, we'll simulate effects by adjusting playback rate and volume

      await _audioPlayer.play(DeviceFileSource(_recordedPath!));
      HapticFeedbackHelper.lightImpact();

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
    } catch (e) {
      // Error playing sound
    }
  }

  double _getPlaybackRateForEffect() {
    switch (_selectedEffect) {
      case 'Robot':
        return 0.8;
      case 'Alien':
        return 0.7;
      case 'Monster':
        return 0.5;
      case 'Chipmunk':
        return 1.5;
      default:
        return _pitch;
    }
  }

  Future<void> _openSaveDialog() async {
    if (_recordedPath == null) return;

    final TextEditingController nameController = TextEditingController(
      text: _soundName,
    );

    await CyberpunkBottomSheet.show(
      context: context,
      title: 'SAVE SOUND',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Name your sound creation:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Sound name field
            Container(
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  border: InputBorder.none,
                  hintText: 'Enter sound name',
                  hintStyle: TextStyle(color: Colors.white54),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _soundName =
                      nameController.text.isNotEmpty
                          ? nameController.text
                          : 'My Sound';
                });
                Navigator.pop(context);
                _saveCurrentSound(_soundName);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'SAVE SOUND',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveCurrentSound(String name) async {
    if (_recordedPath == null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'troll_sound_$timestamp.aac';
      final savedPath = '${directory.path}/$fileName';

      // Copy the file
      final file = File(_recordedPath!);
      await file.copy(savedPath);

      setState(() {
        _savedSounds.add({
          'path': savedPath,
          'name': name,
          'date': timestamp.toString(),
        });
      });

      // Show success message
      if (mounted) {
        HapticFeedbackHelper.successFeedback();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sound saved successfully!'),
            backgroundColor: AppTheme.primaryColor.withOpacity(0.8),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Error saving sound
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving sound: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _playSavedSound(String path) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setPlaybackRate(1.0);
      await _audioPlayer.setVolume(1.0);
      await _audioPlayer.play(DeviceFileSource(path));
      HapticFeedbackHelper.lightImpact();

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
    } catch (e) {
      // Error playing saved sound
    }
  }

  Future<void> _deleteSavedSound(int index) async {
    try {
      final soundToDelete = _savedSounds[index];
      final file = File(soundToDelete['path']);

      if (await file.exists()) {
        await file.delete();
      }

      setState(() {
        _savedSounds.removeAt(index);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sound deleted'),
            backgroundColor: Colors.red.withOpacity(0.8),
          ),
        );
      }
    } catch (e) {
      // Error deleting sound
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
      appBar: AppBar(
        title: GlitchText(
          'Custom Sound Lab',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
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
                // Audio visualizer
                Container(
                  height: 120,
                  decoration: NeonBorder(
                    color: _isRecording ? Colors.red : accentColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  child: CustomPaint(
                    painter: AudioVisualizerPainter(
                      value: _visualizerValue,
                      color: _isRecording ? Colors.red : accentColor,
                      barCount: 32,
                    ),
                    child: Center(
                      child: Text(
                        _isRecording
                            ? 'RECORDING...'
                            : (_isPlaying ? 'PLAYING...' : 'Ready'),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),

                // Control panel
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EFFECTS CONTROL PANEL',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Effects dropdown
                      Row(
                        children: [
                          Text(
                            'Effect:',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: NeonBorder(
                                color: accentColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: _selectedEffect,
                                dropdownColor: Colors.black87,
                                style: const TextStyle(color: Colors.white),
                                underline: const SizedBox(),
                                isExpanded: true,
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    HapticFeedbackHelper.selectionFeedback();
                                    setState(() {
                                      _selectedEffect = newValue;
                                    });
                                  }
                                },
                                items:
                                    _effects.map<DropdownMenuItem<String>>((
                                      String value,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Pitch slider
                      Text(
                        'Pitch: ${_pitch.toStringAsFixed(1)}x',
                        style: TextStyle(color: Colors.white),
                      ),
                      Slider(
                        value: _pitch,
                        min: 0.5,
                        max: 2.0,
                        divisions: 15,
                        activeColor: primaryColor,
                        inactiveColor: primaryColor.withOpacity(0.3),
                        onChanged: (value) {
                          setState(() {
                            _pitch = value;
                          });
                        },
                      ),

                      // Volume slider
                      Text(
                        'Volume: ${(_volume * 100).toInt()}%',
                        style: TextStyle(color: Colors.white),
                      ),
                      Slider(
                        value: _volume,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        activeColor: accentColor,
                        inactiveColor: accentColor.withOpacity(0.3),
                        onChanged: (value) {
                          setState(() {
                            _volume = value;
                          });
                        },
                      ),

                      // Distortion slider
                      Text(
                        'Distortion: ${(_distortion * 100).toInt()}%',
                        style: TextStyle(color: Colors.white),
                      ),
                      Slider(
                        value: _distortion,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        activeColor: Colors.red,
                        inactiveColor: Colors.red.withOpacity(0.3),
                        onChanged: (value) {
                          setState(() {
                            _distortion = value;
                          });
                        },
                      ),

                      // Reverb slider
                      Text(
                        'Reverb: ${(_reverb * 100).toInt()}%',
                        style: TextStyle(color: Colors.white),
                      ),
                      Slider(
                        value: _reverb,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        activeColor: Colors.yellow,
                        inactiveColor: Colors.yellow.withOpacity(0.3),
                        onChanged: (value) {
                          setState(() {
                            _reverb = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildButton(
                      label: _isRecording ? 'Stop' : 'Record',
                      icon: _isRecording ? Icons.stop : Icons.mic,
                      color: Colors.red,
                      onPressed:
                          _isRecording ? _stopRecording : _startRecording,
                    ),
                    _buildButton(
                      label: 'Play',
                      icon: Icons.play_arrow,
                      color: primaryColor,
                      onPressed:
                          _recordedPath != null && !_isRecording
                              ? _playSound
                              : null,
                    ),
                    _buildButton(
                      label: 'Save',
                      icon: Icons.save,
                      color: accentColor,
                      onPressed:
                          _recordedPath != null && !_isRecording
                              ? _openSaveDialog
                              : null,
                    ),
                  ],
                ),

                // Saved sounds
                if (_savedSounds.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SAVED SOUNDS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          letterSpacing: 1.0,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.refresh, color: Colors.white70),
                        onPressed: _loadSavedSounds,
                        tooltip: 'Refresh saved sounds',
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _savedSounds.length,
                      itemBuilder: (context, index) {
                        final sound = _savedSounds[index];
                        final String fileName = sound['path'].split('/').last;
                        return Dismissible(
                          key: Key(sound['path']),
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16.0),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            _deleteSavedSound(index);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: NeonBorder(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              title: Text(
                                sound['name'],
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                'Created: ${DateTime.fromMillisecondsSinceEpoch(int.parse(sound['date'])).toString().substring(0, 16)}',
                                style: TextStyle(color: Colors.white70),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.share,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      // In a real app, we would implement sharing functionality
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Sharing not implemented in this demo',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.play_arrow,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      _playSavedSound(sound['path']);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedNeonBorder(
          color: color,
          borderRadius: BorderRadius.circular(50),
          animate: onPressed != null,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              backgroundColor: Colors.black54,
              shape: const CircleBorder(),
              disabledBackgroundColor: Colors.black38,
            ),
            child: Icon(
              icon,
              color: onPressed != null ? color : Colors.grey,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class AudioVisualizerPainter extends CustomPainter {
  final double value;
  final Color color;
  final int barCount;
  final Random random = Random();

  AudioVisualizerPainter({
    required this.value,
    required this.color,
    this.barCount = 20,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / barCount;
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    for (int i = 0; i < barCount; i++) {
      // Generate a height based on value but with some randomness
      final seedValue = value * (0.1 + 0.9 * sin(i / barCount * pi));
      final randomValue = seedValue * (0.5 + random.nextDouble() * 0.5);
      final barHeight = size.height * randomValue * 0.8;

      final rect = Rect.fromLTWH(
        i * barWidth,
        (size.height - barHeight) / 2,
        barWidth * 0.7,
        barHeight,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AudioVisualizerPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
