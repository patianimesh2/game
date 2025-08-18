import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Snake Speed:'),
            Consumer<SettingsProvider>(
              builder: (context, settings, child) {
                return Slider(
                  value: settings.snakeSpeed.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: settings.snakeSpeed.toString(),
                  onChanged: (newValue) {
                    settings.setSnakeSpeed(newValue);
                  },
                );
              },
            ),
            SizedBox(height: 20),
            Text('Snake Color:'),
            Consumer<SettingsProvider>(
              builder: (context, settings, child) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
 children: settings.availableSnakeColors.map((color) {
 return GestureDetector(
 onTap: () {
 settings.setSnakeColor(color);
 },
 child: Container(
 width: 40,
 height: 40,
 color: color,
 decoration: BoxDecoration(
 border: settings.snakeColor == color
 ? Border.all(color: Colors.black, width: 2.0)
 : null,
 ),
 ),
 );
 }).toList(),
                );
              },
            ),
            SizedBox(height: 40),
 Text('Background Color:'),
 Consumer<SettingsProvider>(
 builder: (context, settings, child) {
 return Row(
 mainAxisAlignment: MainAxisAlignment.spaceAround,
 children: settings.availableBackgroundColors.map((color) {
 return GestureDetector(
 onTap: () {
 settings.setBackgroundColor(color);
 },
 child: Container(
 width: 40,
 height: 40,
 color: color,
 decoration: BoxDecoration(
 border: settings.backgroundColor == color
 ? Border.all(color: Colors.black, width: 2.0)
 : null,
 ),
 ),
 );
 }).toList(),
 );
 },
 ),
 SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous screen
              },
              child: Text('Back to Game'),
            ),
          ],
        ),
      ),
    );
  }
}