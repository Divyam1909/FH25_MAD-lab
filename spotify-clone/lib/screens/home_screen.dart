import 'package:flutter/material.dart';
import '../models/song.dart';
import '../widgets/song_tile.dart';

class HomeScreen extends StatelessWidget {
  final List<Song> songs;

  HomeScreen({required this.songs});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Spotify Clone')),
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          return SongTile(song: songs[index]);
        },
      ),
    );
  }
}
