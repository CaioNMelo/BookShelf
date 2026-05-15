// Modelo que representa uma noticia dentro do aplicativo.
class Article {
  final String title;
  final String description;
  final String url;
  final String imageUrl;
  final String source;
  final DateTime publishedAt;
  final bool isRead;
  final bool isSaved;

  const Article({
    required this.title,
    required this.description,
    required this.url,
    required this.imageUrl,
    required this.source,
    required this.publishedAt,
    this.isRead = false,
    this.isSaved = false,
  });

  // Cria um Article a partir do JSON recebido da GNews API.
  factory Article.fromJson(Map<String, dynamic> json) {
    // A GNews envia os dados da fonte dentro de um objeto chamado "source".
    final sourceJson = json['source'] as Map<String, dynamic>?;

    return Article(
      title: json['title'] as String? ?? 'Sem titulo',
      description: json['description'] as String? ?? 'Sem descricao',
      url: json['url'] as String? ?? '',
      imageUrl: json['image'] as String? ?? '',
      source: sourceJson?['name'] as String? ?? 'Fonte desconhecida',
      publishedAt: DateTime.tryParse(json['publishedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
