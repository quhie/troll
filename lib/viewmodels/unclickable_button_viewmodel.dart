import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UnclickableButtonViewModel extends ChangeNotifier {
  // Button position
  Offset _position = Offset.zero;
  Offset get position => _position;

  // Screen dimensions
  Size _screenSize = Size.zero;
  
  // Button dimensions
  final double buttonWidth = 150;
  final double buttonHeight = 60;
  
  // Movement configuration
  final double minDistance = 100;
  final double maxDistance = 250;
  
  // Movement history to create more unpredictable patterns
  final List<Offset> _previousPositions = [];
  final int _historyLimit = 8; // Increased history for more complex patterns
  
  // Track number of move attempts to adjust difficulty
  int _moveCount = 0;
  int get moveCount => _moveCount;
  
  // Movement strategy - changes based on attempts
  late MovementStrategy _movementStrategy;
  
  // Movement patterns
  final List<MovementPattern> _patterns = [
    BasicMovementPattern(),
    CircularMovementPattern(),
    ZigzagMovementPattern(),
    FakeoutMovementPattern(),
    EdgeHuggingMovementPattern(),
  ];
  
  // Value notifiers for reactive properties
  final ValueNotifier<double> _buttonSpeed = ValueNotifier<double>(1.0);
  double get buttonSpeed => _buttonSpeed.value;
  
  // Button state
  bool _isCornered = false;
  bool get isCornered => _isCornered;
  
  // Initialize with centered position and basic strategy
  UnclickableButtonViewModel() {
    _position = Offset.zero;
    _movementStrategy = BasicMovementStrategy();
    
    // Listen to speed changes
    _buttonSpeed.addListener(_checkSpeedThreshold);
  }
  
  // Check if speed has crossed a threshold that requires strategy change
  void _checkSpeedThreshold() {
    if (_buttonSpeed.value > 2.0 && _movementStrategy is BasicMovementStrategy) {
      _movementStrategy = AdvancedMovementStrategy(this);
    } else if (_buttonSpeed.value > 3.0 && !(_movementStrategy is TrollMovementStrategy)) {
      _movementStrategy = TrollMovementStrategy(this);
    }
  }
  
  // Update screen size when layout changes
  void updateScreenSize(Size size) {
    if (_screenSize != size) {
      _screenSize = size;
      
      // Initialize position if not set or if screen size changed
      if (_position == Offset.zero) {
        _position = Offset(
          (_screenSize.width - buttonWidth) / 2,
          (_screenSize.height - buttonHeight) / 2,
        );
        _previousPositions.add(_position);
      }
      
      notifyListeners();
    }
  }
  
  // Get dynamic distance range based on move count
  // Button moves farther as user makes more attempts
  double _getDynamicMinDistance() {
    // Gradually increase minimum distance (starts at 100, caps at 200)
    return minDistance + min(_moveCount * 10, 100);
  }
  
  double _getDynamicMaxDistance() {
    // Gradually increase maximum distance (starts at 250, caps at 400)
    return maxDistance + min(_moveCount * 15, 150);
  }
  
  // Get dynamic evasion factor based on move count (0.0 to 1.0)
  // Higher values make the button more likely to move away from mouse
  double _getEvasionFactor() {
    // Starts at 0.2, increases to max 0.8
    return min(0.2 + (_moveCount * 0.06), 0.8);
  }
  
  // Move button when user tries to press it
  void moveButton() {
    if (_screenSize == Size.zero) return;
    
    _moveCount++;
    
    // Update button speed based on move count
    _buttonSpeed.value = 1.0 + min(_moveCount * 0.15, 3.0);
    
    // Delegate movement to current strategy
    final newPosition = _movementStrategy.getNextPosition(
      currentPosition: _position,
      previousPositions: _previousPositions,
      screenSize: _screenSize,
      buttonSize: Size(buttonWidth, buttonHeight),
      moveCount: _moveCount,
    );
    
    // Check if button is cornered
    _checkIfCornered(newPosition);
    
    // Update position and history
    _position = newPosition;
    
    // Add to history and maintain history limit
    _previousPositions.add(_position);
    if (_previousPositions.length > _historyLimit) {
      _previousPositions.removeAt(0);
    }
    
    // Use a single notifyListeners call for performance
    notifyListeners();
  }
  
  // Check if button is cornered (near screen edges)
  void _checkIfCornered(Offset position) {
    final edgeThreshold = 20.0;
    
    final isNearLeftEdge = position.dx < edgeThreshold;
    final isNearRightEdge = position.dx > _screenSize.width - buttonWidth - edgeThreshold;
    final isNearTopEdge = position.dy < edgeThreshold;
    final isNearBottomEdge = position.dy > _screenSize.height - buttonHeight - edgeThreshold;
    
    _isCornered = (isNearLeftEdge && (isNearTopEdge || isNearBottomEdge)) || 
                  (isNearRightEdge && (isNearTopEdge || isNearBottomEdge));
  }
  
  // Reset move count and positions
  void reset() {
    _moveCount = 0;
    _previousPositions.clear();
    _buttonSpeed.value = 1.0;
    _isCornered = false;
    _movementStrategy = BasicMovementStrategy();
    
    if (_screenSize != Size.zero) {
      _position = Offset(
        (_screenSize.width - buttonWidth) / 2,
        (_screenSize.height - buttonHeight) / 2,
      );
      _previousPositions.add(_position);
    }
    notifyListeners();
  }
  
  @override
  void dispose() {
    _buttonSpeed.dispose();
    super.dispose();
  }
}

