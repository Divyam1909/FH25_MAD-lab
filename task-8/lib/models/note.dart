

// Data model for a single note.
class Note {
  final String title;
  final String content;


  Note({required this.title, required this.content});


  // Converts a Note instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
    };
  }


  // Creates a Note instance from a JSON map.
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}
