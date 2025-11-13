import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/internship_model.dart';
import '../../providers/application_provider.dart';
import 'internship_details_page.dart';

/// Page listant toutes les offres de stage disponibles pour les étudiants
class StudentInternshipListPage extends StatefulWidget {
  final int studentId;

  const StudentInternshipListPage({Key? key, required this.studentId}) : super(key: key);

  @override
  State<StudentInternshipListPage> createState() => _StudentInternshipListPageState();
}

class _StudentInternshipListPageState extends State<StudentInternshipListPage> {
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
    await provider.initializeMockData(); // Initialize mock data if needed
    await provider.loadOpenInternships();
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
            // Header avec gradient
            _buildHeader(),

            // Liste des stages
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
                            'No internships available',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check back later for new opportunities!',
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
              // Add a back button on the top-left
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.maybePop(context);
                    },
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'INTERNSHIPS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white, size: 22),
                    onPressed: () {
                      // Share functionality
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white, size: 22),
                    onPressed: () {
                      // Settings functionality
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Barre de recherche
          Container(
            decoration: BoxDecoration(
              // Utilise la couleur demandée avec la même opacité
              color: const Color(0xFF8B1C1C).withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search',
                // icône et hint utilisent la couleur demandée
                hintStyle: TextStyle(color: const Color(0xFF8B1C1C).withAlpha((0.7 * 255).round())),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF8B1C1C)),
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
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => InternshipDetailsPage(
              internship: internship,
              studentId: widget.studentId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec icône d'entreprise
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF8B1C1C).withAlpha((0.05 * 255).round()),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B1C1C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.business,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          internship.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          internship.companyName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Corps de la carte
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
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

                  // Infos
                  Row(
                    children: [
                      _buildInfoChip(Icons.location_on, internship.location),
                      const SizedBox(width: 12),
                      _buildInfoChip(Icons.schedule, '${internship.duration} months'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Bouton Apply
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0F0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'APPLY',
                        style: TextStyle(
                          color: Color(0xFF8B1C1C),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
}