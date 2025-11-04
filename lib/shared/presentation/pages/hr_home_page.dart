import 'package:flutter/material.dart';
import '../widgets/zoomable_image.dart';
import 'notification_page.dart';
import '../todo/saved_candidates_page.dart';
import '../../data/notification_service.dart';

class HRHomePage extends StatelessWidget {
  final int userId;
  const HRHomePage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _HomePageMock(
      title: 'HR Home',
      screenshot: 'assets/images/Screenshot.png',
      color: const Color(0xFF821E23),
      icons: [
        'assets/icons/Home.png',
        'assets/icons/internship.png',
        'assets/icons/middle.png',
        'assets/icons/candidates.png',
        'assets/icons/Save.png',
      ],
      userId: userId,
    );
  }
}

class _HomePageMock extends StatefulWidget {
  final String title;
  final String screenshot;
  final Color color;
  final List<String> icons;
  final int userId;
  const _HomePageMock({required this.title, required this.screenshot, required this.color, required this.icons, required this.userId});

  @override
  State<_HomePageMock> createState() => _HomePageMockState();
}

class _HomePageMockState extends State<_HomePageMock> {
  int _selectedIndex = 0;
  List<String> savedCandidates = [];
  bool _candidatesClicked = false;
  bool _showPopover = false;
  int? _popoverSelectedIndex;

  void _onLongPressStartMiddleButton(LongPressStartDetails details) {
    setState(() {
      _showPopover = true;
      _popoverSelectedIndex = null;
    });
  }

  void _onLongPressMoveUpdateMiddleButton(LongPressMoveUpdateDetails details, BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    final double popoverWidth = 80;
    final double popoverHeight = 80;
    final Size screenSize = MediaQuery.of(context).size;
    final double popoverLeft = (screenSize.width - popoverWidth) / 2;
    final double popoverTop = screenSize.height - 70 - popoverHeight;
    if (localOffset.dy > popoverTop && localOffset.dy < popoverTop + popoverHeight) {
      double x = localOffset.dx - popoverLeft;
      int idx = (x / (popoverWidth / 1)).floor();
      if (idx < 0) idx = 0;
      if (idx > 0) idx = 0;
      setState(() {
        _popoverSelectedIndex = idx;
      });
    } else {
      setState(() {
        _popoverSelectedIndex = null;
      });
    }
  }

  void _onLongPressEndMiddleButton(LongPressEndDetails details) {
    if (_popoverSelectedIndex == 0) {
      Navigator.pushNamed(context, '/trophies_hr');
    }
    setState(() {
      _showPopover = false;
      _popoverSelectedIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
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
                            CircleAvatar(radius: 18, backgroundImage: AssetImage('assets/icons/avatar.png')),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Container(
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha((0.15 * 255).round()),
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
                                  MaterialPageRoute(builder: (_) => NotificationPage(userId: widget.userId)),
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
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
                if (index == 1) {
                  // Navigate to HR internship management
                  Navigator.pushNamed(context, '/hr_internship_splash');
                } else if (index == 3) {
                  _candidatesClicked = !_candidatesClicked;
                }
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Image.asset('assets/icons/Home.png', width: 28),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/icons/internship.png', width: 28),
                label: 'Internship',
              ),
              BottomNavigationBarItem(
                icon: GestureDetector(
                  onLongPressStart: _onLongPressStartMiddleButton,
                  onLongPressMoveUpdate: (details) => _onLongPressMoveUpdateMiddleButton(details, context),
                  onLongPressEnd: _onLongPressEndMiddleButton,
                  child: Image.asset('assets/icons/middle.png', width: 36),
                ),
                label: 'Trophies',
              ),
              BottomNavigationBarItem(
                icon: Image.asset(_candidatesClicked ? 'assets/icons/candidatesR.png' : 'assets/icons/candidates.png', width: 28),
                label: 'Candidates',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/icons/Save.png', width: 28),
                label: 'Saved',
              ),
            ],
          ),
        ),
        if (_showPopover)
          ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  _showPopover = false;
                  _popoverSelectedIndex = null;
                });
              },
              child: Container(
                color: Colors.black.withOpacity(0.4),
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Positioned(
              bottom: 70,
              left: MediaQuery.of(context).size.width / 2 - 40,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/trophies_hr');
                    setState(() {
                      _showPopover = false;
                      _popoverSelectedIndex = null;
                    });
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B1C1C),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/icons/trophy.png', width: 36, color: Colors.white),
                        const SizedBox(height: 4),
                        const Text('Trophies', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
      ],
    );
  }
}
