import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  double _snakeSpeed = 5.0;
  Color _snakeColor = Colors.green;
  Color _backgroundColor = Colors.blueGrey[900]!;

  double get snakeSpeed => _snakeSpeed;
  Color get snakeColor => _snakeColor;
  Color get backgroundColor => _backgroundColor;

  // List of available colors for snake and background
  SettingsProvider() {
    _loadSettings();
  }

  void setSnakeSpeed(double speed) {
    _snakeSpeed = speed;
    notifyListeners();
    _saveSettings();
  }

  void setSnakeColor(Color color) {
    _snakeColor = color;
    notifyListeners();
    _saveSettings();
  }

  void setBackgroundColor(Color color) {
    _backgroundColor = color;
    notifyListeners();
    _saveSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _snakeSpeed = prefs.getDouble('snakeSpeed') ?? 5.0;
    final int? colorValue = prefs.getInt('snakeColor');
    if (colorValue != null) {
      _snakeColor = Color(colorValue);
    } else {
      _snakeColor = Colors.green;
    }
    final int? backgroundColorValue = prefs.getInt('backgroundColor');
    if (backgroundColorValue != null) {
      _backgroundColor = Color(backgroundColorValue);
    } else {
      _backgroundColor = Colors.blueGrey[900]!;
    }
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('snakeSpeed', _snakeSpeed);
    await prefs.setInt('snakeColor', _snakeColor.value);
    await prefs.setInt('backgroundColor', _backgroundColor.value);
  }
}