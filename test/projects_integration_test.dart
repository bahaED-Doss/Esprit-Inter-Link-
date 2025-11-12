import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:esprit_interlink/data/datasources/local/database_helper.dart';
import 'package:esprit_interlink/features/projects/data/project_database_helper.dart';
import 'package:esprit_interlink/features/projects/models/project_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // initialize ffi implementation for tests
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    // ensure fresh DB
    await DatabaseHelper.resetDatabase();
  });

  test('projects CRUD flow using local DB', () async {
    final dbHelper = ProjectDatabaseHelper();

    // initialize mock projects
    await DatabaseHelper.initializeMockProjectsIfNeeded();

    // Load all projects
    var all = await dbHelper.getAllProjects();
    expect(all.length, greaterThanOrEqualTo(3));

    // Insert a project
    final newProject = Project(title: 'Test Project', pmId: 2, description: 'Desc');
    final id = await dbHelper.insertProject(newProject);
    expect(id, isNonZero);

    // Read it back
    final fetched = await dbHelper.getProjectById(id);
    expect(fetched, isNotNull);
    expect(fetched!.title, 'Test Project');

    // Update it
    final updated = fetched.copyWith(title: 'Updated Title');
    await dbHelper.updateProject(updated);
    final fetched2 = await dbHelper.getProjectById(id);
    expect(fetched2!.title, 'Updated Title');

    // Delete it
    await dbHelper.deleteProject(id);
    final deleted = await dbHelper.getProjectById(id);
    expect(deleted, isNull);
  });
}

