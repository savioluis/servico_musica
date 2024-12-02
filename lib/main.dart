import 'package:servico_musica/apis/graphql/graphql.dart';

import '../apis/rest/rest.dart';

import 'database/db.dart';
import 'utils/exemplo_criacao_dados.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final database = DataBase();

  // Criar dados de exemplo
  criarDadosExemplo(database);

  // Iniciar servidor REST
  final restApi = RestAPI(database);
  restApi.startServer();

  // Iniciar servidor GraphQL
  final graphqlApi = GraphQLAPI(database);
  graphqlApi.startServer();

  // Esperar servidores iniciarem
  await Future.delayed(const Duration(seconds: 5));

  // Recolher métricas
  final metrics = await collectMetrics(100); // 100 requisições para teste
  printMetrics(metrics);
}

Future<Map<String, double>> collectMetrics(int nRequests) async {
  final metrics = <String, double>{};

  // Testar REST API
  metrics['REST'] = await testApi(
    nRequests,
    () async => await http.get(Uri.parse('http://localhost:8080/songs')),
  );

  // Testar GraphQL API
  metrics['GraphQL'] = await testApi(
    nRequests,
    () async => await http.post(
      Uri.parse('http://localhost:8081'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': 'query { query { songs { id name artist } } }'}),
    ),
  );

  return metrics;
}

Future<double> testApi(
    int nRequests, Future<http.Response> Function() requestFn) async {
  final stopwatch = Stopwatch()..start();
  for (var i = 0; i < nRequests; i++) {
    final response = await requestFn();
    if (response.statusCode != 200) {
      print('API request failed: ${response.statusCode}');
    }
  }
  stopwatch.stop();
  return stopwatch.elapsedMilliseconds / 1000; // Tempo total em segundos
}

void printMetrics(Map<String, double> metrics) {
  print('API Performance Metrics:');
  metrics.forEach((api, time) {
    print(
        '$api: Total Time = ${time}s, Average Time per Request = ${(time / 100).toStringAsFixed(4)}s');
  });
}
