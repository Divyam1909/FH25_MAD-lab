import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/whisper_model.dart';

class WhisperService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _whispersCollection =>
      _firestore.collection('whispers');

  // Sign in anonymously if not already signed in
  Future<void> ensureAnonymousAuth() async {
    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }
  }

  // Create a new whisper post
  Future<void> createWhisper(String text) async {
    await ensureAnonymousAuth();
    final whisper = WhisperPost(
      id: '',
      text: text,
      createdAt: DateTime.now(),
      resolved: false,
    );
    await _whispersCollection.add(whisper.toFirestore());
  }

  // Get all whispers (stream)
  Stream<List<WhisperPost>> getWhispers() {
    return _whispersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WhisperPost.fromFirestore(doc))
            .toList());
  }

  // Mark whisper as resolved (admin only)
  Future<void> markAsResolved(String whisperId, bool resolved) async {
    await _whispersCollection.doc(whisperId).update({'resolved': resolved});
  }

  // Delete whisper
  Future<void> deleteWhisper(String whisperId) async {
    await _whispersCollection.doc(whisperId).delete();
  }
}
