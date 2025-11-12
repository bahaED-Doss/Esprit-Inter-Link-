import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import 'project_create_page.dart';
import '../../../tasks/presentation/pages/pm_task_view.dart';
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
    return Scaffold(appBar: AppBar(title: const Text('Projets')), body: const Center(child: Text('Projets PM')));
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
                                await Navigator.of(context).push(MaterialPageRoute(
                                  builder: (ctx) => PMTaskView(
                                    projectId: p.id!,
                                    projectName: p.title,
                                  ),
                                ));
                                // Si besoin, recharger les projets ici
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
