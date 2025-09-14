import 'dart:convert';
import '../data/models/note.dart';

class JsonCodec {
  static String encodeNotes(List<Note> notes) {
    return jsonEncode(notes.map((note) => note.toJson()).toList());
  }

  static List<Note> decodeNotes(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Note.fromJson(json)).toList();
  }
}
