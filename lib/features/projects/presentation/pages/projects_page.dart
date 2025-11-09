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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              child: const Text("Delete")),
        ],
      ),
    ) ??
        false;
  }

  Widget _buildProjectTile(BuildContext ctx, int i, ProjectProvider prov) {
    final p = prov.projects[i];

    return Dismissible(
      key: ValueKey(p.id ?? i),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerRight,
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (dir) async {
        final ok = await _confirmDelete(ctx);
        if (ok && p.id != null) {
          final removed = await prov.deleteProject(p.id!);
          if (!removed && prov.error != null) {
            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(prov.error!)));
            return false;
          }
          ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Project deleted')));
          return true;
        }
        return false;
      },
      onDismissed: (_) async => _loadProjects(),
      child: Card(
        child: ListTile(
          title: Text(p.title),
          subtitle: Text(p.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: PopupMenuButton<String>(
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
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Project deleted')));
                    await _loadProjects();
                  }
                }
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => ProjectDetailsPage(projectId: p.id),
          )),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(builder: (context, prov, child) {
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
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Database reset')));
                }
              },
              itemBuilder: (_) => const [PopupMenuItem(value: 'reset_db', child: Text('Reset DB'))],
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _loadProjects,
          child: prov.isLoading
              ? const Center(child: CircularProgressIndicator())
              : prov.error != null
              ? Center(child: Text(prov.error!))
              : prov.projects.isEmpty
              ? const Center(child: Text('No projects'))
              : ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: prov.projects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (ctx, i) => _buildProjectTile(ctx, i, prov),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
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
