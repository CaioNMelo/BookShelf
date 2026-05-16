import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/database_service.dart';

// Widget reutilizavel para mostrar uma noticia em formato de card.
class NewsCard extends StatelessWidget {
  final Article article;
  final bool showSaveButton;

  const NewsCard({
    super.key,
    required this.article,
    this.showSaveButton = true,
  });

  // Salva a noticia diretamente pela lista principal.
  Future<void> _saveArticle(BuildContext context) async {
    try {
      await DatabaseService.instance.saveArticle(article);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notícia salva!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível salvar a notícia.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem da noticia.
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(12),
            ),
            child: Image.network(
              article.imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              // Caso a imagem da internet nao carregue, aparece um bloco cinza com icone.
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 160,
                  width: double.infinity,
                  color: Colors.grey.shade300,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 40,
                    color: Colors.grey,
                  ),
                );
              },
            ),
          ),

          // Informacoes da noticia.
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Fonte da noticia.
                    Expanded(
                      child: Text(
                        article.source,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Horario simplificado da noticia.
                    Text(
                      _formatHour(article.publishedAt),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (showSaveButton) ...[
                      const SizedBox(width: 4),
                      IconButton(
                        tooltip: 'Salvar para ler depois',
                        icon: const Icon(Icons.bookmark_add_outlined),
                        onPressed: () => _saveArticle(context),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Formata apenas a hora e os minutos para aparecer no card.
  String _formatHour(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}
