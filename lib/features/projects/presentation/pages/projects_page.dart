import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import 'project_details_page.dart';
import '../../../../shared/providers/user_session_provider.dart';
import '../../../../data/datasources/local/database_helper.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({Key? key}) : super(key: key);

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _sortBy = 'date';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProjects());
  }

  Future<void> _loadProjects() async {
    final prov = Provider.of<ProjectProvider>(context, listen: false);
    final session = Provider.of<UserSessionProvider>(context, listen: false);
    final pmId = session.isPM ? int.tryParse(session.userId ?? '') ?? 0 : 0;
    await prov.loadProjects(pmId: pmId);
  }

  Future<bool> _confirmDelete(BuildContext ctx) async {
    return await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text("Delete project?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    ) ??
        false;
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case 'Completed':
        color = Colors.green;
        break;
      case 'Active':
        color = Colors.blue;
        break;
      case 'Planning':
        color = Colors.orange;
        break;
      case 'On Hold':
        color = Colors.amber;
        break;
      case 'Cancelled':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w600),
      side: BorderSide(color: color),
    );
  }

  Future<void> _showAssignStudentDialog(BuildContext ctx, int projectId) async {
    final emailCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool loading = false;
    await showDialog(
      context: ctx,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Assigner un étudiant'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email étudiant',
                  hintText: 'student@example.com',
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Champ requis';
                  final pattern = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+");
                  return pattern.hasMatch(v.trim()) ? null : 'Email invalide';
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Annuler'),
              ),
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setState(() => loading = true);
                        final email = emailCtrl.text.trim();
                        final db = await DatabaseHelper.database;
                        final users = await db.query('users', where: 'email = ?', whereArgs: [email], limit: 1);
                        if (users.isEmpty) {
                          setState(() => loading = false);
                          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Utilisateur introuvable')));
                          return;
                        }
                        final studentId = users.first['id'] as int;
                        final already = await db.query('projects', where: 'student_id = ?', whereArgs: [studentId], limit: 1);
                        if (already.isNotEmpty) {
                          setState(() => loading = false);
                          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Cet étudiant est déjà assigné à un projet')));
                          return;
                        }
                        // Mettre à jour le projet
                        final prov = Provider.of<ProjectProvider>(ctx, listen: false);
                        final project = prov.filteredProjects.firstWhere((p) => p.id == projectId);
                        final updated = project.copyWith(studentId: studentId, assignedToEmail: email);
                        final ok = await prov.editProject(updated);
                        setState(() => loading = false);
                        if (ok) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Étudiant assigné avec succès')));
                        } else {
                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(prov.error ?? 'Erreur lors de l\'assignation')));
                        }
                      },
                child: loading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Assigner'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectTile(BuildContext ctx, int i, ProjectProvider prov) {
    final p = prov.filteredProjects[i];
    final progress = (p.progress ?? 0) / 100.0;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ProjectDetailsPage(projectId: p.id),
        )),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    p.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) async {
                    if (v == 'edit') {
                      await Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => ProjectDetailsPage(projectId: p.id, forceEdit: true),
                      ));
                      await _loadProjects();
                    } else if (v == 'delete' && p.id != null) {
                      final ok = await _confirmDelete(ctx);
                      if (ok) {
                        final removed = await prov.deleteProject(p.id!);
                        if (!removed && prov.error != null) {
                          ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(prov.error!)));
                        } else {
                          ScaffoldMessenger.of(ctx)
                              .showSnackBar(const SnackBar(content: Text('Project deleted')));
                          await _loadProjects();
                        }
                      }
                    } else if (v == 'assign' && p.id != null) {
                      await _showAssignStudentDialog(ctx, p.id!);
                      await _loadProjects();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                    PopupMenuItem(value: 'assign', child: Text('Assigner étudiant')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              p.description ?? 'No description',
              style: TextStyle(color: Colors.grey[700]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatusChip(p.status ?? 'Pending'),
                const SizedBox(width: 10),
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: Colors.grey[200],
                    color: progress < 1.0 ? Colors.blueAccent : Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${p.progress ?? 0}%',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(builder: (context, prov, child) {
      final projects = prov.filteredProjects;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Projects'),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProjects),
            PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'reset_db') {
                  await DatabaseHelper.resetDatabase();
                  await _loadProjects();
                  if (mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Database reset')));
                  }
                }
              },
              itemBuilder: (_) => const [PopupMenuItem(value: 'reset_db', child: Text('Reset DB'))],
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search projects...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25), borderSide: BorderSide.none),
                    ),
                    onChanged: (v) => prov.filterProjects(v),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    setState(() => _sortBy = v);
                    prov.sortProjects(v);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'title', child: Text('Sort by Title')),
                    PopupMenuItem(value: 'date', child: Text('Sort by Date')),
                    PopupMenuItem(value: 'status', child: Text('Sort by Status')),
                  ],
                  child: const Icon(Icons.sort),
                )
              ]),
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _loadProjects,
          child: prov.isLoading
              ? const Center(child: CircularProgressIndicator())
              : prov.error != null
              ? Center(child: Text(prov.error!))
              : projects.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 12),
                const Text('No projects found', style: TextStyle(fontSize: 16)),
              ],
            ),
          )
              : ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: projects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) => _buildProjectTile(ctx, i, prov),
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.add),
          label: const Text("New Project"),
          onPressed: () async {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => const ProjectDetailsPage(forceEdit: true),
            ));
            await _loadProjects();
          },
        ),
      );
    });
  }
}
