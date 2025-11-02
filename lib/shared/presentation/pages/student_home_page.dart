import 'package:flutter/material.dart';
import '../widgets/zoomable_image.dart';
import 'notification_page.dart';
import '../todo/saved_offers_page.dart';
import '../../../features/ats/ats_page.dart';
import '../../../features/tasks/presentation/pages/student_task_view.dart';
import '../../../data/datasources/local/database_helper.dart';

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
  int? floatingIndex; // Pour l'échange
  String? floatingMessage;
  int? popoverSelectedIndex;
  int _selectedIndex = 0;
  bool _quizClicked = false;
  bool _candidatesClicked = false;
  List<String> icons = [
    'assets/icons/Home.png',
    'assets/icons/internshipD.png',
    'assets/icons/middle.png',
    'assets/icons/cv.png',
    'assets/icons/Save.png',
  ];
  List<String> savedOffers = [];

  // Nouveau: informations sur l'étudiant et le projet assigné
  final String _studentEmail = 'student@esprit.tn'; // assumption: demo student
  int? _studentId;
  int? _assignedProjectId;
  String? _assignedProjectName;

  @override
  void initState() {
    super.initState();
    _initStudentData();
  }

  Future<void> _initStudentData() async {
    // Ensure mock projects exist
    await DatabaseHelper.initializeMockProjectsIfNeeded();

    // Récupérer l'utilisateur demo
    final db = await DatabaseHelper.database;
    final users = await db.query('users', where: 'email = ?', whereArgs: [_studentEmail], limit: 1);
    if (users.isNotEmpty) {
      final u = users.first;
      setState(() {
        _studentId = u['id'] as int?;
        hasInternship = (u['internship_status'] as String?) == 'INTERN';
      });
    }

    // Récupérer le projet assigné à cet email (s'il existe)
    final project = await DatabaseHelper.getProjectAssignedToStudent(_studentEmail);
    if (project != null) {
      setState(() {
        _assignedProjectId = project['id'] as int?;
        _assignedProjectName = project['name'] as String?;
      });
    }
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
    // Calculer la position du doigt par rapport au popover
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localOffset = box.globalToLocal(details.globalPosition);
    // Popover centré, largeur ~3*60=180, hauteur ~100, bottom: 70
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
      // Edit
      setState(() {
        isEditing = true;
        isFloating = true;
        showPopover = true;
        floatingMessage = null;
      });
    } else if (index == 2) {
      // Trophies
      Navigator.pushNamed(context, '/trophies');
      setState(() {
        showPopover = false;
      });
    } else if (index == 0) {
      // Project (si l'étudiant a un stage)
      if (hasInternship) {
        // Naviguer vers la page projet (si besoin) - pour l'instant on ferme simplement
        setState(() {
          showPopover = false;
        });
      }
    } else if (index == 1) {
      // Tasks (si l'étudiant a un stage)
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
        // Aucun projet assigné ou pas encore d'internship
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
    return Stack(
      children: [
        Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          body: _selectedIndex == 4
              ? SavedOffersPage(savedOffers: savedOffers)
              : Column(
                  children: [
                    SafeArea(
                      top: true,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        color: const Color(0xFF821E23),
                        child: Row(
                          children: [
                            CircleAvatar(radius: 18, backgroundImage: AssetImage('assets/icons/avatar.png')),
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
                    // Checkbox en haut
                    Padding(
                      padding: const EdgeInsets.only(top: 32, left: 16, right: 16, bottom: 8),
                      child: Row(
                        children: [
                          Checkbox(
                            value: hasInternship,
                            activeColor: const Color(0xFF8B1C1C),
                            onChanged: (v) async {
                              final newVal = v ?? false;
                              setState(() => hasInternship = newVal);

                              // Persister le statut dans la DB
                              await DatabaseHelper.updateStudentInternshipStatus(_studentEmail, newVal ? 'INTERN' : 'CANDIDATE');

                              if (newVal) {
                                // Devenir intern -> assigner automatiquement le premier projet disponible
                                final assignedId = await DatabaseHelper.assignFirstAvailableProjectToStudent(_studentEmail);
                                if (assignedId != null) {
                                  final proj = await DatabaseHelper.getProjectAssignedToStudent(_studentEmail);
                                  setState(() {
                                    _assignedProjectId = proj?['id'] as int?;
                                    _assignedProjectName = proj?['name'] as String?;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Assigned to project #$assignedId: ${_assignedProjectName ?? ''}')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('No available project to assign')),
                                  );
                                }
                              } else {
                                // Revenir candidat -> désassigner les projets du student
                                final count = await DatabaseHelper.unassignProjectsFromStudent(_studentEmail);
                                setState(() {
                                  _assignedProjectId = null;
                                  _assignedProjectName = null;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Unassigned $count project(s) from student')),
                                );
                              }
                            },
                          ),
                          const Text(
                            'Student has internship',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ],
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
                                          // Navigation vers AtsPage (Upload CV)
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => const AtsPage()),
                                          );
                                        } else if (i == 1) {
                                          _candidatesClicked = !_candidatesClicked;
                                        }
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      child: Image.asset(
                                        i == 3
                                            ? (_quizClicked ? 'assets/icons/cv.png' : icons[3])
                                            : i == 1
                                                ? (_candidatesClicked ? 'assets/icons/internship.png' : icons[1])
                                                : i == 4
                                                    ? (_selectedIndex == 4 ? 'assets/icons/Save icon red.png' : icons[4])
                                                    : icons[i],
                                        width: 28,
                                        color: _selectedIndex == i && i != 1 && i != 4 ? const Color(0xFF8B1C1C) : null,
                                      ),
                                    ),
                                  ),
                        ],
                      ),
              ),
              // Overlay gris qui bloque uniquement le contenu principal (pas la barre)
              if (isEditing)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 70,
                  top: 0,
                  child: GestureDetector(
                    onTap: () => setState(() {
                      isEditing = false;
                      isFloating = false;
                      floatingIndex = null;
                      floatingMessage = null;
                    }),
                    child: Container(
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ),
                ),
              if (isEditing)
                Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF8B1C1C),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => setState(() {
                        isEditing = false;
                        isFloating = false;
                        floatingIndex = null;
                        floatingMessage = null;
                      }),
                      child: const Text('Done'),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // Overlay gris pour popover ou édition, mais SOUS la popover
        if (showPopover || isFloating)
          GestureDetector(
            onTap: _onCancelFloating,
            child: Container(
              color: Colors.black.withOpacity(0.4),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        // Popover TOUJOURS AU-DESSUS
        if (showPopover || isFloating)
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B1C1C),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'these features will be unlocked once you become an intern .',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Project
                              GestureDetector(
                                child: Container(
                                  decoration: popoverSelectedIndex == 0
                                      ? BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        )
                                      : null,
                                  padding: const EdgeInsets.all(4),
                                  child: Column(
                                    children: [
                                      Opacity(
                                        opacity: hasInternship ? 1 : 0.4,
                                        child: Image.asset('assets/icons/project.png', width: 36, color: popoverSelectedIndex == 0 ? const Color(0xFF8B1C1C) : Colors.white),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('Project', style: TextStyle(color: popoverSelectedIndex == 0 ? const Color(0xFF8B1C1C) : Colors.white, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              // Tasks
                              GestureDetector(
                                child: Container(
                                  decoration: popoverSelectedIndex == 1
                                      ? BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        )
                                      : null,
                                  padding: const EdgeInsets.all(4),
                                  child: Column(
                                    children: [
                                      Opacity(
                                        opacity: hasInternship ? 1 : 0.4,
                                        child: Image.asset('assets/icons/task.png', width: 36, color: popoverSelectedIndex == 1 ? const Color(0xFF8B1C1C) : Colors.white),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('tasks', style: TextStyle(color: popoverSelectedIndex == 1 ? const Color(0xFF8B1C1C) : Colors.white, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              // Trophies
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    popoverSelectedIndex = 2;
                                  });
                                  _onSelectPopover(2);
                                },
                                child: Container(
                                  decoration: popoverSelectedIndex == 2
                                      ? BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        )
                                      : null,
                                  padding: const EdgeInsets.all(4),
                                  child: Column(
                                    children: [
                                      Opacity(
                                        opacity: hasInternship ? 1 : 0.4,
                                        child: Image.asset('assets/icons/trophy.png', width: 36, color: popoverSelectedIndex == 2 ? const Color(0xFF8B1C1C) : Colors.white),
                                      ),
                                      const SizedBox(height: 4),
                                      Text('trophies', style: TextStyle(color: popoverSelectedIndex == 2 ? const Color(0xFF8B1C1C) : Colors.white, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              // Edit
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    popoverSelectedIndex = 3;
                                  });
                                  _onSelectPopover(3);
                                },
                                child: Container(
                                  decoration: popoverSelectedIndex == 3
                                      ? BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                        )
                                      : null,
                                  padding: const EdgeInsets.all(4),
                                  child: Column(
                                    children: [
                                      Image.asset('assets/icons/Edit.png', width: 36, color: popoverSelectedIndex == 3 ? const Color(0xFF8B1C1C) : Colors.white),
                                      const SizedBox(height: 4),
                                      Text('edit bar', style: TextStyle(color: popoverSelectedIndex == 3 ? const Color(0xFF8B1C1C) : Colors.white, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    CustomPaint(
                      size: const Size(24, 12),
                      painter: _PopoverArrowPainter(),
                    ),
                    if (floatingMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          floatingMessage!,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
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
