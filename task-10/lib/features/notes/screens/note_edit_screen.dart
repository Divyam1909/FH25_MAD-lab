import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../models/note_model.dart';

class NoteEditScreen extends StatefulWidget {
  final Note? initialNote;
  const NoteEditScreen({super.key, this.initialNote});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _bodyController;
  late TextEditingController _subjectController;
  late TextEditingController _tagsController;
  late List<String> _tags;
  late List<NoteAttachment> _attachments;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialNote?.title);
    _bodyController = TextEditingController(text: widget.initialNote?.body);
    _subjectController = TextEditingController(text: widget.initialNote?.subject);
    _tags = widget.initialNote?.tags ?? [];
    _attachments = List.from(widget.initialNote?.attachments ?? []);
    _tagsController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _subjectController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _addTag() {
    if (_tagsController.text.trim().isNotEmpty) {
      setState(() {
        _tags.add(_tagsController.text.trim());
        _tagsController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        for (final file in result.files) {
          if (file.path != null) {
            final sourceFile = File(file.path!);

            // Copy to app's documents directory
            final directory = await getApplicationDocumentsDirectory();
            final fileName = file.name;
            final newPath = '${directory.path}/attachments/$fileName';
            final newFile = File(newPath);

            // Create directory if it doesn't exist
            await newFile.parent.create(recursive: true);
            await sourceFile.copy(newPath);

            final extension = fileName.split('.').last.toLowerCase();
            final attachment = NoteAttachment(
              fileName: fileName,
              filePath: newPath,
              fileType: extension,
              fileSize: await sourceFile.length(),
            );

            setState(() {
              _attachments.add(attachment);
            });
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result.files.length} file(s) attached'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking files: $e')),
        );
      }
    }
  }

  void _removeAttachment(NoteAttachment attachment) {
    setState(() {
      _attachments.remove(attachment);
    });
  }

  String _getFileIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return '📄';
      case 'doc':
      case 'docx':
        return '📝';
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return '🖼️';
      case 'mp4':
      case 'mov':
        return '🎥';
      case 'mp3':
      case 'wav':
        return '🎵';
      default:
        return '📎';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _viewAttachment(NoteAttachment attachment) {
    final file = File(attachment.filePath);

    if (!file.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File not found')),
      );
      return;
    }

    final extension = attachment.fileType.toLowerCase();

    // Handle different file types
    if (extension == 'pdf') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _PDFViewerScreen(
            file: file,
            title: attachment.fileName,
          ),
        ),
      );
    } else if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => _ImageViewerScreen(
            file: file,
            title: attachment.fileName,
          ),
        ),
      );
    } else {
      // For other file types, show details and option to open with external app
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(attachment.fileName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Type: ${attachment.fileType.toUpperCase()}'),
              Text('Size: ${_formatFileSize(attachment.fileSize)}'),
              const SizedBox(height: 16),
              const Text(
                'This file type cannot be previewed in the app. You can share it or open it with an external app.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  void _saveNote() {
    if (_formKey.currentState!.validate()) {
      final note = Note(
        id: widget.initialNote?.id,
        title: _titleController.text,
        body: _bodyController.text,
        subject: _subjectController.text,
        tags: _tags,
        attachments: _attachments,
        createdAt: widget.initialNote?.createdAt,
      );
      Navigator.pop(context, note);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialNote == null ? 'New Note' : 'Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              validator: (value) => value!.isEmpty ? 'Title cannot be empty' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(labelText: 'Subject (e.g., DSA)', border: OutlineInputBorder()),
              validator: (value) => value!.isEmpty ? 'Subject cannot be empty' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Note content...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 15,
              validator: (value) => value!.isEmpty ? 'Content cannot be empty' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Add tags',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., important, exam',
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTag,
                  tooltip: 'Add Tag',
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _tags
                    .map((tag) => Chip(
                  label: Text(tag),
                  onDeleted: () => _removeTag(tag),
                  deleteIcon: const Icon(Icons.close, size: 18),
                ))
                    .toList(),
              ),
            ],
            const SizedBox(height: 24),

            // Attachments Section
            Row(
              children: [
                const Text(
                  'Attachments',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _pickDocument,
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Add Files'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_attachments.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.file_upload_outlined, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'No attachments yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            else
              ..._attachments.map((attachment) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Text(
                    _getFileIcon(attachment.fileType),
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Text(
                    attachment.fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${attachment.fileType.toUpperCase()} • ${_formatFileSize(attachment.fileSize)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => _viewAttachment(attachment),
                        tooltip: 'View',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _removeAttachment(attachment),
                        color: Colors.red,
                        tooltip: 'Remove',
                      ),
                    ],
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }
}

// PDF Viewer Screen
class _PDFViewerScreen extends StatefulWidget {
  final File file;
  final String title;

  const _PDFViewerScreen({required this.file, required this.title});

  @override
  State<_PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<_PDFViewerScreen> {
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isReady = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: const TextStyle(fontSize: 16)),
            if (_totalPages > 0)
              Text(
                'Page ${_currentPage + 1} of $_totalPages',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.file.path,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            onRender: (pages) {
              setState(() {
                _totalPages = pages ?? 0;
                _isReady = true;
              });
            },
            onPageChanged: (page, total) {
              setState(() {
                _currentPage = page ?? 0;
                _totalPages = total ?? 0;
              });
            },
            onError: (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $error')),
              );
            },
          ),
          if (!_isReady)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}

// Image Viewer Screen
class _ImageViewerScreen extends StatelessWidget {
  final File file;
  final String title;

  const _ImageViewerScreen({required this.file, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(file),
        ),
      ),
    );
  }
}