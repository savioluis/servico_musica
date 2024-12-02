import '../models/user.dart';
import '../models/song.dart';
import '../models/playlist.dart';
import '../database/db.dart';

void criarDadosExemplo(DataBase banco) {
  // Criar usuários
  final usuarios = [
    User(id: 1, name: 'Savio', age: 21),
    User(id: 2, name: 'Gustavo', age: 48),
    User(id: 3, name: 'Maria', age: 25),
    User(id: 4, name: 'Lucas', age: 30),
    User(id: 5, name: 'Ana', age: 35),
  ];

  for (var usuario in usuarios) {
    banco.addUser(usuario);
  }

  // Criar uma lista maior de músicas (manualmente adicionadas + dinâmicas)
  final musicas = [
    Song(id: 1, name: 'Bohemian Rhapsody', artist: 'Queen'),
    Song(id: 2, name: 'Stairway to Heaven', artist: 'Led Zeppelin'),
    Song(id: 3, name: 'Hotel California', artist: 'Eagles'),
    Song(id: 4, name: 'Imagine', artist: 'John Lennon'),
    Song(id: 5, name: 'Smells Like Teen Spirit', artist: 'Nirvana'),
    Song(id: 6, name: 'Hey Jude', artist: 'The Beatles'),
    Song(id: 7, name: 'Like a Rolling Stone', artist: 'Bob Dylan'),
    Song(id: 8, name: 'Billie Jean', artist: 'Michael Jackson'),
    Song(id: 9, name: 'Sweet Child O’ Mine', artist: 'Guns N’ Roses'),
    Song(id: 10, name: 'Comfortably Numb', artist: 'Pink Floyd'),
    Song(id: 11, name: 'Purple Haze', artist: 'Jimi Hendrix'),
    Song(id: 12, name: 'Rolling in the Deep', artist: 'Adele'),
    Song(id: 13, name: 'Shape of You', artist: 'Ed Sheeran'),
    Song(id: 14, name: 'Old Town Road', artist: 'Lil Nas X'),
    Song(id: 15, name: 'Blinding Lights', artist: 'The Weeknd'),
    Song(id: 16, name: 'Despacito', artist: 'Luis Fonsi ft. Daddy Yankee'),
    Song(id: 17, name: 'Someone Like You', artist: 'Adele'),
    Song(id: 18, name: 'Take Me to Church', artist: 'Hozier'),
    Song(id: 19, name: 'Sunflower', artist: 'Post Malone'),
    Song(id: 20, name: 'Perfect', artist: 'Ed Sheeran'),
    // Adicionar mais músicas dinamicamente até 200
  ];

  for (int i = 21; i <= 200; i++) {
    musicas.add(Song(id: i, name: 'Music $i', artist: 'Artist ${(i % 50) + 1}'));
  }

  // Adicionar músicas no banco
  for (var musica in musicas) {
    banco.addSong(musica);
  }

  // Criar playlists temáticas
  final playlists = [
    Playlist(id: 1, name: 'Clássicos do Rock'),
    Playlist(id: 2, name: 'Pop Hits'),
    Playlist(id: 3, name: 'Relaxamento'),
    Playlist(id: 4, name: 'Trilha Sonora de Filmes'),
    Playlist(id: 5, name: 'Motivação e Treino'),
    Playlist(id: 6, name: 'Acústico e Chill'),
    Playlist(id: 7, name: 'Favoritas dos Anos 80'),
    Playlist(id: 8, name: 'Top 40 Hits'),
    Playlist(id: 9, name: 'Indie e Alternativo'),
    Playlist(id: 10, name: 'Músicas Internacionais Recentes'),
  ];

  // Associar manualmente algumas músicas a playlists
  playlists[0].addSong(musicas[0]); // Bohemian Rhapsody
  playlists[0].addSong(musicas[1]); // Stairway to Heaven
  playlists[0].addSong(musicas[2]); // Hotel California

  playlists[1].addSong(musicas[8]); // Sweet Child O’ Mine
  playlists[1].addSong(musicas[20]); // Perfect
  playlists[1].addSong(musicas[15]); // Blinding Lights

  playlists[2].addSong(musicas[3]); // Imagine
  playlists[2].addSong(musicas[17]); // Someone Like You
  playlists[2].addSong(musicas[23]); // Take Me to Church

  playlists[3].addSong(musicas[10]); // Comfortably Numb
  playlists[3].addSong(musicas[12]); // Rolling in the Deep
  playlists[3].addSong(musicas[9]); // Purple Haze

  playlists[4].addSong(musicas[19]); // Sunflower
  playlists[4].addSong(musicas[14]); // Old Town Road
  playlists[4].addSong(musicas[24]); // Thinking Out Loud

  playlists[5].addSong(musicas[22]); // All of Me
  playlists[5].addSong(musicas[7]); // Billie Jean
  playlists[5].addSong(musicas[6]); // Like a Rolling Stone

  playlists[6].addSong(musicas[1]); // Stairway to Heaven
  playlists[6].addSong(musicas[16]); // Despacito
  playlists[6].addSong(musicas[13]); // Shape of You

  playlists[7].addSong(musicas[21]); // Halo
  playlists[7].addSong(musicas[4]); // Smells Like Teen Spirit
  playlists[7].addSong(musicas[5]); // Hey Jude

  playlists[8].addSong(musicas[11]); // Purple Haze
  playlists[8].addSong(musicas[0]); // Bohemian Rhapsody
  playlists[8].addSong(musicas[18]); // Take Me to Church

  playlists[9].addSong(musicas[25]); // Music 26
  playlists[9].addSong(musicas[100]); // Music 101
  playlists[9].addSong(musicas[199]); // Music 200

  // Garantir que todas as músicas estejam em pelo menos uma playlist
  for (int i = 0; i < musicas.length; i++) {
    final playlist = playlists[i % playlists.length];
    if (!playlist.songs.contains(musicas[i])) { // Evita duplicação
      playlist.addSong(musicas[i]);
    }
  }

  // Associar playlists aos usuários
  for (int i = 0; i < playlists.length; i++) {
    final usuario = usuarios[i % usuarios.length];
    usuario.addPlaylist(playlists[i]);
  }

}
