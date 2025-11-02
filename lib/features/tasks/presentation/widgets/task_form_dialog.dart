import 'package:flutter/material.dart';
import '../../models/task_model.dart';

/// Dialogue pour ajouter ou modifier une tâche
/// Formulaire avec validation
class TaskFormDialog extends StatefulWidget {
  final Task? initial;
  final Function(Task) onSave;

  const TaskFormDialog({
    this.initial,
    required this.onSave,
    Key? key,
  }) : super(key: key);

  @override
  _TaskFormDialogState createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<TaskFormDialog> {
  final _form = GlobalKey<FormState>();
  late String _title;
  String? _description;
  String? _taskNumber;
  int? _sprint;
  TaskPriority _priority = TaskPriority.Medium;
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    if (t != null) {
      _title = t.title;
      _description = t.description;
      _taskNumber = t.taskNumber;
      _sprint = t.sprintNumber;
      _priority = t.priority;
      _deadline = t.deadline;
    } else {
      _title = '';
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: now.subtract(Duration(days: 365)),
      lastDate: now.add(Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();

    final task = (widget.initial ?? Task(title: _title, projectId: 1)).copyWith(
      title: _title,
      description: _description,
      taskNumber: _taskNumber,
      sprintNumber: _sprint,
      priority: _priority,
      deadline: _deadline,
    );

    widget.onSave(task);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.initial == null ? 'Add Task' : 'Edit Task',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Task name
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(
                  labelText: 'Task name *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.task),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                onSaved: (v) => _title = v!.trim(),
              ),
              SizedBox(height: 12),

              // Sprint number
              TextFormField(
                initialValue: _sprint?.toString(),
                decoration: InputDecoration(
                  labelText: 'Sprint number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                onSaved: (v) => _sprint = v!.isEmpty ? null : int.tryParse(v),
              ),
              SizedBox(height: 12),

              // Deadline
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Deadline',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _deadline != null
                        ? '${_deadline!.toLocal().toString().split(' ')[0]}'
                        : 'No deadline set',
                  ),
                ),
              ),
              SizedBox(height: 12),

              // Priority
              DropdownButtonFormField<TaskPriority>(
                value: _priority,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag),
                ),
                items: TaskPriority.values.map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p.toString().split('.').last),
                )).toList(),
                onChanged: (v) => setState(() => _priority = v!),
              ),
              SizedBox(height: 12),

              // Description
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                onSaved: (v) => _description = v?.trim(),
              ),
              SizedBox(height: 20),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B1C1C),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _submit,
                  child: Text(
                    'SAVE',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
