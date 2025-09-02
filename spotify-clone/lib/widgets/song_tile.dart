import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/audio_player_service.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final AudioPlayerService _audioService = AudioPlayerService();

  SongTile({required this.song});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(song.albumArt),
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing: IconButton(
        icon: Icon(Icons.play_arrow),
        onPressed: () {
          _audioService.playSong(song);
        },
      ),
    );
  }
}
