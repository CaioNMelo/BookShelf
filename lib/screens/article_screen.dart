import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article.dart';

// Tela de leitura de uma noticia especifica.
// Recebe um objeto Article vindo da HomeScreen.
class ArticleScreen extends StatelessWidget {
  final Article article;

  const ArticleScreen({super.key, required this.article});

  // Formata a data de forma amigavel, ex: "14 de maio de 2026, 09:30".
  String _formatDate(DateTime date) {
    const months = [
      'janeiro',
      'fevereiro',
      'marco',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];

    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day de $month de $year, $hour:$minute';
  }

  // Tenta abrir o link da noticia no navegador do dispositivo.
  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      // LaunchMode.externalApplication abre no navegador, fora do app.
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Se nao conseguiu abrir, avisa o usuario com um SnackBar.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nao foi possivel abrir o link.'),
          ),
        );
      }
    }
  }

  // Bloco cinza que aparece no lugar da imagem quando ela nao esta disponivel.
  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 220,
      color: Colors.grey.shade300,
      child: const Icon(
        Icons.image_not_supported,
        size: 64,
        color: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // O botao de voltar (<) e adicionado automaticamente pelo Flutter
        // porque essa tela foi aberta via Navigator.push.
        title: const Text('Lendo noticia'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      // SingleChildScrollView permite rolar a tela quando o conteudo
      // for maior do que o espaco disponivel.
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem da noticia no topo. Se a URL estiver vazia ou der erro,
            // mostra o placeholder cinza.
            article.imageUrl.isNotEmpty
                ? Image.network(
                    article.imageUrl,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImagePlaceholder();
                    },
                  )
                : _buildImagePlaceholder(),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titulo da noticia em destaque.
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Nome da fonte da noticia.
                  Row(
                    children: [
                      Icon(Icons.source, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          article.source,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Data e hora de publicacao.
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(article.publishedAt),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Divider(),
                  const SizedBox(height: 16),

                  // Descricao / resumo da noticia.
                  // height: 1.6 aumenta o espaco entre linhas para facilitar
                  // a leitura.
                  Text(
                    article.description,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),
                  const SizedBox(height: 32),

                  // Botao principal: abre a materia completa no navegador.
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openLink(context, article.url),
                      icon: const Icon(Icons.open_in_browser),
                      label: const Text('Ler materia completa'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Botao secundario: salvar para ler depois.
                  // Por enquanto so exibe um SnackBar de confirmacao.
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Noticia salva para ler depois!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.bookmark_add_outlined),
                      label: const Text('Salvar para ler depois'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
