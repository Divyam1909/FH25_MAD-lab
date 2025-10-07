import 'dart:convert';
import 'package:uuid/uuid.dart';

class Note {
  final String id;
  final String title;
  final String body;
  final String subject;
  final List<String> tags;
  final DateTime createdAt;
  final bool shared;
  final List<NoteAttachment> attachments;
  final String? createdBy;

  Note({
    String? id,
    required this.title,
    required this.body,
    required this.subject,
    List<String>? tags,
    DateTime? createdAt,
    this.shared = false,
    List<NoteAttachment>? attachments,
    this.createdBy,
  })  : id = id ?? const Uuid().v4(),
        tags = tags ?? [],
        attachments = attachments ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'subject': subject,
      'tags': jsonEncode(tags),
      'createdAt': createdAt.toIso8601String(),
      'shared': shared ? 1 : 0,
      'attachments': jsonEncode(attachments.map((a) => a.toMap()).toList()),
      'createdBy': createdBy ?? '',
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      title: map['title'],
      body: map['body'],
      subject: map['subject'],
      tags: map['tags'] != null 
          ? List<String>.from(jsonDecode(map['tags']))
          : [],
      createdAt: DateTime.parse(map['createdAt']),
      shared: map['shared'] == 1,
      attachments: map['attachments'] != null
          ? (jsonDecode(map['attachments']) as List)
              .map((a) => NoteAttachment.fromMap(a))
              .toList()
          : [],
      createdBy: map['createdBy'] as String?,
    );
  }

  // For JSON export/import
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'subject': subject,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'shared': shared,
      'attachments': attachments.map((a) => a.toJson()).toList(),
      'createdBy': createdBy,
    };
  }

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      subject: json['subject'],
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      shared: json['shared'] ?? false,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((a) => NoteAttachment.fromJson(a))
              .toList()
          : [],
      createdBy: json['createdBy'] as String?,
    );
  }

  Note copyWith({
    String? title,
    String? body,
    String? subject,
    List<String>? tags,
    bool? shared,
    List<NoteAttachment>? attachments,
    String? createdBy,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      subject: subject ?? this.subject,
      tags: tags ?? this.tags,
      createdAt: createdAt,
      shared: shared ?? this.shared,
      attachments: attachments ?? this.attachments,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

class NoteAttachment {
  final String id;
  final String fileName;
  final String filePath; // Local file path
  final String? cloudUrl; // Firebase Storage URL
  final String fileType; // pdf, image, doc, etc.
  final int fileSize; // in bytes
  final DateTime uploadedAt;

  NoteAttachment({
    String? id,
    required this.fileName,
    required this.filePath,
    this.cloudUrl,
    required this.fileType,
    required this.fileSize,
    DateTime? uploadedAt,
  })  : id = id ?? const Uuid().v4(),
        uploadedAt = uploadedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'cloudUrl': cloudUrl,
      'fileType': fileType,
      'fileSize': fileSize,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }

  factory NoteAttachment.fromMap(Map<String, dynamic> map) {
    return NoteAttachment(
      id: map['id'],
      fileName: map['fileName'],
      filePath: map['filePath'],
      cloudUrl: map['cloudUrl'],
      fileType: map['fileType'],
      fileSize: map['fileSize'],
      uploadedAt: DateTime.parse(map['uploadedAt']),
    );
  }

  Map<String, dynamic> toJson() => toMap();
  factory NoteAttachment.fromJson(Map<String, dynamic> json) =>
      NoteAttachment.fromMap(json);
}