// Strategy pattern for button movement
abstract class MovementStrategy {
  Offset getNextPosition({
    required Offset currentPosition,
    required List<Offset> previousPositions,
    required Size screenSize,
    required Size buttonSize,
    required int moveCount,
  });
  
  // Helper method to ensure button stays within bounds
  Offset _ensureWithinBounds(Offset position, Size screenSize, Size buttonSize) {
    return Offset(
      position.dx.clamp(0, screenSize.width - buttonSize.width),
      position.dy.clamp(0, screenSize.height - buttonSize.height),
    );
  }
  
  // Check if a position is too close to previous positions
  bool _isTooCloseToHistory(
    Offset position, 
    List<Offset> history, 
    double minDistance
  ) {
    return history.any((pos) => (pos - position).distance < minDistance / 2);
  }
}

// Basic movement strategy (random jumps)
class BasicMovementStrategy extends MovementStrategy {
  final Random _random = Random();
  
  @override
  Offset getNextPosition({
    required Offset currentPosition,
    required List<Offset> previousPositions,
    required Size screenSize,
    required Size buttonSize,
    required int moveCount,
  }) {
    // Calculate dynamic distance range
    final minDistance = 100.0 + min(moveCount * 5, 50).toDouble();
    final maxDistance = 250.0 + min(moveCount * 10, 100).toDouble();
    
    // Calculate maximum allowed position
    final maxX = screenSize.width - buttonSize.width;
    final maxY = screenSize.height - buttonSize.height;
    
    if (maxX <= 0 || maxY <= 0) return currentPosition;
    
    // Try to find a valid position
    Offset newPosition;
    int attempts = 0;
    final maxAttempts = 10;
    
    do {
      // Calculate a random angle in radians
      final angle = _random.nextDouble() * 2 * pi;
      
      // Random distance between min and max
      final distance = minDistance + _random.nextDouble() * (maxDistance - minDistance);
      
      // Calculate new position using polar coordinates
      final deltaX = distance * cos(angle);
      final deltaY = distance * sin(angle);
      
      newPosition = Offset(
        currentPosition.dx + deltaX,
        currentPosition.dy + deltaY,
      );
      
      // Ensure within bounds
      newPosition = _ensureWithinBounds(newPosition, screenSize, buttonSize);
      
      attempts++;
      if (attempts >= maxAttempts) {
        // Pick a completely different spot
        newPosition = Offset(
          _random.nextDouble() * maxX,
          _random.nextDouble() * maxY,
        );
        break;
      }
      
    } while (_isTooCloseToHistory(newPosition, previousPositions, minDistance));
    
    return newPosition;
  }
}

// Advanced movement strategy (patterns and smarter evasion)
class AdvancedMovementStrategy extends MovementStrategy {
  final UnclickableButtonViewModel _viewModel;
  final Random _random = Random();
  MovementPattern _currentPattern;
  int _patternCounter = 0;
  
  AdvancedMovementStrategy(this._viewModel) 
      : _currentPattern = BasicMovementPattern();
  
