import 'package:esprit_interlink/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;

// Imports de base de données
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:esprit_interlink/data/datasources/local/database_service.dart'; // 🚀 Utiliser DatabaseService (le Singleton)

// Imports des Providers
import 'features/projects/providers/project_provider.dart';
import 'features/aplication/providers/application_provider.dart';
import 'shared/providers/user_session_provider.dart';

// Import du Routeur
import 'routes/app_router.dart';
import 'core/theme/app_theme.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();



  // Charger les variables d'environnement (DotEnv)
  try {
    const envFile = '.env';
    await dotenv.load(fileName: envFile);
    print('✅ .env loaded successfully.');
  } catch (e) {
    print('⚠️ .env not found or failed to load, proceeding without it. Error: $e');
    // Tenter le fallback si nécessaire (code dotenv existant)
  }

  // Initialiser sqflite pour Windows/Desktop si nécessaire
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // 🚀 2. Initialiser la base de données (DatabaseService Singleton)
  try {
    print('🚀 Initializing DatabaseService...');
    // Appeler .database force l'initialisation de _initDatabase() dans le singleton
    await DatabaseService().database;
    print('✅ DatabaseService initialized.');

    // (Optionnel : si vous avez besoin de données mock au démarrage)
    // await DatabaseService().initializeMockProjectsIfNeeded();
    // await DatabaseService().printDatabaseInfo();

  } catch (e) {
    print('❌ CRITICAL: Database initialization failed: $e');
  }

  // 🚀 3. Lancer l'application (UNE SEULE FOIS)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 🚀 Assurez-vous que tous vos providers sont listés ici
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserSessionProvider()),
        ChangeNotifierProvider(create: (_) => ProjectProvider()),
        ChangeNotifierProvider(create: (_) => ApplicationProvider()),
      ],
      // 🚀 4. CORRECTION : Utiliser MaterialApp.router directement
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: appTheme,

        // routerConfig gère TOUTES les routes (home, routes, onGenerateRoute)
        routerConfig: AppRouter.router,

        // ❌ Erreurs Corrigées : Ne PAS fournir home, routes, ou onGenerateRoute ici
      ),
    );
  }
}