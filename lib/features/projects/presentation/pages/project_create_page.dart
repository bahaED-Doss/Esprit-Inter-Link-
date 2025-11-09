import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../../../shared/providers/user_session_provider.dart';
import '../../models/project_model.dart';
import '../../data/project_database_helper.dart';

class ProjectCreatePage extends StatefulWidget {
  const ProjectCreatePage({Key? key}) : super(key: key);

  @override
  State<ProjectCreatePage> createState() => _ProjectCreatePageState();
}

class _ProjectCreatePageState extends State<ProjectCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _techCtrl = TextEditingController();
  final _assignedCtrl = TextEditingController();
  DateTime? _start;
  DateTime? _end;
  String _status = 'ACTIVE';
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _techCtrl.dispose();
    _assignedCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext ctx, bool isStart) async {
    final initial = isStart ? (_start ?? DateTime.now()) : (_end ?? DateTime.now());
    final d = await showDatePicker(context: ctx, initialDate: initial, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (d == null) return;
    setState(() {
      if (isStart) _start = d; else _end = d;
    });
  }

  int _getPmIdSafe() {
    try {
      final session = Provider.of<UserSessionProvider>(context, listen: false);
      return session.isPM ? int.tryParse(session.userId ?? '') ?? 2 : 2;
    } catch (_) {
      return 2; // fallback
    }
  }

  bool _isValidEmail(String? v) {
    if (v == null || v.trim().isEmpty) return true; // optional field
    final pattern = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$");
    return pattern.hasMatch(v.trim());
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_start != null && _end != null && _start!.isAfter(_end!)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Start date must be before end date')));
      return;
    }

    setState(() => _saving = true);
    final pmId = _getPmIdSafe();

    final p = Project(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      technologiesUsed: _techCtrl.text.trim(),
      startDate: _start,
      endDate: _end,
      status: _status,
      pmId: pmId,
      assignedToEmail: _assignedCtrl.text.trim().isNotEmpty ? _assignedCtrl.text.trim() : null,
    );

    try {
      // Try provider first
      try {
        final prov = Provider.of<ProjectProvider>(context, listen: false);
        final ok = await prov.addProject(p);
        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(prov.error ?? 'Failed to create project')));
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project created')));
        if (mounted) Navigator.of(context).pop('created');
        return;
      } catch (e) {
        // Provider lookup failed -> fallback to DB helper
        // ignore: avoid_print
        print('ProjectCreatePage: provider not available, falling back to DB helper: $e');
        try {
          final helper = ProjectDatabaseHelper();
          await helper.insertProject(p);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project created')));
          if (mounted) Navigator.of(context).pop('created');
          return;
        } catch (dbErr) {
          // insert failed
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('DB error: $dbErr')));
          return;
        }
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Project')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _techCtrl,
                  decoration: const InputDecoration(labelText: 'Technologies'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _assignedCtrl,
                  decoration: const InputDecoration(labelText: 'Assigned student email (optional)'),
                  validator: (v) => _isValidEmail(v) ? null : 'Enter a valid email',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ListTile(
                        title: Text(_start != null ? _start!.toIso8601String().split('T').first : '-'),
                        subtitle: const Text('Start Date'),
                        onTap: () => _pickDate(context, true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ListTile(
                        title: Text(_end != null ? _end!.toIso8601String().split('T').first : '-'),
                        subtitle: const Text('End Date'),
                        onTap: () => _pickDate(context, false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  items: const [
                    DropdownMenuItem(value: 'ACTIVE', child: Text('Active')),
                    DropdownMenuItem(value: 'COMPLETED', child: Text('Completed')),
                    DropdownMenuItem(value: 'ON_HOLD', child: Text('On Hold')),
                    DropdownMenuItem(value: 'ARCHIVED', child: Text('Archived')),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? _status),
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
                  label: Text(_saving ? 'Saving...' : 'Create'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
