import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  AudioPlayer get player => _player;

  Future<void> playSong(Song song) async {
    await _player.setUrl(song.url);
    _player.play();
  }

  void pause() => _player.pause();
  void stop() => _player.stop();
  void resume() => _player.play();

  void dispose() {
    _player.dispose();
  }
}
