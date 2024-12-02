from concurrent import futures
import grpc
import requests

from music_service_pb2 import (
    UserList,
    User,
    SongList,
    Song,
    PlaylistList,
    Playlist,
)
import music_service_pb2_grpc


class MusicService(music_service_pb2_grpc.MusicServiceServicer):
    REST_API_URL = "http://localhost:8080"  # Endpoint da API REST

    def GetUsers(self, request, context):
        response = requests.get(f"{self.REST_API_URL}/users")
        if response.status_code == 200:
            users = [
                User(id=user["id"], name=user["name"], age=user["age"])
                for user in response.json()
            ]
            return UserList(users=users)
        context.set_code(grpc.StatusCode.INTERNAL)
        context.set_details("Failed to fetch users from REST API")
        return UserList()

    def GetSongs(self, request, context):
        response = requests.get(f"{self.REST_API_URL}/songs")
        if response.status_code == 200:
            songs = [
                Song(id=song["id"], name=song["title"], artist=song["artist"])
                for song in response.json()
            ]
            return SongList(songs=songs)
        context.set_code(grpc.StatusCode.INTERNAL)
        context.set_details("Failed to fetch songs from REST API")
        return SongList()

    def GetPlaylistsByUserId(self, request, context):
        user_id = request.id
        response = requests.get(f"{self.REST_API_URL}/users/{user_id}/playlists")
        if response.status_code == 200:
            playlists = [
                Playlist(id=playlist["id"], name=playlist["name"])
                for playlist in response.json()
            ]
            return PlaylistList(playlists=playlists)
        context.set_code(grpc.StatusCode.INTERNAL)
        context.set_details("Failed to fetch playlists from REST API")
        return PlaylistList()

    def GetSongsFromPlaylist(self, request, context):
        playlist_id = request.id
        response = requests.get(f"{self.REST_API_URL}/playlists/{playlist_id}")
        if response.status_code == 200:
            songs = [
                Song(id=song["id"], name=song["title"], artist=song["artist"])
                for song in response.json()
            ]
            return SongList(songs=songs)
        context.set_code(grpc.StatusCode.INTERNAL)
        context.set_details("Failed to fetch songs from playlist")
        return SongList()

    def GetPlaylistsContainingSong(self, request, context):
        song_id = request.id
        response = requests.get(f"{self.REST_API_URL}/songs/{song_id}/playlists")
        if response.status_code == 200:
            playlists = [
                Playlist(id=playlist["id"], name=playlist["name"])
                for playlist in response.json()
            ]
            return PlaylistList(playlists=playlists)
        context.set_code(grpc.StatusCode.INTERNAL)
        context.set_details("Failed to fetch playlists containing song")
        return PlaylistList()


def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    music_service_pb2_grpc.add_MusicServiceServicer_to_server(MusicService(), server)
    server.add_insecure_port("[::]:50051")
    print("gRPC server is running on port 50051")
    server.start()
    server.wait_for_termination()


if __name__ == "__main__":
    serve()
