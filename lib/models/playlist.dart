import 'song.dart';

class Playlist {
  final int id;
  String name;
  List<Song> songs;

  Playlist({
    required this.id,
    required this.name,
  }) : songs = [];

  void addSong(Song song) {
    songs.add(song);
  }

  void removeSong(int musicaId) {
    songs.removeWhere((m) => m.id == musicaId);
  }

  @override
  String toString() => 'Playlist(id: $id, name: $name, songs: $songs)';
}
