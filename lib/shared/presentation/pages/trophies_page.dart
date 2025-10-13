import 'package:flutter/material.dart';

class TrophiesPage extends StatelessWidget {
  const TrophiesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trophies'),
        backgroundColor: Color(0xFF8B1C1C),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.emoji_events, size: 80, color: Color(0xFF8B1C1C)),
            SizedBox(height: 24),
            Text('Your trophies will appear here!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text('Unlock achievements by progressing in your journey.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

