// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../models/project_model.dart';
import '../../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/task_form_dialog.dart';
import '../widgets/project_selector.dart';
import '../widgets/kanban_board.dart';

/// Vue PM pour la gestion des tâches
/// Affichage vertical avec regroupement par status (TO_DO, DOING, DONE)
/// FAB pour ajouter une tâche, menu edit/delete sur chaque carte
class PMTaskView extends StatefulWidget {
  final int projectId;
  final String projectName;

  const PMTaskView({
    required this.projectId,
    required this.projectName,
    Key? key,
  }) : super(key: key);

  @override
  State<PMTaskView> createState() => _PMTaskViewState();
}

class _PMTaskViewState extends State<PMTaskView> {
  ProjectModel? _selectedProject;

  @override
  void initState() {
    super.initState();
    _selectedProject = ProjectModel(
      id: widget.projectId,
      name: widget.projectName,
      pmId: 1, // Mock PM ID
    );
  }

  // Mock projects pour le sélecteur compact
  List<ProjectModel> _getMockProjects() {
    return [
      ProjectModel(id: 1, name: 'Mobile Application', pmId: 1),
      ProjectModel(id: 2, name: 'Web Dashboard', pmId: 1),
      ProjectModel(id: 3, name: 'Backend API', pmId: 1),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider()..loadTasks(projectId: widget.projectId),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Tasks', style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF8B1C1C),
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                // TODO: Implémenter la recherche
              },
            ),
            IconButton(
              icon: Icon(Icons.filter_list, color: Colors.white),
              onPressed: () {
                // TODO: Implémenter les filtres
              },
            ),
          ],
        ),
        body: Column(
          children: [
            // Sélecteur de projet compact en haut
            Container(
              padding: EdgeInsets.all(12),
              color: Colors.grey[100],
              child: Builder(
                builder: (ctx) => ProjectSelector(
                  projects: _getMockProjects(),
                  selectedProject: _selectedProject,
                  onProjectSelected: (project) {
                    // Update local selection
                    setState(() {
                      _selectedProject = project;
                    });
                    // Recharger les tâches du nouveau projet depuis le provider accessible via ctx
                    Provider.of<TaskProvider>(ctx, listen: false).loadTasks(projectId: project.id);
                  },
                  compact: true,
                ),
              ),
            ),

            // Liste des tâches ou Kanban
            Expanded(
              child: Consumer<TaskProvider>(
                builder: (ctx, provider, _) {
                  if (provider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (provider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 64, color: Colors.red),
                          SizedBox(height: 16),
                          Text(provider.error!),
                        ],
                      ),
                    );
                  }

                  if (provider.tasks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.task_alt, size: 80, color: Colors.grey[400]),
                          SizedBox(height: 16),
                          Text(
                            'No tasks yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap + to create your first task',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  }

                  // Responsive switch: show kanban in landscape / wide screens
                  final mq = MediaQuery.of(context);
                  final isWide = mq.orientation == Orientation.landscape || mq.size.width > 700;

                  if (isWide) {
                    // Kanban board
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: KanbanBoard(isPM: true, userId: _selectedProject?.pmId ?? 1),
                    );
                  }

                  // Portrait / narrow: keep existing vertical list UI
                  return RefreshIndicator(
                    onRefresh: () => provider.loadTasks(projectId: _selectedProject!.id),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(12),
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusSection(context, provider, TaskStatus.TO_DO),
                          SizedBox(height: 16),
                          _buildStatusSection(context, provider, TaskStatus.DOING),
                          SizedBox(height: 16),
                          _buildStatusSection(context, provider, TaskStatus.DONE),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: Consumer<TaskProvider>(
          builder: (ctx, provider, _) => FloatingActionButton(
            backgroundColor: const Color(0xFF8B1C1C),
            child: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => TaskFormDialog(
                  onSave: (task) {
                    final toInsert = task.copyWith(projectId: _selectedProject!.id);
                    provider.addTask(toInsert);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, TaskProvider provider, TaskStatus status) {
    final tasks = provider.tasksByStatus(status);
    final statusName = status.toString().split('.').last;

    Color statusColor;
    switch (status) {
      case TaskStatus.TO_DO:
        statusColor = const Color(0xFF8B1C1C);
        break;
      case TaskStatus.DOING:
        statusColor = Colors.orange;
        break;
      case TaskStatus.DONE:
        statusColor = Colors.green;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: statusColor.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: 8),
              Text(
                statusName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${tasks.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        if (tasks.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                'No tasks in $statusName',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
          )
        else
          ...tasks.map((task) => TaskCard(
                task: task,
                isPM: true,
                onEdit: (t) {
                  showDialog(
                    context: context,
                    builder: (_) => TaskFormDialog(
                      initial: t,
                      onSave: (updated) => provider.editTask(updated),
                    ),
                  );
                },
                onDelete: (t) {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Remove Task?'),
                      content: Text('Are you sure you want to remove this task?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: Text('CANCEL'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            provider.removeTask(t.id!);
                            Navigator.pop(ctx);
                          },
                          child: Text('DELETE')
                        ),
                      ],
                    ),
                  );
                },
                // DO NOT pass onChangeStatus for PM: only students can change status
              )),
      ],
    );
  }
}
