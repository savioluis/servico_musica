import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import '../../database/db.dart';

class GraphQLAPI {
  final DataBase database;

  GraphQLAPI(this.database);

  void startServer() async {
    final handler = Pipeline()
        .addMiddleware(logRequests())
        .addHandler(_handleGraphQL);

    final server = await io.serve(handler, 'localhost', 8081);
    print('GraphQL API running at http://${server.address.host}:${server.port}');
  }

  Future<Response> _handleGraphQL(Request request) async {
    if (request.method != 'POST') {
      return Response(405, body: 'Only POST requests are allowed');
    }

    try {
      final payload = await request.readAsString();
      final body = jsonDecode(payload);

      if (!body.containsKey('query')) {
        return Response(400, body: 'Query is required in the request body.');
      }

      final query = body['query'];
      final variables = body['variables'] ?? <String, dynamic>{};

      final result = _executeQuery(query, variables);
      return Response.ok(jsonEncode(result), headers: {'content-type': 'application/json'});
    } catch (e) {
      return Response(500, body: jsonEncode({'error': e.toString()}));
    }
  }

  Map<String, dynamic> _executeQuery(String query, Map<String, dynamic> variables) {
    final normalizedQuery = query.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (normalizedQuery.startsWith('query { users')) {
      return _resolveUsers();
    } else if (normalizedQuery.startsWith('query { songs')) {
      return _resolveSongs();
    } else if (normalizedQuery.contains('playlists(userId:')) {
      final userId = _extractArgument(normalizedQuery, 'userId');
      return _resolvePlaylists(userId);
    } else if (normalizedQuery.contains('songsFromPlaylist(playlistId:')) {
      final playlistId = _extractArgument(normalizedQuery, 'playlistId');
      return _resolveSongsFromPlaylist(playlistId);
    } else if (normalizedQuery.contains('playlistsContainingSong(songId:')) {
      final songId = _extractArgument(normalizedQuery, 'songId');
      return _resolvePlaylistsContainingSong(songId);
    }

    return {
      'errors': [
        {'message': 'Invalid query'}
      ]
    };
  }

  Map<String, dynamic> _resolveUsers() {
    final users = database.getAllUsers();
    return {
      'data': {
        'users': users
            .map((user) => {
                  'id': user.id,
                  'name': user.name,
                  'age': user.age,
                })
            .toList()
      }
    };
  }

  Map<String, dynamic> _resolveSongs() {
    final songs = database.getAllSongs();
    return {
      'data': {
        'songs': songs
            .map((song) => {
                  'id': song.id,
                  'name': song.name,
                  'artist': song.artist,
                })
            .toList()
      }
    };
  }

  Map<String, dynamic> _resolvePlaylists(int userId) {
    final playlists = database.getUserPlaylists(userId);
    return {
      'data': {
        'playlists': playlists
            .map((playlist) => {
                  'id': playlist.id,
                  'name': playlist.name,
                })
            .toList()
      }
    };
  }

  Map<String, dynamic> _resolveSongsFromPlaylist(int playlistId) {
    final songs = database.getSongsFromPlaylist(playlistId);
    return {
      'data': {
        'songsFromPlaylist': songs
            .map((song) => {
                  'id': song.id,
                  'name': song.name,
                  'artist': song.artist,
                })
            .toList()
      }
    };
  }

  Map<String, dynamic> _resolvePlaylistsContainingSong(int songId) {
    final playlists = database.getPlaylistsContainingSong(songId);
    return {
      'data': {
        'playlistsContainingSong': playlists
            .map((playlist) => {
                  'id': playlist.id,
                  'name': playlist.name,
                })
            .toList()
      }
    };
  }

  int _extractArgument(String query, String argumentName) {
    final regex = RegExp('$argumentName: ([0-9]+)');
    final match = regex.firstMatch(query);
    if (match != null) {
      return int.parse(match.group(1)!);
    }
    throw ArgumentError('Missing argument: $argumentName');
  }
}
