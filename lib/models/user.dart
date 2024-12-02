import 'playlist.dart';

class User {
  final int id;
  String name;
  int age;
  List<Playlist> playlists;

  User({
    required this.id,
    required this.name,
    required this.age,
  }) : playlists = [];

  void addPlaylist(Playlist playlist) {
    playlists.add(playlist);
  }

  void removePlaylist(int playlistId) {
    playlists.removeWhere((p) => p.id == playlistId);
  }
}
