import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/database/database_helper.dart';
import '../models/note_model.dart';
import '../widgets/note_card.dart';
import 'note_edit_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

enum NoteSortOption { dateNewest, dateOldest, titleAZ, titleZA, subject }

class _NotesListScreenState extends State<NotesListScreen> {
  List<Note> _notes = [];
  List<Note> _filteredNotes = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _filterSubject;
  NoteSortOption _sortOption = NoteSortOption.dateNewest;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final notes = await DatabaseHelper.instance.readAllNotes();
    setState(() {
      _notes = notes;
      _filterNotes();
      _isLoading = false;
    });
  }

  void _filterNotes() {
    _filteredNotes = _notes.where((note) {
      final matchesSearch = _searchQuery.isEmpty ||
          note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.body.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.subject.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesSubject = _filterSubject == null || note.subject == _filterSubject;

      return matchesSearch && matchesSubject;
    }).toList();

    // Apply sorting
    switch (_sortOption) {
      case NoteSortOption.dateNewest:
        _filteredNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case NoteSortOption.dateOldest:
        _filteredNotes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case NoteSortOption.titleAZ:
        _filteredNotes.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case NoteSortOption.titleZA:
        _filteredNotes.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
      case NoteSortOption.subject:
        _filteredNotes.sort((a, b) => a.subject.toLowerCase().compareTo(b.subject.toLowerCase()));
        break;
    }
  }

  List<String> _getUniqueSubjects() {
    return _notes.map((note) => note.subject).toSet().toList()..sort();
  }

  void _navigateToEditScreen([Note? note]) async {
    final result = await Navigator.push<Note>(
      context,
      MaterialPageRoute(builder: (context) => NoteEditScreen(initialNote: note)),
    );

    if (result != null) {
      if (note != null) {
        await DatabaseHelper.instance.updateNote(result);
      } else {
        await DatabaseHelper.instance.createNote(result);
      }
      _loadNotes(); // Refresh the list
    }
  }

  void _deleteNote(String id) async {
    await DatabaseHelper.instance.deleteNote(id);
    _loadNotes(); // Refresh the list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note deleted')),
    );
  }

  void _shareNote(Note note) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.share, color: Colors.blue),
            SizedBox(width: 12),
            Text('Share Note'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose how to share this note:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(Icons.bluetooth, color: Colors.white),
              ),
              title: const Text('Bluetooth'),
              subtitle: const Text('Share offline via Bluetooth'),
              onTap: () => Navigator.pop(context, 'bluetooth'),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.qr_code, color: Colors.white),
              ),
              title: const Text('QR Code'),
              subtitle: const Text('Generate scannable QR code'),
              onTap: () => Navigator.pop(context, 'qr'),
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.text_fields, color: Colors.white),
              ),
              title: const Text('As Text'),
              subtitle: const Text('Share via messaging apps'),
              onTap: () => Navigator.pop(context, 'text'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (choice == null) return;

    if (choice == 'bluetooth') {
      _shareViaBluetooth(note);
    } else if (choice == 'text') {
      _shareAsText(note);
    } else if (choice == 'qr') {
      _showQRCode(note);
    }
  }

  Future<void> _shareViaBluetooth(Note note) async {
    try {
      // Show sharing dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Expanded(child: Text('Preparing to share...')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Converting note to shareable format'),
              const SizedBox(height: 16),
              LinearProgressIndicator(),
            ],
          ),
        ),
      );

      // If note has attachments, share them along with the note
      if (note.attachments.isNotEmpty) {
        final files = <XFile>[];
        
        // Add each attachment file
        for (final attachment in note.attachments) {
          final file = File(attachment.filePath);
          if (file.existsSync()) {
            files.add(XFile(file.path));
          }
        }
        
        // Close loading dialog
        if (mounted) Navigator.pop(context);
        
        // Share files with note text
        final noteText = '''
${note.title}
Subject: ${note.subject}
Tags: ${note.tags.join(', ')}

${note.body}

Attachments: ${note.attachments.length} file(s)
''';
        
        await Share.shareXFiles(
          files,
          subject: note.title,
          text: noteText,
        );
      } else {
        // No attachments, just share the note as JSON
        final jsonString = jsonEncode(note.toJson());
        
        // Close loading dialog
        if (mounted) Navigator.pop(context);
        
        await Share.share(
          jsonString,
          subject: '${note.title} (StudyHub Note)',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    note.attachments.isEmpty
                        ? 'Note prepared for sharing!\nSelect Bluetooth from share menu'
                        : 'Note with ${note.attachments.length} attachment(s) ready to share!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog if still open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sharing note: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareAsText(Note note) async {
    final text = '''
${note.title}
Subject: ${note.subject}
Tags: ${note.tags.join(', ')}

${note.body}
''';
    
    await Share.share(text, subject: note.title);
  }

  void _showQRCode(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _QRCodeScreen(note: note),
      ),
    );
  }

  Future<void> _importNote() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Note'),
        content: const Text('Choose import method:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'file'),
            child: const Text('From File'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'qr'),
            child: const Text('Scan QR Code'),
          ),
        ],
      ),
    );

    if (choice == 'file') {
      await _importFromFile();
    } else if (choice == 'qr') {
      await _importFromQR();
    }
  }

  Future<void> _importFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null && result.files.single.path != null) {
      try {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        final jsonData = jsonDecode(jsonString);
        final note = Note.fromJson(jsonData);

        await DatabaseHelper.instance.createNote(note);
        _loadNotes();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Note imported successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error importing note: $e')),
          );
        }
      }
    }
  }

  Future<void> _importFromQR() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _QRScannerScreen(
          onScanned: (data) async {
            try {
              final jsonData = jsonDecode(data);
              final note = Note.fromJson(jsonData);
              await DatabaseHelper.instance.createNote(note);
              _loadNotes();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note imported from QR code')),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjects = _getUniqueSubjects();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peer Notes'),
        actions: [
          PopupMenuButton<NoteSortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (option) {
              setState(() {
                _sortOption = option;
                _filterNotes();
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: NoteSortOption.dateNewest,
                child: Text('Date (Newest First)'),
              ),
              const PopupMenuItem(
                value: NoteSortOption.dateOldest,
                child: Text('Date (Oldest First)'),
              ),
              const PopupMenuItem(
                value: NoteSortOption.titleAZ,
                child: Text('Title (A-Z)'),
              ),
              const PopupMenuItem(
                value: NoteSortOption.titleZA,
                child: Text('Title (Z-A)'),
              ),
              const PopupMenuItem(
                value: NoteSortOption.subject,
                child: Text('Subject'),
              ),
            ],
          ),
          if (subjects.isNotEmpty)
            PopupMenuButton<String>(
              icon: Icon(_filterSubject != null ? Icons.filter_alt : Icons.filter_alt_outlined),
              tooltip: 'Filter by Subject',
              onSelected: (subject) {
                setState(() {
                  _filterSubject = _filterSubject == subject ? null : subject;
                  _filterNotes();
                });
              },
              itemBuilder: (context) => [
                if (_filterSubject != null)
                  const PopupMenuItem(
                    value: '',
                    child: Row(
                      children: [
                        Icon(Icons.clear),
                        SizedBox(width: 8),
                        Text('Clear Filter'),
                      ],
                    ),
                  ),
                ...subjects.map((subject) => PopupMenuItem(
                      value: subject,
                      child: Row(
                        children: [
                          if (_filterSubject == subject)
                            const Icon(Icons.check, size: 18)
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Text(subject),
                        ],
                      ),
                    )),
              ],
            ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _importNote,
            tooltip: 'Import Note',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _filterNotes();
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterNotes();
                });
              },
            ),
          ),
          // Filter Chip
          if (_filterSubject != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Chip(
                    label: Text('Subject: $_filterSubject'),
                    onDeleted: () {
                      setState(() {
                        _filterSubject = null;
                        _filterNotes();
                      });
                    },
                    deleteIcon: const Icon(Icons.close, size: 18),
                  ),
                ],
              ),
            ),
          // Notes List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notes.isEmpty
                    ? const Center(child: Text('No notes yet. Add one!'))
                    : _filteredNotes.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.search_off, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                const Text(
                                  'No notes found',
                                  style: TextStyle(fontSize: 18, color: Colors.grey),
                                ),
                                const SizedBox(height: 8),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _searchQuery = '';
                                      _filterSubject = null;
                                      _filterNotes();
                                    });
                                  },
                                  child: const Text('Clear filters'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: _filteredNotes.length,
                            itemBuilder: (context, index) {
                              final note = _filteredNotes[index];
                              return NoteCard(
                                note: note,
                                onTap: () => _navigateToEditScreen(note),
                                onDelete: () => _deleteNote(note.id),
                                onShare: () => _shareNote(note),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToEditScreen(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// QR Code Screen for sharing notes
class _QRCodeScreen extends StatelessWidget {
  final Note note;

  const _QRCodeScreen({required this.note});

  @override
  Widget build(BuildContext context) {
    final jsonString = jsonEncode(note.toJson());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Share via QR Code'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: QrImageView(
                data: jsonString,
                version: QrVersions.auto,
                size: 280,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              note.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Scan this QR code to import the note',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// QR Scanner Screen
class _QRScannerScreen extends StatefulWidget {
  final Function(String) onScanned;

  const _QRScannerScreen({required this.onScanned});

  @override
  State<_QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<_QRScannerScreen> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        backgroundColor: Colors.black,
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (_scanned) return;
          
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              setState(() => _scanned = true);
              widget.onScanned(barcode.rawValue!);
              Navigator.pop(context);
              break;
            }
          }
        },
      ),
    );
  }
}