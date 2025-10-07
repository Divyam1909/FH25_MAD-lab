

import 'package:flutter/material.dart';
import 'models/note.dart';
import 'services/storage_service.dart';


void main() => runApp(const MyApp());


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Persistent Notes',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        useMaterial3: true,
      ),
      home: const NotesScreen(),
    );
  }
}


class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});


  @override
  State<NotesScreen> createState() => _NotesScreenState();
}


class _NotesScreenState extends State<NotesScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  List<Note> _notes = [];
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadNotes();
  }


  Future<void> _loadNotes() async {
    setState(() { _isLoading = true; });
    _notes = await StorageService.loadNotes();
    setState(() { _isLoading = false; });
  }


  Future<void> _addNote() async {
    if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
      final newNote = Note(
        title: _titleController.text,
        content: _contentController.text,
      );
      setState(() {
        _notes.add(newNote);
      });
      await StorageService.saveNotes(_notes);
      _titleController.clear();
      _contentController.clear();
      FocusScope.of(context).unfocus(); // Dismiss keyboard
    }
  }


  Future<void> _deleteNote(int index) async {
    setState(() {
      _notes.removeAt(index);
    });
    await StorageService.saveNotes(_notes);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Notes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildInputArea(),
                const Divider(),
                _buildNotesList(),
              ],
            ),
    );
  }


  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(labelText: 'Content', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _addNote,
            icon: const Icon(Icons.add),
            label: const Text('Add Note'),
          ),
        ],
      ),
    );
  }


  Widget _buildNotesList() {
    if (_notes.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text('No notes yet. Add one!'),
        ),
      );
    }
    return Expanded(
      child: ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(note.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(note.content),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _deleteNote(index),
              ),
            ),
          );
        },
      ),
    );
  }
}
