// lib/features/projects/presentation/widgets/project_selector.dart
import 'package:flutter/material.dart';
import '../models/project_model.dart';

class ProjectSelector extends StatelessWidget {
  final List<Project> projects;
  final Project? selectedProject;
  final Function(Project) onProjectSelected;
  final bool compact;

  const ProjectSelector({
    Key? key,
    required this.projects,
    required this.selectedProject,
    required this.onProjectSelected,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return Text('No projects', style: TextStyle(color: Colors.grey[600]));
    }

    final dropdownItems = projects.map((p) {
      return DropdownMenuItem<Project>(
        value: p,
        child: Text(
          p.title,
          style: TextStyle(fontWeight: selectedProject?.id == p.id ? FontWeight.bold : FontWeight.normal),
        ),
      );
    }).toList();

    return DropdownButton<Project>(
      value: selectedProject,
      items: dropdownItems,
      onChanged: (Project? newValue) {
        if (newValue != null) {
          onProjectSelected(newValue);
        }
      },
      isExpanded: true,
      hint: Text('Select Project'),
      underline: compact ? SizedBox() : null,
      dropdownColor: Colors.white,
      style: TextStyle(color: Colors.black87),
    );
  }
}