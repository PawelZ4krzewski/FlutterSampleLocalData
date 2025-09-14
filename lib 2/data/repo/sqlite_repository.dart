import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/note.dart';
import '../../services/file_paths.dart';
import '../../services/sqlite_migrations.dart';
import 'storage_repository.dart';

class SqliteRepository implements StorageRepository {
  Database? _database;

  Future<Database> get database async {
    _database ??= await _openDatabase();
    return _database!;
  }

  Future<Database> _openDatabase() async {
    final dbPath = await getAppDocumentPath();
    final path = join(dbPath, 'notes.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: SqliteMigrations.onCreate,
      onUpgrade: SqliteMigrations.onUpgrade,
    );
  }

  @override
  Future<void> save(Note note) async {
    final db = await database;
    await db.insert(
      'notes',
      _noteToMap(note),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Note?> load(int id) async {
    final db = await database;
    final maps = await db.query(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return _mapToNote(maps.first);
  }

  @override
  Future<List<Note>> list() async {
    final db = await database;
    final maps = await db.query('notes', orderBy: 'created_at DESC');
    return maps.map(_mapToNote).toList();
  }

  @override
  Future<void> update(Note note) async {
    final db = await database;
    await db.update(
      'notes',
      _noteToMap(note),
      where: 'id = ?',
      whereArgs: [note.id],
    );
  }

  @override
  Future<void> delete(int id) async {
    final db = await database;
    await db.delete(
      'notes',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('notes');
  }

  @override
  Future<void> seed() async {
    final db = await database;
    final now = DateTime.now();
    final notes = List.generate(10, (index) => Note(
      id: index + 1,
      title: 'Note ${index + 1}',
      content: 'Content for note ${index + 1}',
      createdAt: now.subtract(Duration(days: index)),
      tags: ['tag${index % 3 + 1}'],
    ));
    
    await db.transaction((txn) async {
      for (final note in notes) {
        await txn.insert('notes', _noteToMap(note), conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Map<String, dynamic> _noteToMap(Note note) {
    return {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'created_at': note.createdAt.millisecondsSinceEpoch,
      'tags_json': jsonEncode(note.tags),
    };
  }

  Note _mapToNote(Map<String, dynamic> map) {
    final tagsJson = map['tags_json'] as String?;
    final tags = tagsJson != null ? List<String>.from(jsonDecode(tagsJson)) : <String>[];
    
    return Note(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      tags: tags,
    );
  }
}
