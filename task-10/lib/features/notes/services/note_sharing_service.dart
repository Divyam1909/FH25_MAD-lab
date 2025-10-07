import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import '../models/note_model.dart';

/// Service for sharing notes via Firebase Cloud
class NoteFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Upload a note to Firebase for sharing
  Future<void> uploadNoteToCloud(Note note) async {
    try {
      // Anonymous sign-in if not authenticated
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }

      // Upload note to Firestore
      await _firestore.collection('shared_notes').doc(note.id).set({
        ...note.toJson(),
        'uploadedBy': _auth.currentUser?.uid ?? 'anonymous',
        'uploadedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to upload note to cloud: $e');
    }
  }

  /// Download a note from Firebase
  Future<Note> downloadNoteFromCloud(String noteId) async {
    try {
      final doc = await _firestore.collection('shared_notes').doc(noteId).get();
      
      if (!doc.exists) {
        throw Exception('Note not found in cloud');
      }

      return Note.fromJson(doc.data()!);
    } catch (e) {
      throw Exception('Failed to download note from cloud: $e');
    }
  }

  /// Get all shared notes from Firebase
  Future<List<Note>> getAllSharedNotes() async {
    try {
      final snapshot = await _firestore
          .collection('shared_notes')
          .orderBy('uploadedAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => Note.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch shared notes: $e');
    }
  }

  /// Delete a note from cloud
  Future<void> deleteNoteFromCloud(String noteId) async {
    try {
      await _firestore.collection('shared_notes').doc(noteId).delete();
    } catch (e) {
      throw Exception('Failed to delete note from cloud: $e');
    }
  }
}

/// Service for Bluetooth sharing of notes
class NoteBluetoothService {
  /// Share note via Bluetooth by creating a local file
  Future<File> prepareNoteForBluetoothShare(Note note) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${note.title.replaceAll(' ', '_')}.json');
      
      // Write note as JSON to file
      await file.writeAsString(
        note.toJson().toString(),
      );
      
      return file;
    } catch (e) {
      throw Exception('Failed to prepare note for Bluetooth sharing: $e');
    }
  }

  /// Import note from Bluetooth-received file
  Future<Note> importNoteFromFile(File file) async {
    try {
      final content = await file.readAsString();
      // Parse and return note
      return Note.fromJson(content as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to import note from file: $e');
    }
  }
}

/// Utility class for file operations
class FileHelper {
  /// Get file extension from path
  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }

  /// Get file type from extension
  static String getFileType(String extension) {
    switch (extension) {
      case 'pdf':
        return 'PDF Document';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return 'Image';
      case 'doc':
      case 'docx':
        return 'Word Document';
      case 'txt':
        return 'Text File';
      default:
        return 'Document';
    }
  }

  /// Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

