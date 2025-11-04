import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      // Get the database path
      String path = join(await getDatabasesPath(), 'your_database.db');
      print('📁 Database path: $path');

      // Open the database
      Database db = await openDatabase(
        path,
        version: 1,
        onCreate: _createTables,
        onOpen: (db) {
          print('✅ Database opened successfully');
        },
      );

      // Verify tables were created
      List<Map> tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      print('📊 Tables in database:');
      for (var table in tables) {
        print('   - ${table['name']}');
      }

      return db;
    } catch (e) {
      print('❌ Database initialization failed: $e');
      rethrow;
    }
  }

  Future<void> _createTables(Database db, int version) async {
    print('🔄 Creating tables...');
    
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE,
        full_name TEXT,
        phone TEXT,
        role TEXT,
        password TEXT,
        created_at TEXT
      )
    ''');
    
    print('✅ Users table created successfully');
    
    // Verify the table was created
    List<Map> result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='users'"
    );
    
    if (result.isNotEmpty) {
      print('✅ Users table verified: ${result.first}');
    } else {
      print('❌ Users table not found!');
    }
  }
}