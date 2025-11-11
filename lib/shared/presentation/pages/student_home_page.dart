import 'package:flutter/material.dart';
import 'notification_page.dart';
import '../todo/saved_offers_page.dart';
import '../../../features/ats/ats_page.dart';
import '../../../features/tasks/presentation/pages/student_task_view.dart';
import '../../../data/datasources/local/database_helper.dart';
import '../../data/notification_service.dart';
import '../../providers/user_session_provider.dart';
import 'package:provider/provider.dart';

class StudentHomePage extends StatefulWidget {
  const StudentHomePage({Key? key}) : super(key: key);

  @override
  State<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends State<StudentHomePage> {
  bool hasInternship = false;
  bool showPopover = false;
  bool isEditing = false;
  bool isFloating = false;
  int? editingIndex;
  int? floatingIndex;
  String? floatingMessage;
  int? popoverSelectedIndex;
  int _selectedIndex = 0;
  bool _quizClicked = false;
  bool _candidatesClicked = false;
  int _unreadCount = 0;
  List<String> icons = [
    'assets/icons/Home.png',
    'assets/icons/internshipD.png',
    'assets/icons/middle.png',
    'assets/icons/cv.png',
    'assets/icons/Save.png',
  ];
  List<String> savedOffers = [];

  // Mock data for recent offers
  final List<Map<String, dynamic>> _recentOffers = [
    {
      'logo': 'G',
      'company': 'Google Inc',
      'location': 'California, USA',
      'salary': '100dt/Mo',
      'title': 'Senior designer',
      'type': 'Full time',
    },
  ];

  final String _studentEmail = 'student@esprit.tn';
  int? _studentId;
  int? _assignedProjectId;
  String? _assignedProjectName;

  @override
  void initState() {
    super.initState();
    _initStudentData();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    if (_studentId != null) {
      final count = await NotificationService.getUnreadCount(_studentId!);
      setState(() {
        _unreadCount = count;
      });
    }
  }

  Future<void> _initStudentData() async {
    await DatabaseHelper.initializeMockProjectsIfNeeded();
    final db = await DatabaseHelper.database;
    final users = await db.query('users', where: 'email = ?', whereArgs: [_studentEmail], limit: 1);
    if (users.isNotEmpty) {
      final u = users.first;
      setState(() {
        _studentId = u['id'] as int?;
        hasInternship = (u['internship_status'] as String?) == 'INTERN';
      });
      await _refreshUnread();
    }
    final project = await DatabaseHelper.getProjectAssignedToStudent(_studentEmail);
    if (project != null) {
      setState(() {
        _assignedProjectId = project['id'] as int?;
        _assignedProjectName = project['name'] as String?;
      });
    }
  }

  Future<void> _refreshUnread() async {
    if (_studentId == null) return;
    final c = await DatabaseHelper.getUnreadNotificationCount(_studentId!);
    if (mounted) setState(() => _unreadCount = c);
  }

  void _onLongPressStartMiddleButton(LongPressStartDetails details) {
    setState(() {
      showPopover = true;
      isFloating = false;
      floatingIndex = null;
      floatingMessage = null;
      popoverSelectedIndex = null;
    });
  }

  void _onLongPressMoveUpdateMiddleButton(LongPressMoveUpdateDetails details, BuildContext context) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    final double popoverWidth = 220;
    final double popoverHeight = 100;
    final Size screenSize = MediaQuery.of(context).size;
    final double popoverLeft = (screenSize.width - popoverWidth) / 2;
    final double popoverTop = screenSize.height - 70 - popoverHeight;
    if (localOffset.dy > popoverTop && localOffset.dy < popoverTop + popoverHeight) {
      double x = localOffset.dx - popoverLeft;
      int idx = (x / (popoverWidth / 3)).floor();
      if (idx < 0) idx = 0;
      if (idx > 2) idx = 2;
      setState(() {
        popoverSelectedIndex = idx;
      });
    } else {
      setState(() {
        popoverSelectedIndex = null;
      });
    }
  }

