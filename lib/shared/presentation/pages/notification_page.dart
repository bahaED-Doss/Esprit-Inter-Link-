import 'package:flutter/material.dart';
import '../../../data/datasources/local/database_helper.dart' as CoreDB;
import '/../../shared/models/achievement_type.dart';
import '../../../features/trophies/presentation/widgets/common/achievement_unlock_screen.dart';
import '../../../features/aplication/data/application_repository.dart';
import '../../../features/aplication/presentation/pages/internship_details_page.dart';

class NotificationPage extends StatefulWidget {
  final int userId;
  const NotificationPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    // When HR opens the notification page we consider that they have seen notifications -> mark all read
    _future = _markAllReadAndLoad();
  }

  Future<List<Map<String, dynamic>>> _markAllReadAndLoad() async {
    try {
      await CoreDB.DatabaseHelper.markAllNotificationsRead(widget.userId);
    } catch (e) {
      print('⚠️ Failed to mark all notifications read: $e');
    }
    return await _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final items = await CoreDB.DatabaseHelper.getNotificationsForUser(widget.userId);
    final user = await CoreDB.DatabaseHelper.getUserById(widget.userId);
    final role = (user?['role'] ?? user?['userRole'] ?? '').toString().toLowerCase();

    // Filtrer les notifications 'Application accepted' pour le PM
    if (role == 'pm') {
      items.removeWhere((n) => ((n['type'] ?? '').toString() == 'APPLICATION_ACCEPTED' || (n['title'] ?? '').toString().toLowerCase().contains('application accepted')));
    }

    for (final n in items) {
      final type = (n['type'] ?? '').toString();
      final title = (n['title'] ?? '').toString();
      final refRaw = n['reference_id'] ?? n['referenceId'];
      if ((type == 'APPLICATION_ACCEPTED' ||
          title.toLowerCase().contains('application accepted')) &&
          refRaw != null) {
        final ref = refRaw is int ? refRaw : int.tryParse(refRaw.toString());
        if (ref != null) {
          try {
            final internship = await ApplicationRepository().getInternshipById(ref);
            if (internship != null) {
              final internshipName = (internship.title ?? '').toString();
              if (internshipName.isNotEmpty) {
                n['message'] = 'You have been accepted to $internshipName';
              }
            }
          } catch (e) {
            // Ignore si l'internship n'est pas récupéré
          }
        }
      }
    }
    return items;
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1C1C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Notifications', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => setState(() => _future = _load()),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/icons/IllustNotification.png', width: 180, height: 180),
                  const SizedBox(height: 32),
                  const Text(
                    'You have no notifications yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B1C1C),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final n = items[index];
              final id = n['id'] as int? ?? 0;
              final title = n['title'] as String? ??
                  n['message']?.toString() ?? 'Notification';
              final msg = n['message'] as String? ?? '';
              final type = n['type'] as String? ?? 'SYSTEM';
              final createdAt = (n['created_at'] as String?) ??
                  n['createdAt'] as String? ?? '';
              final isRead = (n['is_read'] ?? n['read'] ?? 0) as int;
              final referenceId = n['reference_id'] ?? n['referenceId'] ??
                  n['reference_id'];

              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    final user = await CoreDB.DatabaseHelper.getUserById(widget.userId);
                    final role = (user?['role'] ?? user?['userRole'] ?? '').toString().toLowerCase();
                    if ((type == 'APPLICATION_ACCEPTED' || title.toLowerCase().contains('application accepted')) && role == 'student' && referenceId != null) {
                      final ref = referenceId is int ? referenceId : int.tryParse(referenceId.toString());
                      if (ref != null) {
                        final internship = await ApplicationRepository().getInternshipById(ref);
                        if (internship != null) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => InternshipDetailsPage(
                                internship: internship,
                                studentId: widget.userId,
                              ),
                            ),
                          );
                          return;
                        }
                      }
                    }
                    if ((type == 'APPLICATION_ACCEPTED' || title.toLowerCase().contains('application accepted')) && role == 'hr' && referenceId != null) {
                      // Naviguer vers ApplicationDetailsPage si elle existe, sinon afficher un message
                      await Navigator.pushNamed(context, '/application_details', arguments: referenceId);
                      return;
                    }
                    try {
                      // Mark this notification as read in DB
                      await CoreDB.DatabaseHelper.markNotificationRead(id);
                    } catch (_) {}

                    // If the notification has a reference id, navigate to HR applications list
                    if (referenceId != null) {
                      final ref = referenceId is int ? referenceId : int
                          .tryParse(referenceId.toString());
                      if (ref != null) {
                        // Navigate to HR applications page for the internship id
                        await Navigator.pushNamed(
                            context, '/hr_applications', arguments: ref);
                      }
                    }

                    // Refresh the list to update read states
                    setState(() => _future = _load());
                  },
                  onDoubleTap: () async {
                    // Special behavior: for APPLICATION_ACCEPTED notifications, allow student to confirm and become intern
                    if (type == 'APPLICATION_ACCEPTED' || title
                        .toLowerCase()
                        .contains('accepted')) {
                      // Afficher l'animation du trophée Welcome Aboard
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AchievementUnlockScreen(
                                achievement: Achievement
                                    .getAchievementsByRole(
                                    AchievementRole.student)[1],
                                // index 1 = Welcome Aboard
                                onContinue: () {
                                  Navigator.pop(context); // Ferme le trophée
                                  Navigator.pushReplacementNamed(context,
                                      '/student_home'); // Redirige vers la HomePage étudiant
                                },
                              ),
                        ),
                      );
                      return;
                    }
                    try {
                      // Get user email
                      final user = await CoreDB.DatabaseHelper.getUserById(
                          widget.userId);
                      final email = user?['email'] as String?;
                      final currentStatus = user?['internship_status'] as String? ??
                          'CANDIDATE';

                      if (email == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text(
                                'Unable to confirm: user email not found')));
                        return;
                      }

                      if (currentStatus == 'INTERN') {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text(
                                'You already have an internship')));
                        return;
                      }

                      // Mark notification as read
                      await CoreDB.DatabaseHelper.markNotificationRead(id);

                      // Update student status to INTERN
                      await CoreDB.DatabaseHelper
                          .updateStudentInternshipStatus(email, 'INTERN');

                      // Assign a project to the student (first available)
                      final assignedId = await CoreDB.DatabaseHelper
                          .assignFirstAvailableProjectToStudent(email);

                      // Also update the applications table to mark this student's application as ACCEPTED for the internship reference
                      if (referenceId != null) {
                        final ref = referenceId is int ? referenceId : int
                            .tryParse(referenceId.toString());
                        if (ref != null) {
                          final db = await CoreDB.DatabaseHelper.database;
                          try {
                            await db.update(
                                'applications', {'status': 'ACCEPTED'},
                                where: 'internshipId = ? AND studentId = ?',
                                whereArgs: [ref, widget.userId]);
                          } catch (e) {
                            print(
                                '⚠️ Failed to update application status: $e');
                          }
                        }
                      }

                      // Refresh notification list and notify user
                      setState(() => _future = _load());

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(assignedId != null
                            ? 'Confirmed! You are now an intern and assigned to project #$assignedId.'
                            : 'Confirmed! You are now an intern (no available project to assign).')),
                      );

                      // Pop and return true to signal parent to refresh (unread count & student status)
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (mounted) Navigator.pop(context, true);

                      // Optionally pop back so home pages can refresh unread counts
                      // Navigator.pop(context);

                    } catch (e) {
                      print('⚠️ Error during double-tap confirm: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text(
                              'Error while confirming internship')));
                    }
                  },
                  child: ListTile(
                    // onTap removed in favor of GestureDetector handlers
                    leading: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Icon(
                          type == 'TASK' ? Icons.task : (type == 'PROJECT'
                              ? Icons.folder_open
                              : Icons.notifications),
                          color: const Color(0xFF8B1C1C),
                          size: 28,
                        ),
                        if (isRead == 0)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                  color: Colors.red, shape: BoxShape.circle),
                            ),
                          ),
                      ],
                    ),
                    title: Text(
                      title,
                      style: TextStyle(fontWeight: isRead == 0
                          ? FontWeight.w800
                          : FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(msg),
                        const SizedBox(height: 6),
                        Text(_formatDate(createdAt), style: TextStyle(
                            fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    trailing: isRead == 0
                        ? TextButton(
                      onPressed: () async {
                        await CoreDB.DatabaseHelper.markNotificationRead(id);
                        setState(() => _future = _load());
                      },
                      child: const Text('Mark read'),
                    )
                        : null,
                  ),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: items.length,
          );
        },
      ),
    );
  }
}