import 'package:flutter/material.dart';
import 'dart:async';

class TerminalEmulatorView extends StatefulWidget {
  const TerminalEmulatorView({super.key});

  @override
  State<TerminalEmulatorView> createState() => _TerminalEmulatorViewState();
}

class _TerminalEmulatorViewState extends State<TerminalEmulatorView> {
  final List<String> _commandHistory = [];
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _currentDirectory = '~/user';
  bool _showCursor = true;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _commandHistory.add('Welcome to Terminal Emulator');
    _commandHistory.add('Type "help" for available commands');
    _commandHistory.add('');
    
    // Create blinking cursor effect
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _showCursor = !_showCursor;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _cursorTimer?.cancel();
    super.dispose();
  }

  void _processCommand(String command) {
    setState(() {
      _commandHistory.add('$_currentDirectory\$ $command');
      
      if (command.trim().isEmpty) {
        // Handle empty command
        _commandHistory.add('');
      } else if (command == 'clear') {
        _commandHistory.clear();
      } else if (command == 'help') {
        _commandHistory.add('Available commands:');
        _commandHistory.add('  help    - Show this help message');
        _commandHistory.add('  clear   - Clear the terminal');
        _commandHistory.add('  ls      - List files and directories');
        _commandHistory.add('  pwd     - Print working directory');
        _commandHistory.add('  date    - Show current date and time');
        _commandHistory.add('  exit    - Exit the terminal');
        _commandHistory.add('');
      } else if (command == 'ls') {
        _commandHistory.add('Documents');
        _commandHistory.add('Downloads');
        _commandHistory.add('Pictures');
        _commandHistory.add('Music');
        _commandHistory.add('trollpro.sh');
        _commandHistory.add('');
      } else if (command == 'pwd') {
        _commandHistory.add(_currentDirectory);
        _commandHistory.add('');
      } else if (command == 'date') {
        _commandHistory.add(DateTime.now().toString());
        _commandHistory.add('');
      } else if (command == 'exit') {
        Navigator.pop(context);
      } else {
        _commandHistory.add('Command not found: $command');
        _commandHistory.add('');
      }
      
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Terminal', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(_focusNode);
        },
        child: Container(
          color: Colors.black,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // Terminal output
              Expanded(
                child: ListView.builder(
                  itemCount: _commandHistory.length,
                  itemBuilder: (context, index) {
                    return Text(
                      _commandHistory[index],
                      style: const TextStyle(
                        color: Colors.green,
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                    );
                  },
                ),
              ),
              
              // Command input
              Row(
                children: [
                  Text(
                    '$_currentDirectory\$ ',
                    style: const TextStyle(
                      color: Colors.green,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      autofocus: true,
                      style: const TextStyle(
                        color: Colors.green,
                        fontFamily: 'monospace',
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        suffixText: _showCursor ? '|' : ' ',
                        suffixStyle: const TextStyle(
                          color: Colors.green,
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                      cursorColor: Colors.transparent,
                      onSubmitted: _processCommand,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 