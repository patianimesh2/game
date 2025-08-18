import 'package:flutter/material.dart';
import 'dart:async';
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
    final gameSpeed = (11 - settingsProvider.snakeSpeed) * 50; // Map speed 1-10 to milliseconds (slower to faster)
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
    // TODO: Implement game over UI
    print('Game Over! Your score is: $score');
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
                  // Add background color to the GestureDetector or a Container below it
                  child: Container(
                    color: settingsProvider.backgroundColor, // Use background color from settings
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
                    painter: SnakeGamePainter(snake: snake, food: food, gridSize: gridSize, cellSize: cellSize, snakeColor: settingsProvider.snakeColor),
                    child: Container(), // Empty container to provide a surface for drawing
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
class SnakeGamePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;
  final int gridSize;
  final double cellSize;
  final Color snakeColor; // Use snake color from settings

  SnakeGamePainter({required this.snake, required this.food, required this.gridSize, required this.cellSize, required this.snakeColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw snake
    final snakePaint = Paint()
      ..color = snakeColor // Use the passed snake color
      ..style = PaintingStyle.fill;
    for (var segment in snake) {
      canvas.drawRect(Rect.fromLTWH(segment.dx * cellSize, segment.dy * cellSize, cellSize, cellSize), snakePaint);
    }

    // Draw food
    // Use an Image widget for food
    // Replace 'assets/food_image.png' with the actual path to your food image
    final foodImage = Image.asset('assets/food_image.png');
    final foodRect = Rect.fromLTWH(food.dx * cellSize, food.dy * cellSize, cellSize, cellSize);

    // Draw the image onto the canvas
    // You'll need to load the image asynchronously and redraw when it's ready.
    // For simplicity here, I'm assuming the image is loaded synchronously for now.
    // A more robust solution would use Image.resolve and listen for changes.
    // This part will require more complex image loading logic.
    // For now, this is a placeholder.
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Repaint when snake or food position changes
    return true;
  }
}