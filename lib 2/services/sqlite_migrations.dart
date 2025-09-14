import 'package:sqflite/sqflite.dart';

class SqliteMigrations {
  static Future<void> onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY,
        title TEXT,
        content TEXT,
        created_at INTEGER,
        tags_json TEXT
      )
    ''');
    
    await db.execute('''
      CREATE INDEX idx_notes_created_at ON notes(created_at)
    ''');
  }

  static Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE notes ADD COLUMN tags_json TEXT');
      await db.execute('CREATE INDEX idx_notes_created_at ON notes(created_at)');
    }
  }
}
