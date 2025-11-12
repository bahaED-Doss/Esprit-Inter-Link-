import 'package:flutter/material.dart';
  import '../../../../data/datasources/local/database_helper.dart';

class ProjectsDbInspectorPage extends StatefulWidget {
  const ProjectsDbInspectorPage({Key? key}) : super(key: key);

  @override
  State<ProjectsDbInspectorPage> createState() => _ProjectsDbInspectorPageState();
}

class _ProjectsDbInspectorPageState extends State<ProjectsDbInspectorPage> {
  List<Map<String, dynamic>> _rows = [];
  List<String> _cols = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final db = await DatabaseHelper.database;
      final rows = await db.rawQuery('SELECT * FROM projects ORDER BY id DESC');
      final pragma = await db.rawQuery("PRAGMA table_info('projects')");
      final cols = pragma.map((r) => r['name'] as String).toList();
      setState(() {
        _rows = rows;
        _cols = cols;
      });
    } catch (_) {
      setState(() {
        _rows = [];
        _cols = [];
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects DB Inspector'), actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _load)]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Columns: ${_cols.join(', ')}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _rows.length,
                      itemBuilder: (ctx, i) {
                        final row = _rows[i];
                        return Card(
                          child: ListTile(
                            title: Text(row['name'] ?? '<no name>'),
                            subtitle: Text(_cols.map((c) => '$c: ${row[c]}').join('\n')),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
