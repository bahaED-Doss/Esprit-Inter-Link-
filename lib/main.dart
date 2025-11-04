import 'package:esprit_interlink/features/auth/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database in background without blocking UI
  _initializeDatabaseInBackground();
  
  runApp(const MyApp());
}

Future<void> _initializeDatabaseInBackground() async {
  try {
    // Give the app a moment to start
    await Future.delayed(Duration(seconds: 1));
    
    print('🔍 Starting database initialization...');
    
    String path = join(await getDatabasesPath(), 'app_database.db');
    
    Database db = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            full_name TEXT,
            phone TEXT,
            role TEXT,
            password TEXT,
            created_at TEXT
          )
        ''');
        print('✅ Database tables created successfully');
      },
    );
    
    // Quick verification
    List<Map> tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
    print('📊 Database ready! Tables: ${tables.map((t) => t['name']).toList()}');
    
    await db.close();
    
  } catch (e) {
    print('❌ Database initialization error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}