  void _onLongPressEndMiddleButton(LongPressEndDetails details) {
    if (popoverSelectedIndex != null) {
      _onSelectPopover(popoverSelectedIndex!);
    } else {
      setState(() {
        showPopover = false;
      });
    }
    setState(() {
      popoverSelectedIndex = null;
    });
  }

  void _onSelectPopover(int index) {
    if (index == 3) {
      setState(() {
        isEditing = true;
        isFloating = true;
        showPopover = true;
        floatingMessage = null;
      });
    } else if (index == 2) {
      Navigator.pushNamed(context, '/trophies');
      setState(() {
        showPopover = false;
      });
    } else if (index == 0) {
      if (hasInternship) {
        setState(() {
          showPopover = false;
        });
      }
    } else if (index == 1) {
      if (hasInternship && _assignedProjectId != null && _studentId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StudentTaskView(
              projectId: _assignedProjectId!,
              userId: _studentId!,
              projectName: _assignedProjectName ?? 'Project',
            ),
          ),
        );
        setState(() {
          showPopover = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No assigned project or internship not confirmed yet')),
        );
      }
    }
  }

  void _onCancelFloating() {
    setState(() {
      isFloating = false;
      floatingIndex = null;
      floatingMessage = null;
      showPopover = false;
      isEditing = false;
    });
  }

  void _swapIcons(int i, int j) {
    setState(() {
      final tmp = icons[i];
      icons[i] = icons[j];
      icons[j] = tmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userSession = context.watch<UserSessionProvider?>();
    final String userName = userSession?.userName ?? '';
    final String greeting = userName.isNotEmpty ? 'Hey $userName' : 'Hey there';
    final bool isStudent = !hasInternship;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: _selectedIndex == 4
              ? SavedOffersPage(savedOffers: savedOffers)
              : Column(
                  children: [
                    // TOP BAR
                    SafeArea(
                      top: true,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        color: const Color(0xFF821E23),
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
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    SizedBox(width: 12),
                                    Icon(Icons.search, color: Colors.white70, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(child: Text('Search', style: TextStyle(color: Colors.white70, fontSize: 16))),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: () async {
                                if (_studentId != null) {
                                  final result = await Navigator.push<bool?>(
                                    context,
                                    MaterialPageRoute(builder: (_) => NotificationPage(userId: _studentId!)),
                                  );
                                  if (result == true) {
                                    await _initStudentData();
                                  } else {
                                    await _loadUnreadCount();
                                  }
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
                                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                                        child: Text(
                                          _unreadCount > 9 ? '9+' : '$_unreadCount',
                                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
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

                    // MAIN CONTENT - NEW DESIGN
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
                                      'assets/images/hmpimg.png',
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
                                          Text(
                                            isStudent ? 'Generate your Best\nResume/CV' : 'Time to shine, intern!\ncheck your tasks',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.w800,
                                              height: 1.2,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          ElevatedButton(
                                            onPressed: () {
                                              if (isStudent) {
                                                Navigator.push(context, MaterialPageRoute(builder: (_) => const AtsPage()));
                                              } else {
                                                if (_assignedProjectId != null && _studentId != null) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (_) => StudentTaskView(
                                                        projectId: _assignedProjectId!,
                                                        userId: _studentId!,
                                                        projectName: _assignedProjectName ?? 'Project',
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('No project assigned yet.')),
                                                  );
                                                }
                                              }
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.white,
                                              foregroundColor: const Color(0xFF821E23),
                                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: Text(
                                              isStudent ? 'Try Now' : 'Click here',
                                              style: const TextStyle(
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
                            const Text('Find Your Internship', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                            const SizedBox(height: 16),

                            // 3 Offer Type Cards
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildOfferTypeCard(
                                  icon: Icons.document_scanner,
                                  label: 'Remote ',
                                  color: const Color(0xFFE3F2FD),
                                  onTap: () => Navigator.pushNamed(context, '/internship_splash'),
                                ),
                                _buildOfferTypeCard(
                                  icon: Icons.work,
                                  label: 'Full Time',
                                  color: const Color(0xFFEDE7F6),
                                  onTap: () => Navigator.pushNamed(context, '/internship_splash'),
                                ),
                                _buildOfferTypeCard(
                                  icon: Icons.schedule,
                                  label: 'Part Time',
                                  color: const Color(0xFFFFF3E0),
                                  onTap: () => Navigator.pushNamed(context, '/internship_splash'),
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),
                            const Text('Recent offers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                            const SizedBox(height: 16),

                            // Recent Offer Card
                            ..._recentOffers.map((offer) => Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 4))
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: const Color(0xFFF1F1F1),
                                        child: Text(offer['logo'], style: const TextStyle(color: Color(0xFF821E23), fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(offer['title'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                            Text(offer['company'], style: const TextStyle(fontSize: 14, color: Color(0xFF666666))),
                                            const SizedBox(height: 4),
                                            Text(offer['location'], style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          Text(offer['salary'], style: const TextStyle(fontSize: 12, color: Color(0xFF821E23), fontWeight: FontWeight.w600)),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFF0E6),
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Text(offer['type'], style: const TextStyle(fontSize: 12, color: Color(0xFF821E23))),
                                          ),
                                          const SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF821E23),
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                              minimumSize: const Size(80, 32),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            child: const Text('Apply', style: TextStyle(fontSize: 12)),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

          // BOTTOM NAVIGATION BAR
          bottomNavigationBar: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, -2)),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: isEditing
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(icons.length, (i) {
                          return Draggable<int>(
                            data: i,
                            feedback: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: Image.asset(icons[i], width: 28),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.3,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Image.asset(icons[i], width: 28),
                              ),
                            ),
                            child: DragTarget<int>(
                              onAccept: (fromIndex) {
                                setState(() {
                                  final tmp = icons[fromIndex];
                                  icons[fromIndex] = icons[i];
                                  icons[i] = tmp;
                                });
                              },
                              builder: (context, candidateData, rejectedData) => CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Image.asset(icons[i], width: 28),
                              ),
                            ),
                          );
                        }),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          for (int i = 0; i < icons.length; i++)
                            i == 2
                                ? GestureDetector(
                                    onLongPressStart: _onLongPressStartMiddleButton,
                                    onLongPressMoveUpdate: (details) => _onLongPressMoveUpdateMiddleButton(details, context),
                                    onLongPressEnd: _onLongPressEndMiddleButton,
                                    onTap: null,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _selectedIndex == i ? const Color(0xFF8B1C1C) : Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 2)),
                                        ],
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Image.asset(
                                        icons[i],
                                        width: 32,
                                        color: _selectedIndex == i ? Colors.white : null,
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedIndex = i;
                                        if (i == 3) {
                                          Navigator.push(context, MaterialPageRoute(builder: (_) => const AtsPage()));
                                        } else if (i == 1) {
                                          Navigator.pushNamed(context, '/internship_splash');
                                        }
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: _selectedIndex == i ? const Color(0xFF8B1C1C) : Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Image.asset(
                                        icons[i],
                                        width: 28,
                                        color: _selectedIndex == i ? Colors.white : null,
                                      ),
                                    ),
                                  ),
                        ],
                      ),
              ),
            ],
          ),
        ),

        // POPOVER
        if (showPopover)
          GestureDetector(
            onTap: () => setState(() => showPopover = false),
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
        if (showPopover)
          Positioned(
            bottom: 70,
            left: MediaQuery.of(context).size.width / 2 - 100,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF8B1C1C), borderRadius: BorderRadius.circular(16)),
                child: const Text('Long press features', style: TextStyle(color: Colors.white, fontSize: 14)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOfferTypeCard({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF821E23)),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _PopoverArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8B1C1C)
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
