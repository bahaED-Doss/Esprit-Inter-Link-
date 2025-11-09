import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../projects/models/project_model.dart';
import '../../../projects/providers/project_provider.dart';
import '../../../../shared/providers/user_session_provider.dart';
import '../../data/project_database_helper.dart';
import '../widgets/project_task_list.dart';
// ADD THESE IMPORTS - adjust paths as needed
import '../../../../features/tasks/providers/task_provider.dart';
import '../../../../features/tasks/presentation/widgets/task_form_dialog.dart';

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
  late String _selectedStatus;

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;

  final List<String> _selectedTechnologies = [];
  final List<String> _availableTechStacks = [
    'Flutter', 'Dart', 'React', 'React Native', 'Vue.js', 'Angular',
    'Node.js', 'Express.js', 'Python', 'Django', 'Flask', 'FastAPI',
    'Java', 'Spring Boot', 'Kotlin', 'Swift', 'Objective-C',
    'PHP', 'Laravel', 'Symfony', 'Ruby', 'Ruby on Rails',
    'C#', '.NET', 'ASP.NET', 'Go', 'Rust',
    'MySQL', 'PostgreSQL', 'MongoDB', 'Redis', 'SQLite',
    'Firebase', 'AWS', 'Docker', 'Kubernetes', 'Git',
    'REST API', 'GraphQL', 'gRPC', 'WebSocket',
    'JavaScript', 'TypeScript', 'HTML5', 'CSS3', 'SASS',
    'Android', 'iOS', 'Windows', 'Linux', 'macOS',
    'TensorFlow', 'PyTorch', 'OpenCV', 'Pandas', 'NumPy',
    'Figma', 'Adobe XD', 'Sketch', 'Blender',
  ];

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

    _selectedStatus = _project!.status ?? 'Planning';
    _selectedStartDate = _project!.startDate;
    _selectedEndDate = _project!.endDate;

    if (_project!.technologiesUsed != null && _project!.technologiesUsed!.isNotEmpty) {
      _selectedTechnologies.addAll(_project!.technologiesUsed!.split(',').map((tech) => tech.trim()).toList());
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _techController.dispose();
    super.dispose();
  }

  // Date picker for start date
  Future<void> _pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  // Date picker for end date
  Future<void> _pickEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? (_selectedStartDate ?? DateTime.now()).add(const Duration(days: 30)),
      firstDate: _selectedStartDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedEndDate) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  // Status selection dialog
  Future<void> _selectStatus() async {
    final statuses = ['Planning', 'Active', 'On Hold', 'Completed', 'Cancelled'];

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Status'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: statuses.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(statuses[index]),
                  onTap: () {
                    setState(() {
                      _selectedStatus = statuses[index];
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Technology selection dialog
  Future<void> _selectTechnologies() async {
    final selectedTechs = List<String>.from(_selectedTechnologies);

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.code, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Select Technologies'),
                ],
              ),
              content: SizedBox(
                width: double.maxFinite,
                height: MediaQuery.of(context).size.height * 0.6,
                child: Column(
                  children: [
                    // Selected technologies chips
                    if (selectedTechs.isNotEmpty) ...[
                      SizedBox(
                        height: 60,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Selected:', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: selectedTechs.map((tech) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Chip(
                                      label: Text(tech),
                                      onDeleted: () {
                                        setDialogState(() {
                                          selectedTechs.remove(tech);
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Available technologies list
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _availableTechStacks.length,
                        itemBuilder: (BuildContext context, int index) {
                          final tech = _availableTechStacks[index];
                          final isSelected = selectedTechs.contains(tech);

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            color: isSelected ? Colors.blue.withOpacity(0.1) : null,
                            child: ListTile(
                              leading: Icon(
                                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                color: isSelected ? Colors.blue : Colors.grey,
                              ),
                              title: Text(tech),
                              onTap: () {
                                setDialogState(() {
                                  if (isSelected) {
                                    selectedTechs.remove(tech);
                                  } else {
                                    selectedTechs.add(tech);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedTechnologies.clear();
                      _selectedTechnologies.addAll(selectedTechs);
                      _techController.text = _selectedTechnologies.join(', ');
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Quick tech stacks presets
  void _showTechStackPresets() {
    final techStackPresets = {
      'Flutter Mobile': ['Flutter', 'Dart', 'Firebase', 'REST API'],
      'React Web App': ['React', 'JavaScript', 'Node.js', 'MongoDB'],
      'Python Data Science': ['Python', 'Pandas', 'NumPy', 'TensorFlow'],
      'Full Stack JavaScript': ['React', 'Node.js', 'Express.js', 'MongoDB'],
      'Java Enterprise': ['Java', 'Spring Boot', 'MySQL', 'Docker'],
    };

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Tech Stacks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...techStackPresets.entries.map((entry) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.architecture),
                    title: Text(entry.key),
                    subtitle: Text(entry.value.join(', ')),
                    onTap: () {
                      setState(() {
                        _selectedTechnologies.clear();
                        _selectedTechnologies.addAll(entry.value);
                        _techController.text = _selectedTechnologies.join(', ');
                      });
                      Navigator.pop(context);
                    },
                  ),
                );
              }),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ProjectProvider>(context, listen: false);
    final updated = _project!.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      technologiesUsed: _techController.text.trim(),
      status: _selectedStatus,
      startDate: _selectedStartDate,
      endDate: _selectedEndDate,
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

  // UPDATED METHOD: Use TaskFormDialog instead of navigation
  void _navigateToAddTask() {
    if (_project?.id == null) {
      _showSnackBar("Please save the project first before adding tasks");
      return;
    }

    showDialog(
      context: context,
      builder: (_) => TaskFormDialog(
        onSave: (task) {
          final toInsert = task.copyWith(projectId: _project!.id);
          // Get the TaskProvider and add the task
          final taskProvider = Provider.of<TaskProvider>(context, listen: false);
          taskProvider.addTask(toInsert).then((_) {
            // Refresh the task list after adding
            setState(() {});
          });
        },
      ),
    );
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

          if (!isNew && !_isEditing)
            IconButton(
              icon: const Icon(Icons.add_task),
              onPressed: _navigateToAddTask,
              tooltip: "Add Task",
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title Field
              _isEditing
                  ? TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (v) => v == null || v.isEmpty ? "Title required" : null,
              )
                  : _infoTile("Title", _project!.title),
              const SizedBox(height: 12),

              // Description Field
              _isEditing
                  ? TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
              )
                  : _infoTile("Description", _project!.description ?? "—"),
              const SizedBox(height: 12),

              // Technologies Field - Enhanced
              _isEditing
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Technologies Used",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),

                  // Selected technologies chips
                  if (_selectedTechnologies.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _selectedTechnologies.map((tech) {
                        return Chip(
                          label: Text(tech),
                          onDeleted: () {
                            setState(() {
                              _selectedTechnologies.remove(tech);
                              _techController.text = _selectedTechnologies.join(', ');
                            });
                          },
                        );
                      }).toList(),
                    ),

                  const SizedBox(height: 12),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _selectTechnologies,
                          icon: const Icon(Icons.architecture),
                          label: const Text('Choose Technologies'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _showTechStackPresets,
                        icon: const Icon(Icons.auto_awesome),
                        tooltip: 'Quick Stacks',
                      ),
                    ],
                  ),
                ],
              )
                  : _infoTile("Technologies", _project!.technologiesUsed ?? "—"),
              const SizedBox(height: 12),

              // Status Field - Now Editable
              _isEditing
                  ? _editableStatusField()
                  : _infoTile("Status", _project!.status ?? "Planning"),

              // Start Date Field - Now Editable
              _isEditing
                  ? _editableDateField(
                label: "Start Date",
                date: _selectedStartDate,
                onTap: _pickStartDate,
              )
                  : _infoTile("Start Date", _selectedStartDate != null ? df.format(_selectedStartDate!) : "—"),

              // End Date Field - Now Editable
              _isEditing
                  ? _editableDateField(
                label: "End Date",
                date: _selectedEndDate,
                onTap: _pickEndDate,
              )
                  : _infoTile("End Date", _selectedEndDate != null ? df.format(_selectedEndDate!) : "—"),

              const SizedBox(height: 24),
              const Divider(),

              // Tasks Section
              Row(
                children: [
                  const Text("Tasks", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Spacer(),
                  if (!isNew && !_isEditing)
                    ElevatedButton.icon(
                      onPressed: _navigateToAddTask,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text("Add Task"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (_project!.id != null) ProjectTaskList(projectId: _project!.id!),
            ],
          ),
        ),
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton.extended(
          onPressed: _saveProject,
          label: const Text("Save"),
          icon: const Icon(Icons.check))
          : (!isNew ? FloatingActionButton(
        onPressed: _navigateToAddTask,
        child: const Icon(Icons.add_task),
        tooltip: "Add Task",
      ) : null),
    );
  }

  // Editable status field widget
  Widget _editableStatusField() {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: ListTile(
        title: const Text("Status", style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(_selectedStatus),
        trailing: const Icon(Icons.arrow_drop_down),
        onTap: _selectStatus,
      ),
    );
  }

  // Editable date field widget
  Widget _editableDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    final df = DateFormat('yyyy-MM-dd');
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(date != null ? df.format(date) : "Not set"),
        trailing: const Icon(Icons.calendar_today),
        onTap: onTap,
      ),
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