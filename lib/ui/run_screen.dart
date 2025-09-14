import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/storage_kind.dart';
import '../data/models/note.dart';
import '../data/repo/storage_repository.dart';
import '../data/repo/prefs_repository.dart';
import '../data/repo/file_repository.dart';
import '../data/repo/sqlite_repository.dart';
import 'widgets/note_editor.dart';
import 'widgets/progress_overlay.dart';

class RunScreen extends StatefulWidget {
  final StorageKind storageKind;

  RunScreen({required this.storageKind});

  @override
  _RunScreenState createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  late StorageRepository repository;
  List<Note> notes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    repository = _createRepository();
    _loadNotes();
  }

  StorageRepository _createRepository() {
    switch (widget.storageKind) {
      case StorageKind.preferences:
        return PrefsRepository();
      case StorageKind.file:
        return FileRepository();
      case StorageKind.sqlite:
        return SqliteRepository();
    }
  }

  Future<void> _executeWithLoading(Future<void> Function() operation) async {
    setState(() => isLoading = true);
    try {
      await operation();
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadNotes() async {
    await _executeWithLoading(() async {
      notes = await repository.list();
    });
  }

  Future<void> _seed() async {
    await _executeWithLoading(() async {
      await repository.seed();
      await _loadNotes();
    });
  }

  Future<void> _add() async {
    final note = await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditor(),
      ),
    );
    if (note != null) {
      await _executeWithLoading(() async {
        await repository.save(note);
        await _loadNotes();
      });
    }
  }

  Future<void> _editFirst() async {
    if (notes.isEmpty) return;
    final firstNote = notes.first;
    final editedNote = await Navigator.push<Note>(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditor(note: firstNote),
      ),
    );
    if (editedNote != null) {
      await _executeWithLoading(() async {
        await repository.update(editedNote);
        await _loadNotes();
      });
    }
  }

  Future<void> _deleteFirst() async {
    if (notes.isEmpty) return;
    await _executeWithLoading(() async {
      await repository.delete(notes.first.id);
      await _loadNotes();
    });
  }

  Future<void> _clear() async {
    await _executeWithLoading(() async {
      await repository.clearAll();
      await _loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_getStorageTitle()} Demo'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildActionButtons(),
              Expanded(
                child: _buildNotesList(),
              ),
            ],
          ),
          if (isLoading) ProgressOverlay(),
        ],
      ),
    );
  }

  String _getStorageTitle() {
    switch (widget.storageKind) {
      case StorageKind.preferences:
        return 'Preferences';
      case StorageKind.file:
        return 'JSON File';
      case StorageKind.sqlite:
        return 'SQLite';
    }
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Wrap(
        spacing: 8,
        children: [
          ElevatedButton(
            onPressed: _seed,
            child: Text('Seed 10'),
          ),
          ElevatedButton(
            onPressed: _add,
            child: Text('Add'),
          ),
          ElevatedButton(
            onPressed: notes.isNotEmpty ? _editFirst : null,
            child: Text('Edit First'),
          ),
          ElevatedButton(
            onPressed: notes.isNotEmpty ? _deleteFirst : null,
            child: Text('Delete First'),
          ),
          ElevatedButton(
            onPressed: _clear,
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList() {
    if (notes.isEmpty) {
      return Center(
        child: Text(
          'No notes found',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ListTile(
            title: Text(note.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note.content),
                SizedBox(height: 4),
                Text(
                  DateFormat('MMM dd, yyyy - HH:mm').format(note.createdAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (note.tags.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children: note.tags
                        .map((tag) => Chip(
                              label: Text(tag),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ))
                        .toList(),
                  ),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
