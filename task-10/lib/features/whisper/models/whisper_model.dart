import 'package:cloud_firestore/cloud_firestore.dart';

class WhisperPost {
  final String id;
  final String text;
  final DateTime createdAt;
  final bool resolved;

  WhisperPost({
    required this.id,
    required this.text,
    required this.createdAt,
    this.resolved = false,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolved': resolved,
    };
  }

  factory WhisperPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WhisperPost(
      id: doc.id,
      text: data['text'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      resolved: data['resolved'] ?? false,
    );
  }

  WhisperPost copyWith({
    String? text,
    DateTime? createdAt,
    bool? resolved,
  }) {
    return WhisperPost(
      id: id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      resolved: resolved ?? this.resolved,
    );
  }
}
