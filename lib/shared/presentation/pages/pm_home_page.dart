import 'package:flutter/material.dart';
import 'notification_page.dart';
import '../../../features/tasks/presentation/pages/project_selector_page.dart';
import '../../data/notification_service.dart';
import '../../providers/user_session_provider.dart';
import 'package:provider/provider.dart';

class PMHomePage extends StatelessWidget {
  const PMHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _HomePageMock(
      title: 'PM Home',
      screenshot: 'assets/images/hmpimg.png',
      color: const Color(0xFF821E23),
      icons: [
        'assets/icons/Home.png',
        'assets/icons/project.png',
        'assets/icons/middle.png',
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
  int _unreadCount = 0;
  int? _pmId;

  @override
  void initState() {
    super.initState();
    _initPMData();
    _loadUnreadCount();
  }

  Future<void> _initPMData() async {
    setState(() {
      _pmId = 1;
    });
  }

  Future<void> _loadUnreadCount() async {
    if (_pmId != null) {
      final count = await NotificationService.getUnreadCount(_pmId!);
      setState(() {
        _unreadCount = count;
      });
    }
  }

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
    final userSession = context.watch<UserSessionProvider?>();
    final String userName = userSession?.userName ?? '';
    final String greeting = userName.isNotEmpty ? 'Hello $userName' : 'Hello Project Manager';

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: Column(
            children: [
              // TOP BAR
              SafeArea(
                top: true,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: widget.color,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/role_select', (r) => false),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white.withAlpha((0.08 * 255).round()),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/icons/avatar.png',
                              width: 36,
                              height: 36,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset('assets/icons/userIcon.png', width: 36, height: 36, fit: BoxFit.cover);
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.15 * 255).round()),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              SizedBox(width: 12),
                              Icon(Icons.search, color: Colors.white70, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text('Search', style: TextStyle(color: Colors.white70, fontSize: 16)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () async {
                          if (_pmId != null) {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NotificationPage(userId: _pmId!),
                              ),
                            );
                            await _loadUnreadCount();
                          }
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                            if (_unreadCount > 0)
                              Positioned(
                                right: -6,
                                top: -6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _unreadCount > 9 ? '9+' : '$_unreadCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // MAIN CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        greeting,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                      ),
                      const SizedBox(height: 16),

                      // BANNER WITH IMAGE OVERLAY
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                widget.screenshot,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (c, e, s) => Container(
                                  color: const Color(0xFFEFEFEF),
                                  child: const Center(
                                    child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                                  ),
                                ),
                              ),
                              // Dark overlay for better text visibility
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.5),
                                      Colors.black.withValues(alpha: 0.1),
                                    ],
                                  ),
                                ),
                              ),
                              // Text and button overlay
                              Positioned(
                                top: 20,
                                left: 20,
                                right: 20,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Manage your projects\neffectively',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_pmId != null) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProjectSelectorPage(pmId: _pmId!),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: widget.color,
                                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'View Projects',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                      const Text(
                        'Quick Actions',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                      ),
                      const SizedBox(height: 16),

                      // Quick action cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.folder_outlined,
                              label: 'Projects',
                              color: const Color(0xFFE3F2FD),
                              onTap: () {
                                if (_pmId != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProjectSelectorPage(pmId: _pmId!),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildQuickActionCard(
                              icon: Icons.people_outline,
                              label: 'Team',
                              color: const Color(0xFFFFF3E0),
                              onTap: () {
                                // Navigate to team page
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // BOTTOM NAVIGATION BAR
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
                if (index == 1) {
                  // Navigate to projects
                  if (_pmId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectSelectorPage(pmId: _pmId!),
                      ),
                    );
                  }
                } else if (index == 3) {
                  _taskClicked = !_taskClicked;
                  if (_pmId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectSelectorPage(pmId: _pmId!),
                      ),
                    );
                  }
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
                label: 'Projects',
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
                icon: Image.asset('assets/icons/task.png', width: 28),
                label: 'Task',
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/icons/interns.png', width: 28),
                label: 'Interns',
              ),
            ],
          ),
        ),

        // POPOVER
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
                color: Colors.black.withAlpha((0.4 * 255).round()),
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

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: const Color(0xFF821E23)),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
