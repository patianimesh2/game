import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:provider/provider.dart';
import 'settings_provider.dart';
class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  // Game constants
  static const int gridSize = 20; // Number of cells in each dimension
  static const int initialSnakeLength = 3;

  // Game state
  List<Offset> snake = [];
  Offset food = Offset.zero;
  String direction = 'right'; // 'up', 'down', 'left', 'right'
  int score = 0;
  Timer? gameTimer;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  void _initializeGame() {
    snake = [];
    // Initialize snake at the center of the board
    int startX = gridSize ~/ 2;
    int startY = gridSize ~/ 2;
    for (int i = 0; i < initialSnakeLength; i++) {
      snake.add(Offset((startX - i).toDouble(), startY.toDouble()));
    }
    direction = 'right';
    score = 0;
    _generateFood();
    _startGameLoop();
  }

  void _generateFood() {
    final random = Random();
    int foodX, foodY;
    do {
      foodX = random.nextInt(gridSize);
      foodY = random.nextInt(gridSize);
      food = Offset(foodX.toDouble(), foodY.toDouble());
    } while (snake.contains(food)); // Ensure food doesn't spawn on the snake
  }

  void _startGameLoop() {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    // Increased speed by directly setting a lower value for gameSpeed
    final gameSpeed = 100; // Example: Set a fixed lower value for increased speed
    gameTimer = Timer.periodic(Duration(milliseconds: gameSpeed.toInt()), (timer) {
      _moveSnake();
      _checkCollisions();
      _checkFoodCollision();
      setState(() {}); // Update the UI
    });
  }

  void _moveSnake() {
    setState(() {
      Offset newHead = snake.first;
      switch (direction) {
        case 'up':
          newHead = Offset(newHead.dx, newHead.dy - 1);
          break;
        case 'down':
          newHead = Offset(newHead.dx, newHead.dy + 1);
          break;
        case 'left':
          newHead = Offset(newHead.dx - 1, newHead.dy);
          break;
        case 'right':
          newHead = Offset(newHead.dx + 1, newHead.dy);
          break;
      }

      // Add the new head
      snake.insert(0, newHead);

      // Remove the tail if food wasn't eaten
      if (newHead != food) {
        snake.removeLast();
      }
    });
  }

  void _checkCollisions() {
    // Check wall collisions
    if (snake.first.dx < 0 ||
        snake.first.dx >= gridSize ||
        snake.first.dy < 0 ||
        snake.first.dy >= gridSize) {
      _gameOver();
    }

    // Check self-collision
    for (int i = 1; i < snake.length; i++) {
      if (snake.first == snake[i]) {
        _gameOver();
        break;
      }
    }
  }

  void _checkFoodCollision() {
    if (snake.first == food) {
      setState(() {
        score++;
      });
      _generateFood();
    }
  }

  void _gameOver() {
    gameTimer?.cancel();
    print('Game Over! Your score is: $score');
    _showGameOverDialog();
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over!'),
          content: Text('Your score is: $score'),
          actions: <Widget>[
            TextButton(
              child: const Text('Restart'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _initializeGame(); // Restart the game
              },
            ),
          ],
        );
      },
    );
  }

  void _changeDirection(String newDirection) {
    // Prevent reversing direction
    if (direction == 'up' && newDirection != 'down') {
      direction = newDirection;
    } else if (direction == 'down' && newDirection != 'up') {
      direction = newDirection;
    } else if (direction == 'left' && newDirection != 'right') {
      direction = newDirection;
    } else if (direction == 'right' && newDirection != 'left') {
      direction = newDirection;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snake Game'), // Use the title set in main.dart
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double cellSize = constraints.maxWidth / gridSize;
                return GestureDetector(
                  onVerticalDragUpdate: (details) {
 if (details.delta.dy > 0 && direction != 'up') {
 _changeDirection('down');
 } else if (details.delta.dy < 0 && direction != 'down') {
 _changeDirection('up');
 }
 },
              onHorizontalDragUpdate: (details) {
                if (details.delta.dx > 0 && direction != 'left') {
                  _changeDirection('right');
                } else if (details.delta.dx < 0 && direction != 'right') {
                  _changeDirection('left');
                }
              },
                  child: CustomPaint(
                    painter: SnakeGamePainter(
 snake: snake, food: food, gridSize: gridSize, cellSize: cellSize, snakeColor: settingsProvider.snakeColor, backgroundColor: settingsProvider.backgroundColor,
 ),
                    child: Container(),
                  ),
                ),
          ),
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Score: $score',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// CustomPainter to draw the snake and food
// CustomPainter to draw the snake and food
class SnakeGamePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;
  final int gridSize;
  final double cellSize;
  final Color snakeColor;
  final Color backgroundColor;
  final ui.Image? foodImage; // Make foodImage nullable

  SnakeGamePainter({
    required this.snake,
    required this.food,
    required this.gridSize,
    required this.cellSize,
    required this.snakeColor,
    required this.backgroundColor,
    this.foodImage, // Accept nullable foodImage
 });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw background
    final backgroundPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, backgroundPaint);

    // Draw snake
    final snakePaint = Paint()
      ..color = snakeColor
      ..style = PaintingStyle.fill;

    // Draw snake head with rounded corners
    if (snake.isNotEmpty) {
      final headRect = Rect.fromLTWH(snake.first.dx * cellSize, snake.first.dy * cellSize, cellSize, cellSize);
      canvas.drawRRect(RRect.fromRectAndRadius(headRect, const Radius.circular(5.0)), snakePaint);

      // Draw snake body segments
      for (int i = 1; i < snake.length; i++) {
        final segmentRect = Rect.fromLTWH(snake[i].dx * cellSize, snake[i].dy * cellSize, cellSize, cellSize);

        // Determine the direction of the segment relative to the previous one
        final dx = snake[i].dx - snake[i - 1].dx;
        final dy = snake[i].dy - snake[i - 1].dy;

        // Draw rounded rectangles for body segments
        if (dx != 0 || dy != 0) {
          RRect roundedRect;
          if (dx != 0) {
            // Horizontal segment
            roundedRect = RRect.fromRectAndRadius(segmentRect, Radius.circular(cellSize / 2));
          } else {
            // Vertical segment
            roundedRect = RRect.fromRectAndRadius(segmentRect, Radius.circular(cellSize / 2));
          }
          canvas.drawRRect(roundedRect, snakePaint);
        } else {
          // This case should ideally not happen in a valid snake game state
          canvas.drawRect(segmentRect, snakePaint);
        }
      }
    }

    // Draw food image
    if (foodImage != null) {
      final foodRect = Rect.fromLTWH(food.dx * cellSize, food.dy * cellSize, cellSize, cellSize);
      canvas.drawImageRect(foodImage!, Rect.fromLTWH(0, 0, foodImage!.width.toDouble(), foodImage!.height.toDouble()), foodRect, Paint());
    } else {
      // Draw a placeholder if the image is not loaded
      canvas.drawRect(Rect.fromLTWH(food.dx * cellSize, food.dy * cellSize, cellSize, cellSize), Paint()..color = Colors.red);
    }
    // Draw background
    final backgroundPaint = Paint()
      ..color = backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Draw food
    // Use an Image widget for food
    final foodRect = Rect.fromLTWH(food.dx * cellSize, food.dy * cellSize, cellSize, cellSize);

    if (foodImage != null) {
      canvas.drawImageRect(foodImage!, Rect.fromLTWH(0, 0, foodImage!.width.toDouble(), foodImage!.height.toDouble()), foodRect, Paint());
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repaint when snake or food position changes
    return true;
  }
}