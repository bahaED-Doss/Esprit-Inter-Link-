import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:esprit_interlink/features/projects/presentation/pages/project_create_page.dart';
import 'package:esprit_interlink/features/projects/providers/project_provider.dart';
import 'package:esprit_interlink/shared/providers/user_session_provider.dart';
import 'package:esprit_interlink/shared/models/user_role.dart';
import 'package:esprit_interlink/features/projects/models/project_model.dart';

class FakeProjectProvider extends ProjectProvider {
  final List<Project> _projects = [];

  FakeProjectProvider() : super();

  @override
  List<Project> get projects => _projects;

  @override
  bool get isLoading => false;

  @override
  String? get error => null;

  @override
  String get search => '';

  @override
  Future<void> loadProjects({int? pmId}) async => Future.value();

  @override
  void setSearch(String q) {}

  @override
  Future<bool> addProject(Project p) async {
    final nextId = (_projects.isEmpty) ? 1 : (_projects.map((e) => e.id ?? 0).reduce((a, b) => a > b ? a : b) + 1);
    _projects.insert(0, p.copyWith(id: nextId));
    notifyListeners();
    return true;
  }

  @override
  Future<bool> editProject(Project p) async {
    final idx = _projects.indexWhere((x) => x.id == p.id);
    if (idx != -1) _projects[idx] = p;
    notifyListeners();
    return true;
  }

  @override
  Future<bool> deleteProject(int id) async {
    return removeProject(id);
  }

  @override
  Future<bool> removeProject(int id) async {
    _projects.removeWhere((p) => p.id == id);
    notifyListeners();
    return true;
  }

  @override
  Future<Project?> getProjectById(int id) async {
    try {
      return _projects.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

// The rest of ProjectProvider's API remains inherited
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('ProjectCreatePage - create project adds to provider', (WidgetTester tester) async {
    final projProv = FakeProjectProvider();
    final session = UserSessionProvider();
    await session.login(userId: '2', email: 'pm@esprit.tn', name: 'PM', role: UserRole.projectManager);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<UserSessionProvider>.value(value: session),
          ChangeNotifierProvider<ProjectProvider>.value(value: projProv),
        ],
        child: MaterialApp(
          home: ProjectCreatePage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Enter title into the first TextFormField (Title)
    final titleField = find.byType(TextFormField).first;
    expect(titleField, findsOneWidget);
    await tester.enterText(titleField, 'Widget Test Project');

    // Tap Create
    final createLabel = find.text('Create');
    expect(createLabel, findsOneWidget);
    await tester.tap(createLabel);

    // Wait for async operations
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify the project was added to the provider (title matches)
    final exists = projProv.projects.any((p) => p.title == 'Widget Test Project');
    expect(exists, isTrue, reason: 'Project was not added to ProjectProvider');
  });
}