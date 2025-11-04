import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../aplication/models/internship_model.dart';
import '../../../aplication/providers/application_provider.dart';
import 'hr_internship_form_page.dart';

/// Page listant toutes les offres de stage créées par le HR avec CRUD
class HRInternshipListPage extends StatefulWidget {
  final int hrId;

  const HRInternshipListPage({Key? key, required this.hrId}) : super(key: key);

  @override
  State<HRInternshipListPage> createState() => _HRInternshipListPageState();
}

class _HRInternshipListPageState extends State<HRInternshipListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInternships();
    });
  }

  Future<void> _loadInternships() async {
    final provider = Provider.of<ApplicationProvider>(context, listen: false);
    await provider.initializeMockData();
    await provider.loadInternshipsByHR(widget.hrId);
  }

  void _deleteInternship(Internship internship) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Internship'),
        content: Text('Are you sure you want to delete "${internship.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final provider = Provider.of<ApplicationProvider>(context, listen: false);
      await provider.deleteInternship(internship.id!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Internship deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _editInternship(Internship internship) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HRInternshipFormPage(
          hrId: widget.hrId,
          internship: internship,
        ),
      ),
    ).then((_) => _loadInternships());
  }

  void _addInternship() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HRInternshipFormPage(hrId: widget.hrId),
      ),
    ).then((_) => _loadInternships());
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
                  if (provider.isLoadingInternships) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B1C1C),
                      ),
                    );
                  }

                  if (provider.internshipError != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            provider.internshipError!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadInternships,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B1C1C),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (provider.internships.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.work_outline, size: 80, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No internship offers yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create your first internship offer!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _addInternship,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B1C1C),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            icon: const Icon(Icons.add),
                            label: const Text('Create Internship'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _loadInternships,
                    color: const Color(0xFF8B1C1C),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.internships.length,
                      itemBuilder: (context, index) {
                        final internship = provider.internships[index];
                        return _buildInternshipCard(internship);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addInternship,
        backgroundColor: const Color(0xFF8B1C1C),
        icon: const Icon(Icons.add),
        label: const Text('New Offer'),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MY INTERNSHIP OFFERS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white, size: 22),
                onPressed: () {
                  // Filter functionality
                },
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
                hintText: 'Search',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (value) {
                Provider.of<ApplicationProvider>(context, listen: false).setSearch(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInternshipCard(Internship internship) {
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
          // Header avec status
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getStatusColor(internship.status).withOpacity(0.1),
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
                        internship.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        internship.companyName,
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
                    color: _getStatusColor(internship.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    internship.statusDisplay,
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
                Text(
                  internship.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    _buildInfoChip(Icons.location_on, internship.location),
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.schedule, '${internship.duration} months'),
                    const SizedBox(width: 12),
                    _buildInfoChip(Icons.category, internship.typeDisplay),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF8B1C1C)),
                      onPressed: () => _editInternship(internship),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteInternship(internship),
                      tooltip: 'Delete',
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/hr_applications',
                          arguments: internship.id,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B1C1C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.people, size: 18),
                      label: const Text('Applications'),
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

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(InternshipStatus status) {
    switch (status) {
      case InternshipStatus.OPEN:
        return const Color(0xFF66BB6A);
      case InternshipStatus.CLOSED:
        return const Color(0xFFEF5350);
      case InternshipStatus.IN_PROGRESS:
        return const Color(0xFFFFA726);
    }
  }
}
