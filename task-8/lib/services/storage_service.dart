

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';


class StorageService {
  static const String _notesKey = 'notes_list';


  // Save a list of notes to local storage.
  static Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert List<Note> to List<Map<String, dynamic>>
    List<Map<String, dynamic>> notesJson = notes.map((note) => note.toJson()).toList();
    // Encode the list of maps into a single JSON string.
    String notesString = json.encode(notesJson);
    await prefs.setString(_notesKey, notesString);
  }


  // Load a list of notes from local storage.
  static Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    String? notesString = prefs.getString(_notesKey);


    if (notesString != null) {
      // Decode the JSON string into a List<dynamic>.
      List<dynamic> notesJson = json.decode(notesString);
      // Map the List<dynamic> to a List<Note>.
      return notesJson.map((json) => Note.fromJson(json)).toList();
    }
    // Return an empty list if no data is found.
    return [];
  }
}
