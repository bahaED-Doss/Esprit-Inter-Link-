import 'package:flutter/material.dart';
import 'package:esprit_interlink/shared/widgets/achievement_unlock_screen.dart';
import 'package:esprit_interlink/shared/models/achievement_type.dart';

class TrophyModel {
  final String id;
  final String name;
  final String description;
  final int xpPoints;
  final String message;
  final bool locked;
  final String iconName;

  TrophyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.xpPoints,
    required this.message,
    required this.locked,
    required this.iconName,
  });
}

class StudentTrophiesPage extends StatelessWidget {
  final List<TrophyModel> trophies;
  static const Color redColor = Color(0xFF8B1C1C); // Utilise le rouge principal du projet

  const StudentTrophiesPage({Key? key, required this.trophies}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double maxCardWidth = screenWidth < 500 ? 180 : 220;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trophies', style: TextStyle(color: Colors.white)),
        backgroundColor: redColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.all(screenWidth < 400 ? 8.0 : 16.0),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: maxCardWidth,
            crossAxisSpacing: screenWidth < 400 ? 8 : 16,
            mainAxisSpacing: screenWidth < 400 ? 8 : 16,
            childAspectRatio: 0.85,
          ),
          itemCount: trophies.length,
          itemBuilder: (context, index) {
            final trophy = trophies[index];
            return GestureDetector(
              onLongPress: () {
                showDialog(
                  context: context,
                  builder: (ctx) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: AchievementUnlockScreen(
                      achievement: Achievement(
                        type: AchievementType.values.first, // à adapter si besoin
                        role: AchievementRole.student, // Ajout du paramètre manquant
                        title: trophy.name,
                        subtitle: trophy.description,
                        message: trophy.message,
                        icon: _iconFromName(trophy.iconName),
                        xpPoints: trophy.xpPoints,
                      ),
                    ),
                  ),
                );
              },
              child: Stack(
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    color: trophy.locked ? Colors.grey[200] : Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _iconFromName(trophy.iconName),
                            size: 48,
                            color: trophy.locked ? Colors.grey[400] : redColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            trophy.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: trophy.locked ? Colors.grey[400] : redColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            trophy.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: trophy.locked ? Colors.grey[400] : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome, size: 16, color: trophy.locked ? Colors.grey[400] : redColor),
                              const SizedBox(width: 4),
                              Text(
                                '+${trophy.xpPoints} XP',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: trophy.locked ? Colors.grey[400] : redColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (trophy.locked)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Icon(Icons.lock, size: 36, color: Colors.grey[500]),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

IconData _iconFromName(String name) {
  switch (name) {
    case 'user_check':
      return Icons.verified_user;
    case 'building':
      return Icons.apartment;
    case 'megaphone':
      return Icons.campaign;
    case 'documents':
      return Icons.description;
    case 'handshake':
      return Icons.handshake;
    case 'group':
      return Icons.groups;
    case 'folder_plus':
      return Icons.create_new_folder;
    case 'folders':
      return Icons.folder_special;
    case 'clipboard_check':
      return Icons.assignment_turned_in;
    case 'clipboards':
      return Icons.assignment;
    case 'flag':
      return Icons.flag;
    case 'trophy_star':
      return Icons.emoji_events;
    case 'briefcase':
      return Icons.work_outline;
    case 'checklist':
      return Icons.checklist;
    case 'star':
      return Icons.star;
    case 'book_check':
      return Icons.menu_book;
    case 'calendar':
      return Icons.calendar_today;
    case 'trophy':
      return Icons.emoji_events;
    default:
      return Icons.emoji_events;
  }
}
