import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notification_page.dart';
import '../../data/notification_service.dart';
import '../../providers/user_session_provider.dart';
import '../../../data/datasources/local/database_helper.dart' as CoreDB;
import '../../../features/offres/presentation/pages/hr_applications_list_page.dart';
import 'package:intl/intl.dart';

class HRHomePage extends StatelessWidget {
  final int userId;
  const HRHomePage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _HomePageMock(
      title: 'HR Home',
      screenshot: 'assets/images/hmpimg.png',
      color: const Color(0xFF821E23),
      icons: const [],
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
  int _unreadCount = 0;
  bool _candidatesClicked = false;
  bool _showPopover = false;

  List<Map<String, dynamic>> _recentApplications = [];
  bool _isLoadingRecentApps = false;
  String? _recentAppsError;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    _loadRecentOpenApplications();
  }

  Future<void> _loadUnreadCount() async {
    try {
      final c = await NotificationService.getUnreadCount(widget.userId);
      if (mounted) setState(() => _unreadCount = c);
    } catch (_) {
      // ignore
    }
  }

  Future<void> _loadRecentOpenApplications() async {
    setState(() {
      _isLoadingRecentApps = true;
      _recentAppsError = null;
    });

    try {
      final db = await CoreDB.DatabaseHelper.database;
      final rows = await db.rawQuery('''
        SELECT a.*, i.title AS internshipTitle, i.companyName as companyName, i.status as internshipStatus
        FROM applications a
        INNER JOIN internships i ON a.internshipId = i.id
        WHERE a.status = 'PENDING'
        ORDER BY a.createdAt DESC
        LIMIT 3
      ''');
      final list = rows.map((r) => Map<String, dynamic>.from(r)).toList();
      if (mounted) setState(() => _recentApplications = list);
    } catch (e) {
      if (mounted) setState(() => _recentAppsError = e.toString());
    } finally {
      if (mounted) setState(() => _isLoadingRecentApps = false);
    }
  }

  void _onLongPressStartMiddleButton(LongPressStartDetails details) {
    setState(() {
      _showPopover = true;
    });
  }

  void _onLongPressMoveUpdateMiddleButton(LongPressMoveUpdateDetails details, BuildContext context) {
  }

  void _onLongPressEndMiddleButton(LongPressEndDetails details) {
  }

  @override
  Widget build(BuildContext context) {
    final userSession = context.watch<UserSessionProvider?>();
    final username = userSession?.userName ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          Column(
            children: [
              SafeArea(
                top: true,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: widget.color,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pushNamedAndRemoveUntil(context, '/role_select', (r) => false),
                        child: const CircleAvatar(radius: 18, backgroundImage: AssetImage('assets/icons/avatar.png')),
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
                              Expanded(child: Text('search here ', style: TextStyle(color: Colors.white70, fontSize: 16))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () async {
                          await Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationPage(userId: widget.userId)));
                          await _loadUnreadCount();
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
                                  decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                                  child: Text(_unreadCount > 9 ? '9+' : '$_unreadCount', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Hello $username\nLet\'s find the perfect match today', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 16),

                      // Banner: Image with text overlay
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
                                      'Find our best\ncandidates',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      onPressed: () async {
                                        if (_recentApplications.isNotEmpty) {
                                          final first = _recentApplications.first;
                                          final internshipId = (first['internshipId'] is int) ? first['internshipId'] as int : int.tryParse(first['internshipId']?.toString() ?? '') ?? 0;
                                          if (internshipId > 0) {
                                            await Navigator.push(context, MaterialPageRoute(builder: (_) => HRApplicationsListPage(internshipId: internshipId)));
                                            await _loadRecentOpenApplications();
                                          } else {
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No internship id')));
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No pending applications available.'), backgroundColor: Color(0xFF8B1C1C)));
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
                                        'View Applications',
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

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Recent Pending Applications', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                          GestureDetector(onTap: () {}, child: const Text('See all', style: TextStyle(color: Color(0xFF821E23)))),
                        ],
                      ),
                      const SizedBox(height: 16),

                      if (_isLoadingRecentApps) const Center(child: CircularProgressIndicator())
                      else if (_recentAppsError != null) Center(child: Text(_recentAppsError!))
                      else if (_recentApplications.isEmpty) const Center(child: Text('No recent pending applications found.'))
                      else
                        Column(
                          children: _recentApplications.map((app) {
                            final internshipTitle = app['internshipTitle'] ?? '';
                            final companyName = app['companyName'] ?? '';
                            final appStatus = app['status'] ?? 'PENDING';
                            final createdAt = app['createdAt'] != null ? DateTime.tryParse(app['createdAt']) : null;
                            final isPending = appStatus == 'PENDING';

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Color.fromRGBO(0,0,0,0.08), blurRadius: 8, offset: const Offset(0,4))]),
                              child: Row(
                                children: [
                                  Container(width: 8, height: 8, decoration: BoxDecoration(color: isPending ? Colors.orange : Colors.green, borderRadius: BorderRadius.circular(4))),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(internshipTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF1A1A2E))),
                                        const SizedBox(height: 4),
                                        Text(companyName, style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
                                        const SizedBox(height: 8),
                                        Row(children: [
                                          Expanded(child: Container(padding: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: isPending ? Color.fromRGBO(255,152,0,0.1) : Color.fromRGBO(76,175,80,0.1), borderRadius: BorderRadius.circular(16)), child: Text(appStatus, textAlign: TextAlign.center, style: TextStyle(color: isPending ? Colors.orange : Colors.green)))),
                                          const SizedBox(width: 8),
                                          Container(width: 1, height: 40, color: const Color(0xFFE0E0E0)),
                                          const SizedBox(width: 8),
                                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                            const Text('Applied on:', style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
                                            const SizedBox(height: 4),
                                            Text(createdAt != null ? DateFormat('MMM d, y').format(createdAt) : '', style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A2E))),
                                          ])
                                        ])
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_showPopover)
            ...[
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showPopover = false;
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
                      Navigator.pushNamed(context, '/trophies_hr');
                      setState(() {
                        _showPopover = false;
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
    );
  }
}

