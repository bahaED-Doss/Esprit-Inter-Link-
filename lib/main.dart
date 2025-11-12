import 'package:esprit_interlink/shared/presentation/pages/role_select_screen.dart';
import 'package:esprit_interlink/shared/presentation/todo/student_project_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'features/projects/presentation/pages/project_create_page.dart';
import 'shared/presentation/pages/LoadingScreen.dart';
import 'shared/presentation/pages/SplashScreen.dart';
import 'shared/presentation/pages/student_home_page.dart';
import 'shared/presentation/pages/hr_home_page.dart';
import 'shared/presentation/pages/pm_home_page.dart';
import 'shared/presentation/todo/student_profile_page.dart';
import 'shared/presentation/todo/student_offers_page.dart';
import 'shared/presentation/todo/student_applications_page.dart';
import 'shared/presentation/todo/student_task_page.dart';
import 'shared/presentation/todo/hr_applications_page.dart';
import 'shared/presentation/todo/hr_candidates_page.dart';
import 'shared/presentation/todo/hr_profile_company_page.dart';
import 'shared/presentation/todo/pm_profile_page.dart';
import 'features/projects/presentation/pages/pm_projects_page.dart';
import 'shared/presentation/todo/pm_interns_page.dart';
import 'shared/presentation/todo/pm_tasks_page.dart';
import 'features/trophies/presentation/pages/student_trophies_page.dart';
import 'features/trophies/presentation/pages/trophies_pm_page.dart';
import 'features/trophies/presentation/pages/trophies_hr_page.dart';
import 'features/aplication/presentation/pages/internship_splash_screen.dart';
import 'features/aplication/presentation/pages/student_internship_list_page.dart';
import 'features/aplication/presentation/pages/student_applications_page.dart' as app_pages;
import 'features/aplication/providers/application_provider.dart';
import 'features/offres/presentation/pages/hr_internship_splash_screen.dart';
import 'features/offres/presentation/pages/hr_internship_list_page.dart';
import 'features/offres/presentation/pages/hr_applications_list_page.dart';
import 'data/datasources/local/database_helper.dart';
import 'features/projects/presentation/pages/projects_page.dart';
import 'package:provider/provider.dart';
import 'features/projects/providers/project_provider.dart';
import 'shared/providers/user_session_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement depuis le fichier `.env` si présent
  try {
    const envFile = '.env';
    await dotenv.load(fileName: envFile);
    // Debug: indiquer si dotenv est initialisé et si la clé est présente (ne pas afficher la clé)
    print('dotenv initialized: ${dotenv.isInitialized}');
    print('GEMINI_API_KEY present: ${dotenv.env['GEMINI_API_KEY']?.trim().isNotEmpty ?? false}');
    print('GEMINI_API_KEY2 present: ${dotenv.env['GEMINI_API_KEY2']?.trim().isNotEmpty ?? false}');
  } catch (e) {
    // ignore: avoid_print
    print('.env not found or failed to load: $e');
  }

  // Fallback: tenter de charger depuis un chemin absolu connu (utile si l'IDE change le working directory)
  if (!dotenv.isInitialized || (dotenv.env['GEMINI_API_KEY']?.trim().isEmpty ?? true)) {
    const fallbackPath = r'C:\Users\bahae\Documents\5sae8\Mobile Project\esprit_interlink\.env';
    try {
      await dotenv.load(fileName: fallbackPath);
      print('Fallback dotenv load attempted: initialized=${dotenv.isInitialized}, keyPresent=${dotenv.env['GEMINI_API_KEY']?.trim().isNotEmpty ?? false}, key2Present=${dotenv.env['GEMINI_API_KEY2']?.trim().isNotEmpty ?? false}');
      print('Fallback dotenv load attempted: initialized=${dotenv.isInitialized}, keyPresent=${dotenv.env['GEMINI_API_KEY']?.trim().isNotEmpty ?? false}');
    } catch (e) {
      print('Fallback dotenv load failed: $e');
    }
  }

  // Initialiser sqflite pour Windows/Desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialiser la base de données et afficher les informations
  try {
    print('🚀 Initializing database...');
    await DatabaseHelper.database; // Force la création/initialisation
    await DatabaseHelper.initializeMockProjectsIfNeeded(); // Insère les projets mock si besoin
    await DatabaseHelper.printDatabaseInfo();
  } catch (e) {
    print('❌ Database initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserSessionProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationProvider()), // Ajouté
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const LoadingScreen(),
        routes: {
          '/splash': (context) => SplashScreen(
                onNext: () {
                  Navigator.of(context).pushReplacementNamed('/role_select');
                },
              ),
          '/role_select': (context) => RoleSelectScreen(),
          '/student_home': (context) => const StudentHomePage(),
          '/hr_home': (context) => const HRHomePage(userId: 3), // HR mock userId
          '/pm_home': (context) => const PMHomePage(),
          '/studentProfile': (context) => const StudentProfilePage(),
          '/offers': (context) => const StudentOffersPage(),
          '/myApplications': (context) => const StudentApplicationsPage(),
          '/test': (context) => const StudentTestPage(),
          '/applications': (context) => const HRApplicationsPage(),
          '/candidates': (context) => const HRCandidatesPage(),
          '/companyProfile': (context) => const HRProfileCompanyPage(),
          '/pmProfile': (context) => const PMProfilePage(),
          '/projects': (context) => const ProjectsPage(),
          '/projects/create': (context) => const ProjectCreatePage(),
          '/interns': (context) => const PMInternsPage(),
          '/tasks': (context) => const PMTasksPage(),
          '/trophies': (context) => const StudentTrophiesPage(),
          '/trophies_hr': (context) => const TrophiesHRPage(),
          '/trophies_pm': (context) => const TrophiesPMPage(),
          '/internship_splash': (context) => InternshipSplashScreen(
                onNext: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const StudentInternshipListPage(studentId: 1),
                    ),
                  );
                },
              ),
          '/internship_list': (context) => const StudentInternshipListPage(studentId: 1),
          '/my_applications': (context) => const app_pages.StudentApplicationsPage(studentId: 1),
          '/hr_internship_splash': (context) => HRInternshipSplashScreen(
                onNext: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const HRInternshipListPage(hrId: 3),
                    ),
                  );
                },
              ),
          '/hr_internship_list': (context) => const HRInternshipListPage(hrId: 3),
        },
        onGenerateRoute: (settings) {
          // Handle routes with arguments
          if (settings.name == '/hr_applications') {
            final internshipId = settings.arguments as int;
            return MaterialPageRoute(
              builder: (_) => HRApplicationsListPage(internshipId: internshipId),
            );
          }
          return null;
        },
      ),
    );
  }
}
