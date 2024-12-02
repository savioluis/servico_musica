import 'package:collection/collection.dart';
import 'package:servico_musica/models/playlist.dart';
import '../models/user.dart';
import '../models/song.dart';

class DataBase {
  List<User> users = [];
  List<Song> songs = [];

  User? getUserById(int id) {
    return users.firstWhereOrNull((u) => u.id == id);
  }

  Song? getSongById(int id) {
    return songs.firstWhereOrNull((m) => m.id == id);
  }

  void addUser(User user) {
    users.add(user);
  }

  void addSong(Song song) {
    songs.add(song);
  }

  void removeUser(int id) {
    users.removeWhere((u) => u.id == id);
  }

  void removeSong(int id) {
    songs.removeWhere((m) => m.id == id);
  }

  List<User> getAllUsers() {
    return users;
  }

  List<Song> getAllSongs() {
    return songs;
  }

  List<Playlist> getUserPlaylists(int userId) {
    final usuario = getUserById(userId);
    return usuario?.playlists ?? [];
  }

List<Song> getSongsFromPlaylist(int playlistId) {
  for (var user in users) {
    final playlist = user.playlists.firstWhereOrNull((p) => p.id == playlistId);
    if (playlist != null) {
      return playlist.songs;
    }
  }
  return [];
}


  List<Playlist> getPlaylistsContainingSong(int songId) {
    final playlists = <Playlist>[];
    for (var user in users) {
      for (var playlist in user.playlists) {
        if (playlist.songs.any((m) => m.id == songId)) {
          playlists.add(playlist);
        }
      }
    }
    return playlists;
  }
}