  @override
  Offset getNextPosition({
    required Offset currentPosition,
    required List<Offset> previousPositions,
    required Size screenSize,
    required Size buttonSize,
    required int moveCount,
  }) {
    // Change patterns occasionally
    if (_patternCounter <= 0 || _random.nextDouble() < 0.2) {
      _selectNewPattern();
      _patternCounter = 2 + _random.nextInt(3); // Use pattern for 2-4 moves
    }
    _patternCounter--;
    
    // Calculate dynamic distance range
    final minDistance = 100.0 + min(moveCount * 8, 80).toDouble();
    final maxDistance = 250.0 + min(moveCount * 12, 120).toDouble();
    
    // Get next position from current pattern
    Offset newPosition = _currentPattern.getNextPosition(
      currentPosition: currentPosition,
      previousPositions: previousPositions,
      screenSize: screenSize,
      buttonSize: buttonSize,
      moveCount: moveCount,
      minDistance: minDistance,
      maxDistance: maxDistance,
    );
    
    // Double-jump occasionally at higher move counts
    if (moveCount > 5 && _random.nextDouble() < 0.15) {
      // Schedule a secondary move shortly after this one
      Future.delayed(const Duration(milliseconds: 180), () {
        _viewModel.moveButton();
      });
    }
    
    return _ensureWithinBounds(newPosition, screenSize, buttonSize);
  }
  
  // Select a new movement pattern
  void _selectNewPattern() {
    final patterns = [
      BasicMovementPattern(),
      CircularMovementPattern(),
      ZigzagMovementPattern(),
    ];
    _currentPattern = patterns[_random.nextInt(patterns.length)];
  }
}

// Troll movement strategy (unpredictable and mischievous)
class TrollMovementStrategy extends MovementStrategy {
  final UnclickableButtonViewModel _viewModel;
  final Random _random = Random();
  int _specialMoveCounter = 0;
  
  TrollMovementStrategy(this._viewModel);
  
  @override
  Offset getNextPosition({
    required Offset currentPosition,
    required List<Offset> previousPositions,
    required Size screenSize,
    required Size buttonSize,
    required int moveCount,
  }) {
    // Increase chance of special moves with attempt count
    final specialMoveChance = min(0.1 + (moveCount * 0.02), 0.5);
    
    // Special troll moves
    if (_random.nextDouble() < specialMoveChance) {
      _specialMoveCounter++;
      
      // Pick a special move
      final specialMoveType = _random.nextInt(4);
      switch (specialMoveType) {
        case 0: // Teleport to opposite side
          return _teleportMove(currentPosition, screenSize, buttonSize);
        case 1: // Triple jump
          _scheduleTripleJump();
          break;
        case 2: // Edge hugging
          return _edgeHuggingMove(currentPosition, screenSize, buttonSize);
        case 3: // Fake-out move (small move then big move)
          _scheduleFakeoutMove();
          return _smallJump(currentPosition, screenSize, buttonSize);
      }
    }
    
    // Fall back to a complex pattern
    MovementPattern pattern;
    
    // Cycle through different patterns
    final patternIndex = _specialMoveCounter % 3;
    switch (patternIndex) {
      case 0:
        pattern = CircularMovementPattern();
        break;
      case 1:
        pattern = ZigzagMovementPattern();
        break;
      default:
        pattern = FakeoutMovementPattern();
    }
    
    final minDistance = 120.0 + min(moveCount * 10, 100).toDouble();
    final maxDistance = 280.0 + min(moveCount * 15, 150).toDouble();
    
    return _ensureWithinBounds(
      pattern.getNextPosition(
        currentPosition: currentPosition,
        previousPositions: previousPositions,
        screenSize: screenSize,
        buttonSize: buttonSize,
        moveCount: moveCount,
        minDistance: minDistance,
        maxDistance: maxDistance,
      ),
      screenSize,
      buttonSize,
    );
  }
  
  // Special move: Teleport to opposite quadrant
  Offset _teleportMove(Offset current, Size screenSize, Size buttonSize) {
    final maxX = screenSize.width - buttonSize.width;
    final maxY = screenSize.height - buttonSize.height;
    
    // Determine current quadrant
    final isLeftSide = current.dx < screenSize.width / 2;
    final isTopSide = current.dy < screenSize.height / 2;
    
    // Move to opposite quadrant
    double newX, newY;
    if (isLeftSide) {
      newX = screenSize.width / 2 + _random.nextDouble() * (maxX - screenSize.width / 2);
    } else {
      newX = _random.nextDouble() * (screenSize.width / 2);
    }
    
    if (isTopSide) {
      newY = screenSize.height / 2 + _random.nextDouble() * (maxY - screenSize.height / 2);
    } else {
      newY = _random.nextDouble() * (screenSize.height / 2);
    }
    
    return Offset(newX, newY);
  }
  
