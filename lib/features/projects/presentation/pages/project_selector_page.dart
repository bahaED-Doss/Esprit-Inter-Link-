import 'package:flutter/material.dart';

/// Page de sélection de projet pour PM
/// Le PM choisit le projet qu'il veut gérer avant d'accéder aux tâches
class ProjectSelectorPage extends StatefulWidget {
  final int pmId;
  const ProjectSelectorPage({required this.pmId, Key? key}) : super(key: key);

  @override
  State<ProjectSelectorPage> createState() => _ProjectSelectorPageState();
}

class _ProjectSelectorPageState extends State<ProjectSelectorPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Redirect to the main projects management page
      Navigator.of(context).pushReplacementNamed('/projects');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

