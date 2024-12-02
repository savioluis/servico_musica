import 'package:servico_musica/database/db.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'dart:convert';

class RestAPI {
  final DataBase database;

  RestAPI(this.database);

  void startServer() async {
    final handler =
        Pipeline().addMiddleware(logRequests()).addHandler(_routeRequests);

    final server = await io.serve(handler, 'localhost', 8080);
    print('REST API running at http://${server.address.host}:${server.port}');
  }

  Response _routeRequests(Request request) {
    final path = request.url.path;
    final method = request.method;

    if (method == 'GET' && path == 'users') {
      return _getAllUsers();
    } else if (method == 'GET' && path == 'songs') {
      return _getAllSongs();
    } else if (method == 'GET' &&
        path.startsWith('users/') &&
        path.endsWith('playlists')) {
      final userId = int.tryParse(path.split('/')[1]);
      if (userId != null) {
        return _getUserPlaylists(userId);
      }
    } else if (method == 'GET' && path.startsWith('playlists/')) {
      final playlistId = int.tryParse(path.split('/')[1]);
      if (playlistId != null) {
        return _getSongsFromPlaylist(playlistId);
      }
    } else if (method == 'GET' && path.startsWith('songs/')) {
      final songId = int.tryParse(path.split('/')[1]);
      if (songId != null) {
        return _getPlaylistsContainingSong(songId);
      }
    }

    return Response.notFound('Route not found.');
  }

  Response _getAllUsers() {
    final users = database.getAllUsers();
    return Response.ok(jsonEncode(users
        .map((u) => {
              'id': u.id,
              'name': u.name,
              'age': u.age,
            })
        .toList()));
  }

  Response _getAllSongs() {
    final songs = database.getAllSongs();
    return Response.ok(jsonEncode(songs
        .map((s) => {
              'id': s.id,
              'title': s.name,
              'artist': s.artist,
            })
        .toList()));
  }

  Response _getUserPlaylists(int userId) {
    final playlists = database.getUserPlaylists(userId);
    if (playlists.isEmpty) {
      return Response.notFound('User not found or no playlists available.');
    }
    return Response.ok(jsonEncode(playlists
        .map((p) => {
              'id': p.id,
              'name': p.name,
            })
        .toList()));
  }

  // Método atualizado para buscar músicas de uma playlist
  Response _getSongsFromPlaylist(int playlistId) {
    final songs = database.getSongsFromPlaylist(playlistId);
    if (songs.isEmpty) {
      return Response.notFound('Playlist not found or no songs available.');
    }
    return Response.ok(jsonEncode(songs
        .map((s) => {
              'id': s.id,
              'title': s.name,
              'artist': s.artist,
            })
        .toList()));
  }

  Response _getPlaylistsContainingSong(int songId) {
    final playlists = database.getPlaylistsContainingSong(songId);
    return Response.ok(jsonEncode(playlists
        .map((p) => {
              'id': p.id,
              'name': p.name,
            })
        .toList()));
  }
}
