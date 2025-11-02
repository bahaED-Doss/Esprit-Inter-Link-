import 'package:flutter/material.dart';
import '../../models/task_model.dart';

/// Widget pour afficher un badge de priorité coloré
class PriorityTag extends StatelessWidget {
  final TaskPriority priority;

  const PriorityTag({required this.priority, Key? key}) : super(key: key);

  Color _color() {
    switch (priority) {
      case TaskPriority.High:
        return Colors.redAccent;
      case TaskPriority.Medium:
        return Colors.orange;
      case TaskPriority.Low:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color().withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority.toString().split('.').last,
        style: TextStyle(
          color: _color(),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

