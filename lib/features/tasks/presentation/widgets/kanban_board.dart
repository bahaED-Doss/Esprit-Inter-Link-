// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../providers/task_provider.dart';
import 'package:intl/intl.dart';
import '../widgets/task_form_dialog.dart';
import 'task_details_dialog.dart'; // + afficher les détails en vue Kanban pour les étudiants
import '../../../../data/datasources/local/database_helper.dart';
import '../../../../shared/data/notification_service.dart';

class KanbanBoard extends StatefulWidget {
  final bool isPM;
  final int userId; // Ajout de l'id utilisateur courant

  const KanbanBoard({Key? key, this.isPM = false, required this.userId}) : super(key: key);

  @override
  State<KanbanBoard> createState() => _KanbanBoardState();
}

class _KanbanBoardState extends State<KanbanBoard> {
  final ScrollController _toDoController = ScrollController();
  final ScrollController _doingController = ScrollController();
  final ScrollController _doneController = ScrollController();

  @override
  void dispose() {
    _toDoController.dispose();
    _doingController.dispose();
    _doneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    // helper to build a column
    Widget buildColumn(TaskStatus status, ScrollController controller) {
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

      return Expanded(
        child: DragTarget<Task>(
          // Accept drops when the status would change (allow PM to drop visually, logic will decide)
          onWillAcceptWithDetails: (details) => details.data.status != status,
          onAcceptWithDetails: (details) async {
            final incoming = details.data;
            final previousStatus = incoming.status;
            if (widget.isPM) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Only interns can move tasks in the Kanban — this action is for interns.'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }
            final updated = incoming.copyWith(status: status);
            await provider.editTask(updated);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Moved "${incoming.title}" to $statusName')),
            );
            // Vérification du rôle avant notification PM
            final currentUser = await DatabaseHelper.getUserById(widget.userId);
            if (currentUser != null && currentUser['role'] == 'STUDENT') {
              if (previousStatus == TaskStatus.TO_DO && (status == TaskStatus.DOING || status == TaskStatus.DONE)) {
                final openTasks = await DatabaseHelper.countOpenTasksForProject(incoming.projectId);
                if (openTasks == 0) {
                  final pmId = await DatabaseHelper.getPMUserIdForProject(incoming.projectId);
                  if (pmId != null) {
                    final alreadyNotified = await DatabaseHelper.hasUnreadEmptyProjectNotification(pmId, incoming.projectId);
                    if (!alreadyNotified) {
                      final project = await DatabaseHelper.getProjectById(incoming.projectId);
                      await NotificationService.addNotificationForUser(
                        pmId,
                        'Le projet ${project?['name'] ?? ''} n’a plus de tâches à faire, voulez-vous en ajouter ou terminer le projet ?',
                        title: 'Projet sans tâches',
                        type: 'PROJECT',
                        referenceId: incoming.projectId,
                      );
                    }
                  }
                }
              }
            }
          },
          builder: (context, candidateData, rejectedData) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha((0.08 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(width: 6, height: 18, decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(4))),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            statusName,
                            style: TextStyle(fontWeight: FontWeight.bold, color: statusColor),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: statusColor.withAlpha((0.15 * 255).round()), borderRadius: BorderRadius.circular(12)),
                          child: Text('${tasks.length}', style: TextStyle(fontWeight: FontWeight.bold, color: statusColor)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: candidateData.isNotEmpty ? Colors.grey.withAlpha((0.08 * 255).round()) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Scrollbar(
                        controller: controller,
                        thumbVisibility: true,
                        child: ListView.builder(
                          controller: controller,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: tasks.length,
                          itemBuilder: (ctx, i) {
                            final task = tasks[i];

                            // Make every card draggable visually; only students will persist changes on drop
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                              child: LongPressDraggable<Task>(
                                data: task,
                                feedback: Material(
                                  elevation: 6,
                                  color: Colors.transparent,
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 320),
                                    child: _KanbanCard(task: task, isPM: widget.isPM),
                                  ),
                                ),
                                childWhenDragging: Opacity(opacity: 0.4, child: _KanbanCard(task: task, isPM: widget.isPM)),
                                child: _KanbanCard(
                                  task: task,
                                  isPM: widget.isPM,
                                  onTap: () => _openTaskMenu(context, task, provider),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildColumn(TaskStatus.TO_DO, _toDoController),
        buildColumn(TaskStatus.DOING, _doingController),
        buildColumn(TaskStatus.DONE, _doneController),
      ],
    );
  }

  void _openTaskMenu(BuildContext context, Task task, TaskProvider provider) {
    // En vue Kanban: pas de sélection de statut pour les étudiants (drag & drop uniquement)
    if (!widget.isPM) {
      // Ouvrir les détails pour lecture (optionnel) et afficher un rappel
      TaskDetailsDialog.show(context, task, showAI: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tip: drag & drop the card to another column to change status.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // PM: garde le menu d’édition/suppression
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Color(0xFF8B1C1C)),
                title: const Text('Edit Task'),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (_) => TaskFormDialog(
                      initial: task,
                      onSave: (updated) => provider.editTask(updated),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.redAccent),
                title: const Text('Delete Task', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(context);
                  provider.removeTask(task.id!);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStatusSheet(BuildContext context, Task task, TaskProvider provider) {
    TaskStatus selected = task.status;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) {
        return StatefulBuilder(builder: (ctx, setState) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 12),
                ...TaskStatus.values.map((s) {
                  return
                  // ignore: deprecated_member_use
                  RadioListTile<TaskStatus>(
                    title: Text(s.toString().split('.').last),
                    value: s,
                    groupValue: selected,
                    onChanged: (v) => setState(() => selected = v!),
                  );
                }).toList(),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B1C1C)),
                  onPressed: () async {
                    Navigator.pop(context);
                    await provider.editTask(task.copyWith(status: selected));
                  },
                  child: const SizedBox(width: double.infinity, child: Center(child: Text('UPDATE'))),
                ),
              ],
            ),
          );
        });
      },
    );
  }
}

class _KanbanCard extends StatelessWidget {
  final Task task;
  final bool isPM;
  final VoidCallback? onTap;

  const _KanbanCard({required this.task, this.isPM = false, this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deadlineText = task.deadline != null ? DateFormat('yyyy-MM-dd').format(task.deadline!) : 'No deadline';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Color.fromRGBO(0,0,0,0.03), blurRadius: 6)]),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(task.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: Text(task.priority.toString().split('.').last, style: const TextStyle(fontSize: 11)),
                )
              ],
            ),
            if ((task.description ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(task.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(deadlineText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                  child: Text(task.sprintNumber != null ? 'Sprint ${task.sprintNumber}' : '-', style: const TextStyle(fontSize: 11)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
