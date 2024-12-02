class Song {
  final int id;
  String name;
  String artist;

  Song({
    required this.id,
    required this.name,
    required this.artist,
  });

  @override
  String toString() => 'Song(id: $id, name: $name, artist: $artist)';
}
