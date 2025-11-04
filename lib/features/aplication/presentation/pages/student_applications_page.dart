import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/application_provider.dart';
import '../../models/application_model.dart';

/// Page affichant toutes les candidatures soumises par un étudiant
class StudentApplicationsPage extends StatefulWidget {
  final int studentId;

  const StudentApplicationsPage({Key? key, required this.studentId}) : super(key: key);

  @override
  State<StudentApplicationsPage> createState() => _StudentApplicationsPageState();
}

class _StudentApplicationsPageState extends State<StudentApplicationsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadApplications();
    });
  }

  Future<void> _loadApplications() async {
    final provider = Provider.of<ApplicationProvider>(context, listen: false);
    await provider.loadApplicationsByStudent(widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B1C1C),
        title: const Text(
          'My Applications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<ApplicationProvider>(
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
                    onPressed: _loadApplications,
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
                    'Start applying to internships!',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadApplications,
            color: const Color(0xFF8B1C1C),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.applications.length,
              itemBuilder: (context, index) {
                final application = provider.applications[index];
                return _buildApplicationCard(application);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildApplicationCard(Application application) {
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
                  child: Text(
                    'Application #${application.id}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
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
                // Full name
                Text(
                  application.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Email
                Text(
                  application.email,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 16),
                
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
                
                const SizedBox(height: 12),
                
                // Motivation preview
                if (application.motivation.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Motivation',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        application.motivation,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                
                const SizedBox(height: 12),
                
                // Resume indicator
                if (application.resumePath != null)
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
                
                // Applied date
                Text(
                  'Applied on ${_formatDate(application.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
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
