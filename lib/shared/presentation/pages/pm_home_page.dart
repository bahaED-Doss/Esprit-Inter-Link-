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
        'assets/icons/middle.png', // Ajout de l'icône middle
        'assets/icons/task.png',
        'assets/icons/interns.png',
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
  bool _taskClicked = false;
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
      Navigator.pushNamed(context, '/trophies_pm');
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
          body: Column(
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
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
                if (index == 3) {
                  _taskClicked = !_taskClicked;
                }
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: Image.asset('assets/icons/Home.png', width: 28),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/icons/project.png', width: 28),
                label: 'Project',
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
                icon: Image.asset(_taskClicked ? 'assets/icons/task.png' : 'assets/icons/task.png', width: 28),
                label: 'Task',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/icons/interns.png', width: 28),
                label: 'Interns',
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
                    Navigator.pushNamed(context, '/trophies_pm');
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
