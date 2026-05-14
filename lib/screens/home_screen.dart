import 'package:flutter/material.dart';

import '../models/article.dart';
import '../widgets/news_card.dart';

// Tela principal do aplicativo.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controla se o usuario esta vendo noticias do Brasil ou internacionais.
  bool isInternational = false;

  // Guarda a categoria escolhida nos radio buttons.
  String selectedCategory = 'Geral';

  // Lista de categorias exibidas na tela.
  final List<String> categories = const [
    'Geral',
    'Tecnologia',
    'Esportes',
    'Ciencia',
    'Saude',
    'Entretenimento',
  ];

  // Lista de noticias falsas para visualizar o layout.
  final List<Article> articles = [
    Article(
      title: 'Nova biblioteca publica incentiva leitura entre estudantes',
      description: 'Projeto cria espacos de leitura em escolas publicas.',
      url: 'https://example.com/noticia-1',
      imageUrl: 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f',
      source: 'Jornal Campus',
      publishedAt: DateTime(2026, 5, 14, 9, 30),
    ),
    Article(
      title: 'Tecnologia ajuda pesquisadores a organizar acervos digitais',
      description: 'Ferramentas digitais facilitam buscas em grandes colecoes.',
      url: 'https://example.com/noticia-2',
      imageUrl: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3',
      source: 'Tech Hoje',
      publishedAt: DateTime(2026, 5, 14, 11, 15),
    ),
    Article(
      title: 'Feira cultural reune musica, ciencia e exposicoes',
      description: 'Evento gratuito acontece durante todo o fim de semana.',
      url: 'https://example.com/noticia-3',
      imageUrl: 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee',
      source: 'Cultura News',
      publishedAt: DateTime(2026, 5, 14, 14, 45),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Icone de livro ao lado do nome do app.
        title: const Row(
          children: [
            Icon(Icons.menu_book),
            SizedBox(width: 8),
            Text('BookShelf'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Campo de busca por texto.
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar noticias',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Switch para alternar entre noticias do Brasil e internacionais.
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Brasil',
                style: TextStyle(fontSize: 16),
              ),
              Switch(
                value: isInternational,
                onChanged: (value) {
                  setState(() {
                    isInternational = value;
                  });
                },
              ),
              const Text(
                'Internacional',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Titulo da area de categorias.
          const Text(
            'Categoria',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Radio buttons para escolher a categoria da noticia.
          Column(
            children: categories.map((category) {
              return Row(
                children: [
                  Radio<String>(
                    value: category,
                    groupValue: selectedCategory,
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                  Text(category),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Titulo da lista de noticias.
          const Text(
            'Noticias recentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Lista de cards com noticias falsas.
          ...articles.map((article) {
            return NewsCard(article: article);
          }),
        ],
      ),
    );
  }
}
