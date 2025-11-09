import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../features/projects/providers/project_provider.dart';
import '../../../features/projects/presentation/pages/project_details_page.dart';
import '../../../features/projects/presentation/pages/project_create_page.dart';
import '/shared/providers/user_session_provider.dart';

class PMProjectsPage extends StatefulWidget {
  const PMProjectsPage({Key? key}) : super(key: key);

  @override
  State<PMProjectsPage> createState() => _PMProjectsPageState();
}

class _PMProjectsPageState extends State<PMProjectsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProjects());
  }

  Future<void> _loadProjects() async {
    final prov = Provider.of<ProjectProvider>(context, listen: false);
    final session = Provider.of<UserSessionProvider>(context, listen: false);
    final pmId = session.isPM ? int.tryParse(session.userId ?? '') ?? 2 : 2;
    await prov.loadProjects(pmId: pmId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProjectProvider>(
      builder: (context, prov, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Projets'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: 'Create project',
                onPressed: () async {
                  final res = await Navigator.of(context).push(MaterialPageRoute(
                    builder: (ctx) => const ProjectCreatePage(),
                  ));
                  if (res == 'created') {
                    final session = Provider.of<UserSessionProvider>(context, listen: false);
                    final pmId = session.isPM ? int.tryParse(session.userId ?? '') ?? 2 : 2;
                    await prov.loadProjects(pmId: pmId);
                  }
                },
              ),
            ],
          ),
          body: prov.isLoading
              ? const Center(child: CircularProgressIndicator())
              : prov.error != null
                  ? Center(child: Text(prov.error!))
                  : prov.projects.isEmpty
                      ? const Center(child: Text('Aucun projet trouvé'))
                      : ListView.builder(
                          itemCount: prov.projects.length,
                          itemBuilder: (context, i) {
                            final p = prov.projects[i];
                            return ListTile(
                              title: Text(p.title),
                              subtitle: Text(p.description ?? ''),
                              trailing: Text(p.status),
                              onTap: () async {
                                final res = await Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => ProjectDetailsPage(projectId: p.id!),
                                ));
                                if (res == 'updated' || res == 'deleted') {
                                  // reload projects
                                  final session = Provider.of<UserSessionProvider>(context, listen: false);
                                  final pmId = session.isPM ? int.tryParse(session.userId ?? '') ?? 2 : 2;
                                  await prov.loadProjects(pmId: pmId);
                                }
                              },
                            );
                          },
                        ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final res = await Navigator.of(context).push(MaterialPageRoute(
                builder: (ctx) => const ProjectCreatePage(),
              ));
              if (res == 'created') {
                final session = Provider.of<UserSessionProvider>(context, listen: false);
                final pmId = session.isPM ? int.tryParse(session.userId ?? '') ?? 2 : 2;
                await prov.loadProjects(pmId: pmId);
              }
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
