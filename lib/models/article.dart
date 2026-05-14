// Modelo que representa uma noticia dentro do aplicativo.
// Por enquanto ele sera usado com dados falsos, mas depois pode receber dados de uma API.
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
}