  // Schedule a triple jump sequence
  void _scheduleTripleJump() {
    // First jump happens immediately
    // Schedule second and third jumps
    Future.delayed(const Duration(milliseconds: 150), () {
      _viewModel.moveButton();
      
      Future.delayed(const Duration(milliseconds: 150), () {
        _viewModel.moveButton();
      });
    });
  }
  
  // Special move: Hug the edges
  Offset _edgeHuggingMove(Offset current, Size screenSize, Size buttonSize) {
    final maxX = screenSize.width - buttonSize.width;
    final maxY = screenSize.height - buttonSize.height;
    
    // Determine which edge to hug
    final edgeType = _random.nextInt(4);
    
    switch (edgeType) {
      case 0: // Left edge
        return Offset(
          _random.nextDouble() * 30, // Close to left edge
          _random.nextDouble() * maxY,
        );
      case 1: // Right edge
        return Offset(
          maxX - _random.nextDouble() * 30, // Close to right edge
          _random.nextDouble() * maxY,
        );
      case 2: // Top edge
        return Offset(
          _random.nextDouble() * maxX,
          _random.nextDouble() * 30, // Close to top edge
        );
      default: // Bottom edge
        return Offset(
          _random.nextDouble() * maxX,
          maxY - _random.nextDouble() * 30, // Close to bottom edge
        );
    }
  }
  
  // Schedule a fake-out move
  void _scheduleFakeoutMove() {
    Future.delayed(const Duration(milliseconds: 80), () {
      _viewModel.moveButton(); // Big jump after small one
    });
  }
  
  // Small jump for fake-out
  Offset _smallJump(Offset current, Size screenSize, Size buttonSize) {
    final angle = _random.nextDouble() * 2 * pi;
    final distance = 30 + _random.nextDouble() * 20; // Small distance
    
    final deltaX = distance * cos(angle);
    final deltaY = distance * sin(angle);
    
    return _ensureWithinBounds(
      Offset(current.dx + deltaX, current.dy + deltaY),
      screenSize,
      buttonSize,
    );
  }
}

// Abstract pattern for movement
abstract class MovementPattern {
  final Random _random = Random();
  
  Offset getNextPosition({
    required Offset currentPosition,
    required List<Offset> previousPositions,
    required Size screenSize,
    required Size buttonSize,
    required int moveCount,
    required double minDistance,
    required double maxDistance,
  });
  
  // Helper to ensure button stays within bounds
  Offset ensureWithinBounds(Offset position, Size screenSize, Size buttonSize) {
    return Offset(
      position.dx.clamp(0, screenSize.width - buttonSize.width),
      position.dy.clamp(0, screenSize.height - buttonSize.height),
    );
  }
}

// Basic random movement pattern
class BasicMovementPattern extends MovementPattern {
  @override
  Offset getNextPosition({
    required Offset currentPosition,
    required List<Offset> previousPositions,
    required Size screenSize,
    required Size buttonSize,
    required int moveCount,
    required double minDistance,
    required double maxDistance,
  }) {
    // Calculate a random angle in radians
    final angle = _random.nextDouble() * 2 * pi;
    
    // Random distance between min and max
    final distance = minDistance + _random.nextDouble() * (maxDistance - minDistance);
    
    // Calculate new position using polar coordinates
    final deltaX = distance * cos(angle);
    final deltaY = distance * sin(angle);
    
    return ensureWithinBounds(
      Offset(currentPosition.dx + deltaX, currentPosition.dy + deltaY),
      screenSize,
      buttonSize,
    );
  }
}

// Circular movement pattern
class CircularMovementPattern extends MovementPattern {
  @override
  Offset getNextPosition({
    required Offset currentPosition,
    required List<Offset> previousPositions,
    required Size screenSize,
    required Size buttonSize,
    required int moveCount,
    required double minDistance,
    required double maxDistance,
  }) {
    // Get the screen center
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;
    
    // Calculate angle from center to current position
    final currentAngle = atan2(
      currentPosition.dy - centerY,
      currentPosition.dx - centerX,
    );
    
    // Move along the circle by a random amount
    final angleChange = pi / 4 + _random.nextDouble() * (pi / 2);
    final newAngle = currentAngle + angleChange;
    
    // Calculate radius (distance from center)
    final radius = minDistance + _random.nextDouble() * (maxDistance - minDistance);
    
    // Convert back to Cartesian coordinates
    final newX = centerX + radius * cos(newAngle);
    final newY = centerY + radius * sin(newAngle);
    
    return ensureWithinBounds(
      Offset(newX, newY),
      screenSize,
      buttonSize,
    );
  }
}

