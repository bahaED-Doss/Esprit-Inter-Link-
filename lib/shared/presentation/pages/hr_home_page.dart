import 'package:flutter/material.dart';
import '../widgets/zoomable_image.dart';
import 'notification_page.dart';
import '../todo/saved_candidates_page.dart';

class HRHomePage extends StatelessWidget {
  const HRHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _HomePageMock(
      title: 'HR Home',
      screenshot: 'assets/images/Screenshot.png',
      color: const Color(0xFF821E23),
      icons: [
        'assets/icons/Home.png',
        'assets/icons/internship.png',
        'assets/icons/candidates.png',
        'assets/icons/Save.png',
      ],
    );
  }
}

class _HomePageMock extends StatefulWidget {
  final String title;
  final String screenshot;
  final Color color;
  final List<String> icons;
  const _HomePageMock({required this.title, required this.screenshot, required this.color, required this.icons});

  @override
  State<_HomePageMock> createState() => _HomePageMockState();
}

class _HomePageMockState extends State<_HomePageMock> {
  int _selectedIndex = 0;
  List<String> savedCandidates = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _selectedIndex == 3
          ? SavedCandidatesPage(savedCandidates: savedCandidates)
          : Column(
              children: [
                SafeArea(
                  top: true,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: widget.color,
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
                          child: ZoomableImage(imagePath: widget.screenshot),
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
          children: [
            IconButton(
              icon: Image.asset(
                widget.icons[0],
                width: 28,
                color: _selectedIndex == 0 ? const Color(0xFF8B1C1C) : null,
              ),
              onPressed: () => setState(() => _selectedIndex = 0),
            ),
            IconButton(
              icon: Image.asset(
                _selectedIndex == 1 ? 'assets/icons/internship.png' : 'assets/icons/internshipD.png',
                width: 28,
              ),
              onPressed: () => setState(() => _selectedIndex = 1),
            ),
            IconButton(
              icon: Image.asset(
                widget.icons[2],
                width: 28,
                color: _selectedIndex == 2 ? const Color(0xFF8B1C1C) : null,
              ),
              onPressed: () => setState(() => _selectedIndex = 2),
            ),
            IconButton(
              icon: Image.asset(
                _selectedIndex == 3 ? 'assets/icons/Save icon red.png' : widget.icons[3],
                width: 28,
              ),
              onPressed: () => setState(() => _selectedIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}
