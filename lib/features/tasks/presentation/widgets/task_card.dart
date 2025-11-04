import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import 'priority_tag.dart';
import 'task_details_dialog.dart';

typedef OnEdit = void Function(Task task);
typedef OnDelete = void Function(Task task);
typedef OnChangeStatus = void Function(Task task);
typedef OnPin = void Function(Task task); // nouveau typedef

/// Widget TaskCard - Carte d'affichage d'une tâche
/// Affiche différents menus selon le rôle (PM ou Student)
class TaskCard extends StatelessWidget {
  final Task task;
  final bool isPM;
  final OnEdit? onEdit;
  final OnDelete? onDelete;
  final OnChangeStatus? onChangeStatus;
  final OnPin? onPin; // nouveau callback

  const TaskCard({
    required this.task,
    required this.isPM,
    this.onEdit,
    this.onDelete,
    this.onChangeStatus,
    this.onPin,
    Key? key,
  }) : super(key: key);

  void _showMenu(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isPM) ...[
              ListTile(
                leading: Icon(Icons.edit, color: const Color(0xFF8B1C1C)),
                title: Text('Edit Task'),
                onTap: () {
                  Navigator.pop(ctx);
                  onEdit?.call(task);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.redAccent),
                title: Text('Delete Task', style: TextStyle(color: Colors.redAccent)),
                onTap: () {
                  Navigator.pop(ctx);
                  onDelete?.call(task);
                },
              ),
            ],

            // Always show Change Status option if a handler is provided
            if (onChangeStatus != null)
              ListTile(
                leading: Icon(Icons.swap_horiz, color: const Color(0xFF8B1C1C)),
                title: Text('Change Status'),
                onTap: () {
                  Navigator.pop(ctx);
                  onChangeStatus?.call(task);
                },
              ),

            // Pin/Unpin option
            if (onPin != null)
              ListTile(
                leading: Icon(task.pinned ? Icons.push_pin : Icons.push_pin_outlined, color: const Color(0xFF8B1C1C)),
                title: Text(task.pinned ? 'Unpin Task' : 'Pin Task'),
                onTap: () {
                  Navigator.pop(ctx);
                  onPin?.call(task);
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deadlineText = task.deadline != null
        ? '${task.deadline!.toLocal().toString().split(' ')[0]}'
        : 'No deadline';

    final content = ListTile(
      contentPadding: const EdgeInsets.all(12),
      title: Text(
        task.title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((task.description ?? '').isNotEmpty) SizedBox(height: 6),
          if ((task.description ?? '').isNotEmpty)
            Text(
              task.description ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[700]),
            ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              PriorityTag(priority: task.priority),
              if (task.sprintNumber != null)
                Chip(
                  label: Text('Sprint ${task.sprintNumber}'),
                  backgroundColor: Colors.grey[200],
                  labelStyle: TextStyle(fontSize: 11),
                ),
              Chip(
                label: Text(deadlineText),
                backgroundColor: Colors.grey[100],
                labelStyle: TextStyle(fontSize: 11, color: Colors.grey[700]),
                avatar: Icon(Icons.calendar_today, size: 14),
              ),
            ],
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(Icons.more_vert),
        onPressed: () => _showMenu(context),
      ),
      onTap: () => TaskDetailsDialog.show(context, task, showAI: !isPM),
    );

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: content,
    );
  }
}
