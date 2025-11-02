import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/kanban_board.dart';

class StudentTaskView extends StatefulWidget {
  final int projectId;
  final int userId;
  final String projectName;

  const StudentTaskView({
    required this.projectId,
    required this.userId,
    required this.projectName,
    Key? key,
  }) : super(key: key);

  @override
  State<StudentTaskView> createState() => _StudentTaskViewState();
}

class _StudentTaskViewState extends State<StudentTaskView> {
  // Maintenant on reçoit explicitement le provider pour éviter les erreurs de contexte.
  void _showStatusSheet(BuildContext context, Task task, TaskProvider provider) {
    TaskStatus selectedStatus = task.status;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: StatefulBuilder(
            builder: (ctx, setModalState) {
              Widget buildRadio(
                  TaskStatus value,
                  String title,
                  String subtitle,
                  IconData icon,
                  ) {
                return RadioListTile<TaskStatus>(
                  value: value,
                  groupValue: selectedStatus,
                  activeColor: const Color(0xFF8B1C1C),
                  onChanged: (v) => setModalState(() => selectedStatus = v!),
                  title: Row(
                    children: [
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                      Text(title),
                    ],
                  ),
                  subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 20 + MediaQuery.of(ctx).viewInsets.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'When you are working on a task',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'please select the state of the task',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 12),

                    buildRadio(TaskStatus.TO_DO, 'To-Do', 'tasks needs to be done', Icons.circle_outlined),
                    buildRadio(TaskStatus.DOING, 'Doing', 'the task is ongoing', Icons.sync),
                    buildRadio(TaskStatus.DONE, 'Done', 'the task is completed', Icons.check_circle),

                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B1C1C),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () async {
                          // Mise à jour via le provider passé en paramètre
                          await provider.editTask(task.copyWith(status: selectedStatus));
                          if (selectedStatus == TaskStatus.DONE) {
                            final hasAchievement = await provider.checkTaskWarriorAchievement(widget.userId);
                            if (hasAchievement) {
                              // TODO: déclencher le trophée
                            }
                          }
                          Navigator.pop(ctx);
                        },
                        child: const Text('UPDATE STATUS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold , color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider()
        ..loadTasks(
          projectId: widget.projectId,
          userId: widget.userId,
        ),
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('My Tasks', style: TextStyle(fontSize: 18, color: Colors.white)),
              Text(
                widget.projectName,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Colors.white),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF8B1C1C),
          foregroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Consumer<TaskProvider>(
          // IMPORTANT : utiliser un contexte interne (consumerCtx) qui est sous le Provider
          builder: (consumerCtx, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                    Text(
                      'No tasks assigned yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your PM will assign tasks soon',
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            final mq = MediaQuery.of(consumerCtx);
            final isWide = mq.orientation == Orientation.landscape || mq.size.width > 700;

            if (isWide) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: KanbanBoard(isPM: false, userId: widget.userId),
              );
            }

            return Stack(
              children: [
                RefreshIndicator(
                  onRefresh: () => provider.loadTasks(
                    projectId: widget.projectId,
                    userId: widget.userId,
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(color: const Color.fromRGBO(0, 0, 0, 0.03), blurRadius: 6),
                            ],
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Here you can find your tasks', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(height: 6),
                              Text('Tip: rotate your phone for a Kanban view and drag tasks between columns', style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildStatusSection(consumerCtx, provider, TaskStatus.TO_DO),
                        const SizedBox(height: 16),
                        _buildStatusSection(consumerCtx, provider, TaskStatus.DOING),
                        const SizedBox(height: 16),
                        _buildStatusSection(consumerCtx, provider, TaskStatus.DONE),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  bottom: 18,
                  right: 18,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Pinned', style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 8),
                          Switch(
                            value: provider.showPinnedOnly,
                            thumbColor: MaterialStateProperty.all(const Color(0xFF8B1C1C)),
                            onChanged: (v) => provider.setShowPinnedOnly(v),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
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
              const SizedBox(width: 8),
              Text(
                statusName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
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
        const SizedBox(height: 8),
        if (tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
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
            isPM: false,
            // On passe le context descendant et le provider afin que la feuille trouve le provider.
            onChangeStatus: (t) => _showStatusSheet(context, t, provider),
            onPin: (t) => provider.editTask(t.copyWith(pinned: !t.pinned)),
          )),
      ],
    );
  }
}