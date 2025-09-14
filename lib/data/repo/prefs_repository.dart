import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';
import 'storage_repository.dart';

class PrefsRepository implements StorageRepository {
  static const String _keyPrefix = 'note_';
  static const String _keyIds = 'note_ids';

  @override
  Future<void> save(Note note) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix${note.id}';
    await prefs.setString(key, jsonEncode(note.toJson()));
    
    final ids = await _getIds();
    if (!ids.contains(note.id)) {
      ids.add(note.id);
      await _saveIds(ids);
    }
  }

  @override
  Future<Note?> load(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$id';
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;
    return Note.fromJson(jsonDecode(jsonString));
  }

  @override
  Future<List<Note>> list() async {
    final ids = await _getIds();
    final notes = <Note>[];
    for (final id in ids) {
      final note = await load(id);
      if (note != null) {
        notes.add(note);
      }
    }
    return notes;
  }

  @override
  Future<void> update(Note note) async {
    await save(note);
  }

  @override
  Future<void> delete(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$id';
    await prefs.remove(key);
    
    final ids = await _getIds();
    ids.remove(id);
    await _saveIds(ids);
  }

  @override
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await _getIds();
    for (final id in ids) {
      final key = '$_keyPrefix$id';
      await prefs.remove(key);
    }
    await prefs.remove(_keyIds);
  }

  @override
  Future<void> seed() async {
    final now = DateTime.now();
    final notes = List.generate(10, (index) => Note(
      id: index + 1,
      title: 'Note ${index + 1}',
      content: 'Content for note ${index + 1}',
      createdAt: now.subtract(Duration(days: index)),
      tags: ['tag${index % 3 + 1}'],
    ));
    
    for (final note in notes) {
      await save(note);
    }
  }

  Future<List<int>> _getIds() async {
    final prefs = await SharedPreferences.getInstance();
    final idsString = prefs.getString(_keyIds);
    if (idsString == null) return [];
    final List<dynamic> ids = jsonDecode(idsString);
    return ids.cast<int>();
  }

  Future<void> _saveIds(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIds, jsonEncode(ids));
  }
}
