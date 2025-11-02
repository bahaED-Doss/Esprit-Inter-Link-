import 'package:flutter/material.dart';
import '../../models/project_model.dart';

/// Widget de sélection de projet pour PM
/// Permet au PM de choisir quel projet gérer
class ProjectSelector extends StatelessWidget {
  final List<ProjectModel> projects;
  final ProjectModel? selectedProject;
  final Function(ProjectModel) onProjectSelected;
  final bool compact; // Mode compact pour l'affichage en haut de page

  const ProjectSelector({
    required this.projects,
    this.selectedProject,
    required this.onProjectSelected,
    this.compact = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (compact) {
      // Mode compact: dropdown simple
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: selectedProject?.id,
            hint: Text('Select Project'),
            isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: const Color(0xFF8B1C1C)),
            items: projects.map((project) => DropdownMenuItem<int>(
              value: project.id,
              child: Row(
                children: [
                  Icon(Icons.folder, color: const Color(0xFF8B1C1C), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      project.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )).toList(),
            onChanged: (projectId) {
              if (projectId != null) {
                final project = projects.firstWhere((p) => p.id == projectId);
                onProjectSelected(project);
              }
            },
          ),
        ),
      );
    }

    // Mode pleine page: liste de cartes
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => onProjectSelected(project),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B1C1C).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.folder_open,
                      color: const Color(0xFF8B1C1C),
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (project.description != null) ...[
                          SizedBox(height: 4),
                          Text(
                            project.description!,
                            style: TextStyle(color: Colors.grey[600]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
