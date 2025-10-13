import 'package:flutter/material.dart';
import '../widgets/zoomable_image.dart';
import 'notification_page.dart';

class PMHomePage extends StatelessWidget {
  const PMHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _HomePageMock(
      title: 'PM Home',
      screenshot: 'assets/images/Screenshot.png',
      color: const Color(0xFF821E23),
      icons: [
        'assets/icons/Home.png',
        'assets/icons/project.png',
        'assets/icons/task.png',
        'assets/icons/interns.png',
      ],
    );
  }
}

class _HomePageMock extends StatelessWidget {
  final String title;
  final String screenshot;
  final Color color;
  final List<String> icons;
  const _HomePageMock({required this.title, required this.screenshot, required this.color, required this.icons});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          SafeArea(
            top: true,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: color,
              child: Row(
                children: [
                  CircleAvatar(radius: 18, backgroundImage: AssetImage('assets/images/avatar.png')),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          const Icon(Icons.search, color: Colors.white70, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text('Search', style: TextStyle(color: Colors.white70, fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Hey Wyvern team , this home page\nwill be filled later like this :",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Color(0xFF1A1A2E)),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 180,
                    height: 120,
                    child: ZoomableImage(imagePath: 'assets/images/Screenshot.png'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B1C1C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(context, '/role_select', (route) => false);
                    },
                    child: const Text('Back to Select User'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: icons.map((icon) => IconButton(icon: Image.asset(icon, width: 28), onPressed: () {})).toList(),
        ),
      ),
    );
  }
}
