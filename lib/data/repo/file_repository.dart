import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../../services/json_codec.dart';
import '../../services/file_paths.dart';
import 'storage_repository.dart';

class FileRepository implements StorageRepository {
  List<Note> _notes = [];

  @override
  Future<void> save(Note note) async {
    await _loadNotes();
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      _notes[index] = note;
    } else {
      _notes.add(note);
    }
    await _saveNotes();
  }

  @override
  Future<Note?> load(int id) async {
    await _loadNotes();
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Note>> list() async {
    await _loadNotes();
    return List.from(_notes);
  }

  @override
  Future<void> update(Note note) async {
    await save(note);
  }

  @override
  Future<void> delete(int id) async {
    await _loadNotes();
    _notes.removeWhere((note) => note.id == id);
    await _saveNotes();
  }

  @override
  Future<void> clearAll() async {
    _notes.clear();
    await _saveNotes();
  }

  @override
  Future<void> seed() async {
    final now = DateTime.now();
    _notes = List.generate(10, (index) => Note(
      id: index + 1,
      title: 'Note ${index + 1}',
      content: 'Content for note ${index + 1}',
      createdAt: now.subtract(Duration(days: index)),
      tags: ['tag${index % 3 + 1}'],
    ));
    await _saveNotes();
  }

  Future<void> _loadNotes() async {
    final file = File(await getNotesFilePath());
    if (!await file.exists()) {
      _notes = [];
      return;
    }
    
    final jsonString = await file.readAsString();
    if (jsonString.isEmpty) {
      _notes = [];
      return;
    }

    if (jsonString.length > 1000) {
      _notes = await compute(JsonCodec.decodeNotes, jsonString);
    } else {
      _notes = JsonCodec.decodeNotes(jsonString);
    }
  }

  Future<void> _saveNotes() async {
    final file = File(await getNotesFilePath());
    final jsonString = JsonCodec.encodeNotes(_notes);
    await file.writeAsString(jsonString);
  }
}
