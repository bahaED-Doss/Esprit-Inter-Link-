import 'package:esprit_interlink/shared/presentation/pages/role_select_screen.dart';
import 'package:flutter/material.dart';
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
import 'shared/presentation/todo/pm_projects_page.dart';
import 'shared/presentation/todo/pm_interns_page.dart';
import 'shared/presentation/todo/pm_tasks_page.dart';
import 'features/trophies/presentation/pages/student_trophies_page.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        '/hr_home': (context) => const HRHomePage(),
        '/pm_home': (context) => const PMHomePage(),
        '/studentProfile': (context) => const StudentProfilePage(),
        '/offers': (context) => const StudentOffersPage(),
        '/myApplications': (context) => const StudentApplicationsPage(),
        '/test': (context) => const StudentTestPage(),
        '/applications': (context) => const HRApplicationsPage(),
        '/candidates': (context) => const HRCandidatesPage(),
        '/companyProfile': (context) => const HRProfileCompanyPage(),
        '/pmProfile': (context) => const PMProfilePage(),
        '/projects': (context) => const PMProjectsPage(),
        '/interns': (context) => const PMInternsPage(),
        '/tasks': (context) => const PMTasksPage(),
        '/trophies': (context) => StudentTrophiesPage(
              trophies: [
                TrophyModel(
                  id: '1',
                  name: 'Rising Star',
                  description: 'Received Outstanding Feedback',
                  xpPoints: 250,
                  message: 'Your supervisor is impressed. Shine bright!',
                  locked: false,
                  iconName: 'star',
                ),
                TrophyModel(
                  id: '2',
                  name: 'Welcome Aboard!',
                  description: 'You\'re officially an intern',
                  xpPoints: 100,
                  message: 'Your journey begins here. Time to make an impact!',
                  locked: true,
                  iconName: 'bag',
                ),
                TrophyModel(
                  id: '3',
                  name: 'Quiz Master',
                  description: 'Completed all quizzes',
                  xpPoints: 150,
                  message: 'Knowledge is power!',
                  locked: true,
                  iconName: 'medal',
                ),
              ],
            ),
      },
    );
  }
}
