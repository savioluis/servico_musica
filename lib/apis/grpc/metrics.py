import time
import requests
import grpc
from music_service_pb2 import Empty
from music_service_pb2_grpc import MusicServiceStub


def test_soap(n_requests):
    soap_url = "http://localhost:8083/soap"
    soap_body = """
    <soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:mus="soap.service.musica">
       <soapenv:Header/>
       <soapenv:Body>
          <mus:get_users/>
       </soapenv:Body>
    </soapenv:Envelope>
    """
    headers = {"Content-Type": "text/xml"}
    start_time = time.time()
    for _ in range(n_requests):
        response = requests.post(soap_url, data=soap_body, headers=headers)
        if response.status_code != 200:
            print(f"SOAP request failed: {response.status_code}")
    total_time = time.time() - start_time
    return total_time


def test_grpc(n_requests):
    grpc_channel = grpc.insecure_channel("localhost:50051")
    grpc_stub = MusicServiceStub(grpc_channel)
    start_time = time.time()
    for _ in range(n_requests):
        grpc_stub.GetUsers(Empty())
    total_time = time.time() - start_time
    return total_time


def collect_metrics(n_requests):
    print("Collecting metrics...")
    soap_time = test_soap(n_requests)
    grpc_time = test_grpc(n_requests)

    print(f"SOAP API: Total Time = {soap_time:.2f}s, Average Time = {soap_time / n_requests:.4f}s")
    print(f"gRPC API: Total Time = {grpc_time:.2f}s, Average Time = {grpc_time / n_requests:.4f}s")


if __name__ == "__main__":
    n_requests = int(input("Enter the number of requests: "))
    collect_metrics(n_requests)
