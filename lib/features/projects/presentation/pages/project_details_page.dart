import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../projects/models/project_model.dart';
import '../../../projects/providers/project_provider.dart';
import '../../../../shared/providers/user_session_provider.dart';
import '../../data/project_database_helper.dart';
import '../widgets/project_task_list.dart';

class ProjectDetailsPage extends StatefulWidget {
  final Project? project;
  final int? projectId;
  final bool forceEdit;

  const ProjectDetailsPage({Key? key, this.project, this.projectId, this.forceEdit = false})
      : super(key: key);

  @override
  State<ProjectDetailsPage> createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  Project? _project;
  bool _isEditing = false;
  bool _isLoading = false;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _techController;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.forceEdit;
    _loadProject();
  }

  Future<void> _loadProject() async {
    setState(() => _isLoading = true);
    final session = Provider.of<UserSessionProvider>(context, listen: false);

    _project = widget.project ??
        (widget.projectId != null ? await ProjectDatabaseHelper().getProjectById(widget.projectId!) : null) ??
        Project(title: '', pmId: int.tryParse(session.userId ?? '0') ?? 0);

    _isEditing = widget.forceEdit || _project!.id == null;

    _titleController = TextEditingController(text: _project!.title);
    _descriptionController = TextEditingController(text: _project!.description ?? '');
    _techController = TextEditingController(text: _project!.technologiesUsed ?? '');

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _techController.dispose();
    super.dispose();
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ProjectProvider>(context, listen: false);
    final updated = _project!.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      technologiesUsed: _techController.text.trim(),
    );

    final success = await provider.saveProject(updated);
    if (success) {
      setState(() {
        _project = updated;
        _isEditing = false;
      });
      _showSnackBar("✅ Project saved successfully");
    } else {
      _showSnackBar("❌ Failed to save project");
    }
  }

  Future<void> _deleteProject() async {
    final provider = Provider.of<ProjectProvider>(context, listen: false);
    final confirmed = await _confirmDeleteDialog();
    if (!confirmed) return;

    if (_project!.id != null) {
      final success = await provider.deleteProject(_project!.id!);
      if (success) {
        Navigator.pop(context);
        _showSnackBar("🗑️ Project deleted");
      } else {
        _showSnackBar("❌ Failed to delete project");
      }
    }
  }

  Future<bool> _confirmDeleteDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Project?"),
        content: const Text("Are you sure you want to delete this project? This cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete")),
        ],
      ),
    ) ??
        false;
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy-MM-dd');

    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final isNew = _project!.id == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? "New Project" : _project!.title),
        actions: [
          if (!_isEditing && !isNew)
            IconButton(icon: const Icon(Icons.edit), onPressed: () => setState(() => _isEditing = true)),
          if (_isEditing) IconButton(icon: const Icon(Icons.check), onPressed: _saveProject),
          if (_isEditing) IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _isEditing = false)),
          if (!isNew) IconButton(icon: const Icon(Icons.delete), onPressed: _deleteProject),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _isEditing
                  ? TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (v) => v == null || v.isEmpty ? "Title required" : null,
              )
                  : _infoTile("Title", _project!.title),
              const SizedBox(height: 12),
              _isEditing
                  ? TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              )
                  : _infoTile("Description", _project!.description ?? "—"),
              const SizedBox(height: 12),
              _isEditing
                  ? TextFormField(
                controller: _techController,
                decoration: const InputDecoration(labelText: "Technologies Used"),
              )
                  : _infoTile("Technologies", _project!.technologiesUsed ?? "—"),
              const SizedBox(height: 12),
              _infoTile("Status", _project!.status),
              _infoTile("Start Date", _project!.startDate != null ? df.format(_project!.startDate!) : "—"),
              _infoTile("End Date", _project!.endDate != null ? df.format(_project!.endDate!) : "—"),
              const SizedBox(height: 24),
              const Divider(),
              const Text("Tasks", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 8),
              if (_project!.id != null) ProjectTaskList(projectId: _project!.id!),
            ],
          ),
        ),
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton.extended(
          onPressed: _saveProject, label: const Text("Save"), icon: const Icon(Icons.check))
          : null,
    );
  }

  Widget _infoTile(String label, String value) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
