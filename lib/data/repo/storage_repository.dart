import '../models/note.dart';

abstract class StorageRepository {
  Future<void> save(Note note);
  Future<Note?> load(int id);
  Future<List<Note>> list();
  Future<void> update(Note note);
  Future<void> delete(int id);
  Future<void> clearAll();
  Future<void> seed();
}
