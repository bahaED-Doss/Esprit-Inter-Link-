import 'package:flutter/material.dart';

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
            return _TrophyCard(trophy: trophy, redColor: redColor);
          },
        ),
      ),
    );
  }
}

class _TrophyCard extends StatelessWidget {
  final TrophyModel trophy;
  final Color redColor;

  const _TrophyCard({required this.trophy, required this.redColor});

  @override
  Widget build(BuildContext context) {
    final bool isLocked = trophy.locked;
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: isLocked ? null : () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Trophy: ${trophy.name}')),
            );
          },
          child: Opacity(
            opacity: isLocked ? 0.5 : 1.0,
            child: Card(
              elevation: isLocked ? 1 : 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              color: Colors.white,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: constraints.maxHeight,
                  minHeight: 120,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: isLocked ? Colors.grey[300] : redColor,
                          child: Icon(
                            _getIconData(trophy.iconName),
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          trophy.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: isLocked ? Colors.grey : redColor,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trophy.description,
                          style: TextStyle(
                            fontSize: 11,
                            color: isLocked ? Colors.grey[600] : Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.flash_on, color: isLocked ? Colors.grey : redColor, size: 13),
                            const SizedBox(width: 3),
                            Text(
                              '+${trophy.xpPoints} XP',
                              style: TextStyle(
                                color: isLocked ? Colors.grey : redColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        if (!isLocked) ...[
                          const SizedBox(height: 4),
                          Text(
                            trophy.message,
                            style: TextStyle(
                              color: redColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'star':
        return Icons.star;
      case 'bag':
        return Icons.work;
      case 'medal':
        return Icons.emoji_events;
      case 'rocket':
        return Icons.rocket_launch;
      default:
        return Icons.emoji_events;
    }
  }
}
