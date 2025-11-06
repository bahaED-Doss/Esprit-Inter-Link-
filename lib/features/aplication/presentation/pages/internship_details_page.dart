import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/internship_model.dart';
import '../../providers/application_provider.dart';
import 'application_form_page.dart';

/// Page affichant les détails complets d'une offre de stage
class InternshipDetailsPage extends StatefulWidget {
  final Internship internship;
  // studentId peut être null si la page est ouverte depuis le HR (visualisation seule)
  final int? studentId;

  const InternshipDetailsPage({
    Key? key,
    required this.internship,
    this.studentId,
  }) : super(key: key);

  @override
  State<InternshipDetailsPage> createState() => _InternshipDetailsPageState();
}

class _InternshipDetailsPageState extends State<InternshipDetailsPage> {
  bool _hasApplied = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkApplicationStatus();
  }

  Future<void> _checkApplicationStatus() async {
    // Si aucun studentId fourni (ex: HR view), ne pas appeler hasApplied
    if (widget.studentId == null) {
      if (mounted) {
        setState(() {
          _hasApplied = false;
          _isLoading = false;
        });
      }
      return;
    }

    final provider = Provider.of<ApplicationProvider>(context, listen: false);
    final hasApplied = await provider.hasApplied(widget.studentId!, widget.internship.id!);
    if (mounted) {
      setState(() {
        _hasApplied = hasApplied;
        _isLoading = false;
      });
    }
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
            
            // Contenu défilant
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carte entreprise
                    _buildCompanyCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Description
                    _buildSection(
                      'Description',
                      Text(
                        widget.internship.description,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Requirements
                    _buildSection(
                      'Requirements',
                      Column(
                        children: widget.internship.requirements.map((req) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 6),
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: Color(0xFF8B1C1C),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    req,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Skills
                    _buildSection(
                      'Skills',
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.internship.skills.map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFF8B1C1C).withAlpha((0.1 * 255).round()),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              skill,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8B1C1C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Additional Info
                    _buildSection(
                      'Details',
                      Column(
                        children: [
                          _buildDetailRow('Duration', '${widget.internship.duration} months'),
                          const SizedBox(height: 12),
                          _buildDetailRow('Start Date', _formatDate(widget.internship.startDate)),
                          const SizedBox(height: 12),
                          _buildDetailRow('Location', widget.internship.location),
                          const SizedBox(height: 12),
                          _buildDetailRow('Type', widget.internship.typeDisplay),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 100), // Space for button
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Bouton Apply flottant
      // Si on charge encore ou si aucun studentId n'est fourni (visualisation HR), ne rien afficher
      bottomNavigationBar: (_isLoading || widget.studentId == null)
          ? null
          : Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.05 * 255).round()),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: _hasApplied
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ALREADY APPLIED',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                          letterSpacing: 1,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        if (widget.studentId == null) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ApplicationFormPage(
                              internship: widget.internship,
                              studentId: widget.studentId!,
                            ),
                          ),
                        ).then((_) {
                          // Refresh status après retour
                          _checkApplicationStatus();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B1C1C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'APPLY',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
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
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Internship Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }

  Widget _buildCompanyCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF8B1C1C),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.business,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.internship.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.internship.companyName,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      widget.internship.location,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
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

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        content,
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
