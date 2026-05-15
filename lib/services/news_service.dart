import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/article.dart';

// Chave da GNews API lida do arquivo .env.
// O operador ?? usa uma string vazia se a chave nao existir.
final String kGNewsApiKey = dotenv.env['GNEWS_API_KEY'] ?? '';

// Classe responsavel por conversar com a GNews API.
class NewsService {
  // URL base informada pela documentacao da GNews.
  static const String _baseUrl = 'https://gnews.io/api/v4';

  // Busca noticias na API usando async/await.
  //
  // Se "query" tiver texto, usamos o endpoint /search.
  // Se "query" estiver vazio, usamos /top-headlines com categoria.
  Future<List<Article>> fetchNews({
    String category = 'general',
    String query = '',
    String country = 'br',
  }) async {
    if (kGNewsApiKey.isEmpty) {
      throw Exception('Chave da GNews API nao encontrada no arquivo .env.');
    }

    final trimmedQuery = query.trim();
    final endpoint = trimmedQuery.isEmpty ? 'top-headlines' : 'search';

    // O app usa nomes em portugues na tela, mas a API espera nomes em ingles.
    final apiCategory = _mapCategoryToApi(category);

    // O app trabalha com "br" para Brasil e "us" para Internacional.
    final apiCountry = country == 'us' ? 'us' : 'br';

    // Monta a URL de forma segura, sem concatenar parametros manualmente.
    final uri = Uri.parse('$_baseUrl/$endpoint').replace(
      queryParameters: {
        'token': kGNewsApiKey,
        'country': apiCountry,
        'lang': apiCountry == 'br' ? 'pt' : 'en',
        'max': '10',
        if (trimmedQuery.isEmpty) 'category': apiCategory,
        if (trimmedQuery.isNotEmpty) 'q': trimmedQuery,
      },
    );

    try {
      final response = await http.get(uri);

      // Codigo 429 significa que o limite de requisicoes da API foi atingido.
      if (response.statusCode == 429) {
        throw Exception('Limite de requisicoes da GNews atingido.');
      }

      // Qualquer resposta fora da faixa 200 indica erro na chamada.
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          'Erro ao buscar noticias. Codigo: ${response.statusCode}.',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final articlesJson = data['articles'] as List<dynamic>? ?? [];

      // A API respondeu corretamente, mas nao encontrou noticias.
      if (articlesJson.isEmpty) {
        throw Exception('Nenhum resultado encontrado.');
      }

      // Converte cada item do JSON em um objeto Article do nosso app.
      return articlesJson
          .map((json) => Article.fromJson(json as Map<String, dynamic>))
          .toList();
    } on http.ClientException {
      // Erros de ClientException costumam acontecer quando nao ha conexao.
      throw Exception('Sem conexao com a internet.');
    } on FormatException {
      // A resposta chegou, mas nao estava em um formato JSON valido.
      throw Exception('Resposta invalida da GNews API.');
    }
  }

  // Traduz as categorias da interface para as categorias aceitas pela GNews.
  String _mapCategoryToApi(String category) {
    switch (category.toLowerCase()) {
      case 'tecnologia':
      case 'technology':
        return 'technology';
      case 'esportes':
      case 'sports':
        return 'sports';
      case 'ciencia':
      case 'science':
        return 'science';
      case 'saude':
      case 'health':
        return 'health';
      case 'entretenimento':
      case 'entertainment':
        return 'entertainment';
      case 'geral':
      case 'general':
      default:
        return 'general';
    }
  }
}
