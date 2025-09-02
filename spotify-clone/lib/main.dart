import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'models/song.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final List<Song> demoSongs = [
    Song(
      id: '1',
      title: 'Song One',
      artist: 'Artist One',
      albumArt: 'https://picsum.photos/200',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    ),
    Song(
      id: '2',
      title: 'Song Two',
      artist: 'Artist Two',
      albumArt: 'https://picsum.photos/200',
      url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Clone',
      theme: ThemeData.dark(),
      home: HomeScreen(songs: demoSongs),
    );
  }
}
