import grpc
from music_service_pb2 import Empty, UserId, PlaylistId, SongId
import music_service_pb2_grpc

def run():
    with grpc.insecure_channel("localhost:50051") as channel:
        stub = music_service_pb2_grpc.MusicServiceStub(channel)

        response = stub.GetUsers(Empty())
        print("Users:", response)

        response = stub.GetSongs(Empty())
        print("Songs:", response)

        response = stub.GetPlaylistsByUserId(UserId(id=1))
        print("Playlists for User 1:", response)

        response = stub.GetSongsFromPlaylist(PlaylistId(id=1))
        print("Songs in Playlist 1:", response)

        response = stub.GetPlaylistsContainingSong(SongId(id=1))
        print("Playlists containing Song 1:", response)

if __name__ == "__main__":
    run()
