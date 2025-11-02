import 'package:flutter/material.dart';
import '../../models/project_model.dart';
import '../widgets/project_selector.dart';
import 'pm_task_view.dart';

/// Page de sélection de projet pour PM
/// Le PM choisit le projet qu'il veut gérer avant d'accéder aux tâches
class ProjectSelectorPage extends StatelessWidget {
  final int pmId;

  const ProjectSelectorPage({required this.pmId, Key? key}) : super(key: key);

  // Mock data - sera remplacé par les vrais projets du PM
  List<ProjectModel> _getMockProjects() {
    return [
      ProjectModel(
        id: 1,
        name: 'Mobile Application',
        description: 'Flutter project for student internship management',
        pmId: pmId,
      ),
      ProjectModel(
        id: 2,
        name: 'Web Dashboard',
        description: 'React admin panel for HR management',
        pmId: pmId,
      ),
      ProjectModel(
        id: 3,
        name: 'Backend API',
        description: 'Spring Boot REST API for data management',
        pmId: pmId,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final projects = _getMockProjects();

    return Scaffold(
      appBar: AppBar(
        title: Text('Select Project', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8B1C1C),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Projects',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Select a project to manage its tasks',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ProjectSelector(
              projects: projects,
              onProjectSelected: (project) {
                // Naviguer vers la page de gestion des tâches du projet
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PMTaskView(
                      projectId: project.id,
                      projectName: project.name,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
