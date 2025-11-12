import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../tasks/providers/task_provider.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../../../../shared/providers/user_session_provider.dart';

class ProjectTaskList extends StatelessWidget {
  final int projectId;
  final bool isPM;

  const ProjectTaskList({Key? key, required this.projectId, this.isPM = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider()..loadTasks(projectId: projectId),
      child: Consumer<TaskProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) return const Center(child: CircularProgressIndicator());
          if (provider.error != null) return Center(child: Text(provider.error!));
          if (provider.tasks.isEmpty) return const Text('No tasks found for this project');

          bool pmFlag = isPM;
          try {
            final roleProvider = Provider.of<UserSessionProvider>(ctx, listen: false);
            pmFlag = pmFlag || roleProvider.isPM;
          } catch (_) {}

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.tasks.length,
            itemBuilder: (ctx2, i) {
              final t = provider.tasks[i];
              return TaskCard(
                task: t,
                isPM: pmFlag,
                onEdit: (task) async {
                  await provider.editTask(task);
                },
                onDelete: (task) async {
                  if (task.id != null) await provider.removeTask(task.id!);
                },
                onChangeStatus: (task) async {
                  await provider.editTask(task);
                },
                onPin: (task) async {
                  final updated = task.copyWith(pinned: !task.pinned);
                  await provider.editTask(updated);
                },
              );
            },
          );
        },
      ),
    );
  }
}