// Zigzag movement pattern
class ZigzagMovementPattern extends MovementPattern {
  @override
  Offset getNextPosition({
    required Offset currentPosition,
    required List<Offset> previousPositions,
    required Size screenSize,
    required Size buttonSize,
    required int moveCount,
    required double minDistance,
    required double maxDistance,
  }) {
    // Determine direction (horizontal or vertical zigzag)
    final isHorizontal = _random.nextBool();
    
    double newX, newY;
    
    if (isHorizontal) {
      // Move horizontally, zigzag vertically
      final direction = _random.nextBool() ? 1 : -1;
      newX = currentPosition.dx + direction * (minDistance + _random.nextDouble() * (maxDistance - minDistance));
      newY = currentPosition.dy + (moveCount % 2 == 0 ? 1 : -1) * (40 + _random.nextDouble() * 40);
    } else {
      // Move vertically, zigzag horizontally
      final direction = _random.nextBool() ? 1 : -1;
      newY = currentPosition.dy + direction * (minDistance + _random.nextDouble() * (maxDistance - minDistance));
      newX = currentPosition.dx + (moveCount % 2 == 0 ? 1 : -1) * (40 + _random.nextDouble() * 40);
    }
    
    return ensureWithinBounds(
      Offset(newX, newY),
      screenSize,
      buttonSize,
    );
  }
}

// Fake-out movement pattern (appears to go one way, then changes)
class FakeoutMovementPattern extends MovementPattern {
  @override
  Offset getNextPosition({
    required Offset currentPosition,
    required List<Offset> previousPositions,
    required Size screenSize,
    required Size buttonSize,
    required int moveCount,
    required double minDistance,
    required double maxDistance,
  }) {
    // Find the previous movement direction if available
    Offset previousDirection = Offset.zero;
    if (previousPositions.length >= 2) {
      final lastPos = previousPositions.last;
      final secondLastPos = previousPositions[previousPositions.length - 2];
      previousDirection = lastPos - secondLastPos;
      
      // Normalize
      final distance = previousDirection.distance;
      if (distance > 0) {
        previousDirection = previousDirection.scale(1/distance, 1/distance);
      }
    }
    
    // Calculate a perpendicular direction to fake out the user
    Offset perpendicularDirection;
    if (previousDirection != Offset.zero) {
      // Perpendicular is (y, -x) normalized
      perpendicularDirection = Offset(
        previousDirection.dy,
        -previousDirection.dx,
      );
      
      // Randomly flip direction
      if (_random.nextBool()) {
        perpendicularDirection = Offset(
          -perpendicularDirection.dx,
          -perpendicularDirection.dy,
        );
      }
    } else {
      // If no previous direction, use random
      final angle = _random.nextDouble() * 2 * pi;
      perpendicularDirection = Offset(cos(angle), sin(angle));
    }
    
    // Calculate distance
    final distance = minDistance + _random.nextDouble() * (maxDistance - minDistance);
    
    // Calculate new position
    final newX = currentPosition.dx + perpendicularDirection.dx * distance;
    final newY = currentPosition.dy + perpendicularDirection.dy * distance;
    
    return ensureWithinBounds(
      Offset(newX, newY),
      screenSize,
      buttonSize,
    );
  }
}

// Edge-hugging movement pattern
class EdgeHuggingMovementPattern extends MovementPattern {
  @override
  Offset getNextPosition({
    required Offset currentPosition,
    required List<Offset> previousPositions,
    required Size screenSize,
    required Size buttonSize,
    required int moveCount,
    required double minDistance,
    required double maxDistance,
  }) {
    final maxX = screenSize.width - buttonSize.width;
    final maxY = screenSize.height - buttonSize.height;
    
    // Determine which edge to stay near
    Offset newPosition;
    
    final edgeChoice = _random.nextInt(4);
    switch (edgeChoice) {
      case 0: // Left edge
        newPosition = Offset(
          _random.nextDouble() * 40,
          _random.nextDouble() * maxY,
        );
        break;
      case 1: // Right edge
        newPosition = Offset(
          maxX - _random.nextDouble() * 40,
          _random.nextDouble() * maxY,
        );
        break;
      case 2: // Top edge
        newPosition = Offset(
          _random.nextDouble() * maxX,
          _random.nextDouble() * 40,
        );
        break;
      default: // Bottom edge
        newPosition = Offset(
          _random.nextDouble() * maxX,
          maxY - _random.nextDouble() * 40,
        );
    }
    
    return ensureWithinBounds(newPosition, screenSize, buttonSize);
  }
} 