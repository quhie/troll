import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/sound_viewmodel.dart';
import '../models/sound_model.dart';
import 'home_screen.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({Key? key}) : super(key: key);

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  final TextEditingController _logController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _logController.text = 'Debug log initialized\n';

    // Log when the screen is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addLog('Debug screen mounted');
      _checkViewModel();
    });
  }

  @override
  void dispose() {
    _logController.dispose();
    super.dispose();
  }

  void _addLog(String message) {
    setState(() {
      _logController.text +=
          '${DateTime.now().toString().substring(11, 19)}: $message\n';
    });

    // Scroll to bottom
    _logController.selection = TextSelection.fromPosition(
      TextPosition(offset: _logController.text.length),
    );
  }

  void _checkViewModel() {
    final viewModel = Provider.of<SoundViewModel>(context, listen: false);

    // Log the current state
    _addLog('Checking SoundViewModel state');
    _addLog('Local sounds count: ${viewModel.localSounds.length}');
    _addLog('Online sounds count: ${viewModel.onlineSounds.length}');
    _addLog('Favorite sounds count: ${viewModel.favoriteSounds.length}');
    _addLog('Selected category: ${viewModel.selectedCategory}');
    _addLog('Is loading: ${viewModel.isLoading}');

    // Log first 3 online sounds if any
    if (viewModel.onlineSounds.isNotEmpty) {
      _addLog('First online sounds:');
      for (int i = 0; i < viewModel.onlineSounds.length && i < 3; i++) {
        final sound = viewModel.onlineSounds[i];
        _addLog('  ${i + 1}. ${sound.name} (${sound.id}): ${sound.soundPath}');
      }
    } else {
      _addLog('No online sounds available');
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SoundViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Mode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _addLog('Refreshing debug info');
              _checkViewModel();
            },
          ),
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Debug Controls',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Status info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Loading: ${viewModel.isLoading ? '🔄 Yes' : '✅ No'}',
                        ),
                        Text('Online sounds: ${viewModel.onlineSounds.length}'),
                        Text('Local sounds: ${viewModel.localSounds.length}'),
                        Text('Favorites: ${viewModel.favoriteSounds.length}'),
                        Text(
                          'Selected category: ${viewModel.selectedCategory.isEmpty ? 'None' : viewModel.selectedCategory}',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Load data buttons
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _addLog('Loading trending sounds');
                          viewModel.loadTrendingSounds();
                        },
                        child: const Text('Load Trending'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _addLog('Loading recent sounds');
                          viewModel.loadRecentSounds();
                        },
                        child: const Text('Load Recent'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _addLog('Loading best sounds');
                          viewModel.loadBestSounds();
                        },
                        child: const Text('Load Best'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _addLog('Manual refresh UI');
                          viewModel.refreshUI();
                        },
                        child: const Text('Force UI Refresh'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _addLog('Loading mock sounds for testing');
                          viewModel.forceLoadMockSounds();
                        },
                        child: const Text('Load Mock Sounds'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Online sounds list (first 5)
                  const Text(
                    'Online Sounds Preview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  viewModel.onlineSounds.isEmpty
                      ? const Text('No online sounds available')
                      : Column(
                        children: [
                          for (
                            int i = 0;
                            i < viewModel.onlineSounds.length && i < 5;
                            i++
                          )
                            _buildSoundPreviewCard(
                              viewModel.onlineSounds[i],
                              i,
                            ),
                        ],
                      ),
                ],
              ),
            ),
          ),

          // Debug log
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Debug Log',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _logController.text = 'Log cleared\n';
                          });
                        },
                        tooltip: 'Clear log',
                      ),
                    ],
                  ),
                  Expanded(
                    child: TextField(
                      controller: _logController,
                      readOnly: true,
                      maxLines: null,
                      expands: true,
                      style: const TextStyle(
                        color: Colors.green,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundPreviewCard(SoundModel sound, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Text('${index + 1}'),
        ),
        title: Text(sound.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ID: ${sound.id}',
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'URL: ${sound.soundPath}',
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        trailing:
            sound.isFavorite
                ? const Icon(Icons.favorite, color: Colors.red)
                : const Icon(Icons.favorite_border),
        onTap: () {
          _addLog('Tapped sound: ${sound.name}');

          // Show sound details
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: Text(sound.name),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('ID: ${sound.id}'),
                        const SizedBox(height: 8),
                        Text('URL: ${sound.soundPath}'),
                        const SizedBox(height: 8),
                        Text('Category: ${sound.category.name}'),
                        const SizedBox(height: 8),
                        Text('Favorite: ${sound.isFavorite ? 'Yes' : 'No'}'),
                        const SizedBox(height: 8),
                        Text('Local: ${sound.isLocal ? 'Yes' : 'No'}'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Close'),
                    ),
                  ],
                ),
          );
        },
      ),
    );
  }
}
