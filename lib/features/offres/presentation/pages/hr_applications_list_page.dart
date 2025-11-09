import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../aplication/models/application_model.dart';
import '../../../aplication/models/internship_model.dart';
import '../../../aplication/providers/application_provider.dart';
import '../../../../data/datasources/local/database_helper.dart' as CoreDB;

/// Page listant toutes les candidatures pour une offre de stage avec Accept/Refuse
class HRApplicationsListPage extends StatefulWidget {
  final int internshipId;

  const HRApplicationsListPage({Key? key, required this.internshipId}) : super(key: key);

  @override
  State<HRApplicationsListPage> createState() => _HRApplicationsListPageState();
}

class _HRApplicationsListPageState extends State<HRApplicationsListPage> {
  final TextEditingController _searchController = TextEditingController();
  Internship? _internship;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final provider = Provider.of<ApplicationProvider>(context, listen: false);
    
    // Load internship details
    _internship = await provider.getInternshipById(widget.internshipId);
    setState(() {});
    
    // Load applications
    await provider.loadApplicationsByInternship(widget.internshipId);
  }

  Future<void> _acceptApplication(Application application) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Application'),
        content: Text('Accept application from ${application.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final provider = Provider.of<ApplicationProvider>(context, listen: false);
      final updated = application.copyWith(status: ApplicationStatus.ACCEPTED);
      final success = await provider.updateApplication(updated);
      
      if (success && mounted) {
        // 1. Fermer l'offre (status = CLOSED)
        try {
          final db = await CoreDB.DatabaseHelper.database;
          await db.update(
            'internships',
            {'status': 'CLOSED', 'updatedAt': DateTime.now().toIso8601String()},
            where: 'id = ?',
            whereArgs: [application.internshipId],
          );
        } catch (e) {
          print('⚠️ Failed to close internship: $e');
        }

        // 2. Récupérer l'email de l'étudiant et le marquer comme INTERN
        try {
          final db = await CoreDB.DatabaseHelper.database;
          final user = await db.query('users', where: 'id = ?', whereArgs: [application.studentId], limit: 1);
          if (user.isNotEmpty) {
            final email = user.first['email'] as String;

            // Mettre à jour le statut de l'étudiant
            await CoreDB.DatabaseHelper.updateStudentInternshipStatus(email, 'INTERN');

            // 3. Assigner automatiquement un projet à l'étudiant
            final assignedId = await CoreDB.DatabaseHelper.assignFirstAvailableProjectToStudent(email);

            if (assignedId != null) {
              print('✅ Student assigned to project #$assignedId');
            }
          }
        } catch (e) {
          print('⚠️ Failed to update student status or assign project: $e');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application accepted! Student is now an intern.'),
            backgroundColor: Colors.green,
          ),
        );

        // Envoyer une notification à l'étudiant pour l'informer de la décision
        try {
          await CoreDB.DatabaseHelper.insertNotification(
            userId: application.studentId,
            title: 'Application accepted',
            message: 'Your application for internship #${application.internshipId} has been accepted by the company.\nDouble-tap this notification to confirm and become an intern.',
            type: 'APPLICATION_ACCEPTED',
            referenceId: application.internshipId,
          );
        } catch (e) {
          // Ignorer les erreurs de notification (ne doit pas casser l'UI)
          print('⚠️ Failed to send acceptance notification: $e');
        }

        // Recharger les données
        await _loadData();
      }
    }
  }

  Future<void> _refuseApplication(Application application) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refuse Application'),
        content: Text('Refuse application from ${application.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Refuse'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final provider = Provider.of<ApplicationProvider>(context, listen: false);
      final updated = application.copyWith(status: ApplicationStatus.REJECTED);
      final success = await provider.updateApplication(updated);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application refused'),
            backgroundColor: Colors.red,
          ),
        );
        // Envoyer une notification de rejet à l'étudiant
        try {
          await CoreDB.DatabaseHelper.insertNotification(
            userId: application.studentId,
            title: 'Application refused',
            message: 'Your application for internship #${application.internshipId} has been refused by the company.',
            type: 'APPLICATION_REJECTED',
            referenceId: application.internshipId,
          );
        } catch (e) {
          print('⚠️ Failed to send rejection notification: $e');
        }
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            
            Expanded(
              child: Consumer<ApplicationProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoadingApplications) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B1C1C),
                      ),
                    );
                  }

                  if (provider.applicationError != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            provider.applicationError!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B1C1C),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.applications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No Applications Yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Applications will appear here',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Filter applications by search
                  final applications = _searchController.text.isEmpty
                      ? provider.applications
                      : provider.applications.where((app) {
                          final query = _searchController.text.toLowerCase();
                          return app.fullName.toLowerCase().contains(query) ||
                                 app.email.toLowerCase().contains(query);
                        }).toList();

                  return RefreshIndicator(
                    onRefresh: _loadData,
                    color: const Color(0xFF8B1C1C),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: applications.length,
                      itemBuilder: (context, index) {
                        final application = applications[index];
                        return _buildApplicationCard(application);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8B1C1C),
            Color(0xFFA52A2A),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'APPLICATIONS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    if (_internship != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _internship!.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Barre de recherche
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) {
                setState(() {}); // Rebuild to filter
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(Application application) {
    final isPending = application.status == ApplicationStatus.PENDING;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(application.statusColor).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.fullName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        application.email,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(application.statusColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    application.statusDisplay,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dates
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatDate(application.startDate)} - ${_formatDate(application.endDate)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Motivation
                if (application.motivation.isNotEmpty) ...[
                  Text(
                    'Motivation',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    application.motivation,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Resume
                if (application.resumePath != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_file,
                        size: 16,
                        color: Color(0xFF8B1C1C),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Resume attached',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Applied date
                Text(
                  'Applied on ${_formatDate(application.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons (only for pending applications)
                if (isPending)
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _refuseApplication(application),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('REFUSE'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _acceptApplication(application),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF66BB6A),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('ACCEPT'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
