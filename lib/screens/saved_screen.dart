import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/database_service.dart';
import 'article_screen.dart';

// Tela que mostra as noticias salvas localmente no SQLite.
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  // Future usado pelo FutureBuilder para carregar as noticias salvas.
  late Future<List<Article>> _savedArticlesFuture;

  @override
  void initState() {
    super.initState();
    _loadSavedArticles();
  }

  // Busca novamente as noticias salvas no banco.
  void _loadSavedArticles() {
    _savedArticlesFuture = DatabaseService.instance.getSavedArticles();
  }

  // Marca uma noticia como lida e atualiza a lista.
  Future<void> _markAsRead(String url) async {
    await DatabaseService.instance.markAsRead(url);

    if (mounted) {
      setState(_loadSavedArticles);
    }
  }

  // Remove uma noticia salva e atualiza a lista.
  Future<void> _deleteArticle(String url) async {
    await DatabaseService.instance.deleteArticle(url);

    if (mounted) {
      setState(_loadSavedArticles);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notícia removida dos salvos.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Abre a tela de leitura com a noticia escolhida.
  void _openArticle(Article article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArticleScreen(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salvos'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Article>>(
        future: _savedArticlesFuture,
        builder: (context, snapshot) {
          // Mostra um carregamento enquanto o SQLite responde.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Não foi possível carregar as notícias salvas.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final articles = snapshot.data ?? [];

          if (articles.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma notícia salva ainda',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: articles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final article = articles[index];

              return Card(
                child: ListTile(
                  onTap: () => _openArticle(article),
                  leading: Checkbox(
                    value: article.isRead,
                    onChanged: article.isRead
                        ? null
                        : (value) {
                            if (value == true) {
                              _markAsRead(article.url);
                            }
                          },
                  ),
                  title: Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(article.source),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icone visual para diferenciar noticias lidas e nao lidas.
                      Icon(
                        article.isRead
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: article.isRead ? Colors.green : Colors.grey,
                      ),
                      IconButton(
                        tooltip: 'Remover',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteArticle(article.url),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
