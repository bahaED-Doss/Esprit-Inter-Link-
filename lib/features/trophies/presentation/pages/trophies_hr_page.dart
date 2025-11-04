import 'package:flutter/material.dart';
import '/shared/models/achievement_type.dart';
import '../widgets/common/achievement_unlock_screen.dart';

class TrophiesHRPage extends StatelessWidget {
  const TrophiesHRPage({super.key});

  @override
  Widget build(BuildContext context) {
    final trophies = Achievement.getAchievementsByRole(AchievementRole.hr);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trophées HR'),
        backgroundColor: const Color(0xFF8B1C1C),
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: trophies.length,
          itemBuilder: (context, index) {
            final trophy = trophies[index];
            return GestureDetector(
              onLongPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AchievementUnlockScreen(
                      achievement: trophy,
                      onContinue: () => Navigator.pop(context),
                    ),
                  ),
                );
              },
              child: Opacity(
                opacity: 0.4, // Toujours bloqué pour l'instant
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(trophy.icon, size: 48, color: Colors.grey[600]),
                      const SizedBox(height: 12),
                      Text(trophy.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text('Bloqué', style: TextStyle(color: Colors.grey)),
                      const Icon(Icons.lock, color: Colors.grey, size: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
