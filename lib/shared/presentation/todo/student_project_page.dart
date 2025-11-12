import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/datasources/local/database_helper.dart';
import '../../providers/user_session_provider.dart';
import '../../../features/projects/presentation/pages/project_details_page.dart';

class StudentProjectPage extends StatefulWidget {
  const StudentProjectPage({Key? key}) : super(key: key);

  @override
  State<StudentProjectPage> createState() => _StudentProjectPageState();
}

class _StudentProjectPageState extends State<StudentProjectPage> {
  bool _loading = true;
  int? _projectId;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final session = Provider.of<UserSessionProvider>(context, listen: false);
      final email = session.userEmail ?? 'student@esprit.tn';
      final proj = await DatabaseHelper.getProjectAssignedToStudent(email);
      if (proj != null) {
        final id = proj['id'] as int?;
        if (id != null) {
          // navigate to ProjectDetailsPage
          if (mounted) {
            await Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ProjectDetailsPage(projectId: id),
            ));
            // when returning, go back to previous screen
            if (mounted) Navigator.of(context).pop();
          }
          return;
        }
      }
      setState(() {
        _error = 'No project assigned to current student.';
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load project: $e';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Project')),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _error != null
                ? Text(_error!)
                : const Text('Opening project...'),
      ),
    );
  }
}

