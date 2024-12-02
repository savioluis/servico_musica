from flask import Flask, request, Response
from spyne import Application, rpc, ServiceBase, Integer, Unicode, Iterable, ComplexModel
from spyne.protocol.soap import Soap11
from spyne.server.wsgi import WsgiApplication

import requests

# Configuração do Flask
app = Flask(__name__)

# Definições do modelo SOAP
class Song(ComplexModel):
    id = Integer
    name = Unicode
    artist = Unicode

class Playlist(ComplexModel):
    id = Integer
    name = Unicode

class User(ComplexModel):
    id = Integer
    name = Unicode
    age = Integer

class SOAPService(ServiceBase):

    @rpc(_returns=Iterable(User))
    def get_users(ctx):
        """Retorna todos os usuários do serviço."""
        response = requests.get("http://localhost:8080/users")  # Consome a API REST
        if response.status_code == 200:
            users = response.json()
            for user in users:
                yield User(id=user["id"], name=user["name"], age=user["age"])

    @rpc(_returns=Iterable(Song))
    def get_songs(ctx):
        """Retorna todas as músicas do serviço."""
        response = requests.get("http://localhost:8080/songs")  # Consome a API REST
        if response.status_code == 200:
            songs = response.json()
            for song in songs:
                yield Song(id=song["id"], name=song["title"], artist=song["artist"])

    @rpc(Integer, _returns=Iterable(Playlist))
    def get_playlists_by_user_id(ctx, user_id):
        """Retorna todas as playlists de um usuário."""
        response = requests.get(f"http://localhost:8080/users/{user_id}/playlists")  # Consome a API REST
        if response.status_code == 200:
            playlists = response.json()
            for playlist in playlists:
                yield Playlist(id=playlist["id"], name=playlist["name"])

    @rpc(Integer, _returns=Iterable(Song))
    def get_songs_from_playlist(ctx, playlist_id):
        """Retorna todas as músicas de uma playlist."""
        response = requests.get(f"http://localhost:8080/playlists/{playlist_id}")  # Consome a API REST
        if response.status_code == 200:
            songs = response.json()
            for song in songs:
                yield Song(id=song["id"], name=song["title"], artist=song["artist"])

    @rpc(Integer, _returns=Iterable(Playlist))
    def get_playlists_containing_song(ctx, song_id):
        """Retorna todas as playlists que contêm uma música."""
        response = requests.get(f"http://localhost:8080/songs/{song_id}/playlists")  # Consome a API REST
        if response.status_code == 200:
            playlists = response.json()
            for playlist in playlists:
                yield Playlist(id=playlist["id"], name=playlist["name"])

# Configuração do Spyne
soap_app = Application(
    [SOAPService],
    tns="soap.service.musica",
    in_protocol=Soap11(validator="lxml"),
    out_protocol=Soap11(),
)

# Adaptação WSGI para integração correta com Flask
soap_wsgi_app = WsgiApplication(soap_app)

@app.route("/soap", methods=["POST"])
def soap_endpoint():
    # Chamar o WSGI app diretamente
    return Response(
        soap_wsgi_app(request.environ, start_response=lambda status, headers: None),
        content_type="text/xml; charset=utf-8",
    )

# Inicialização do servidor Flask
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8083)
