import 'package:flutter/material.dart';

import '../models/article.dart';
import '../services/news_service.dart';
import '../services/preferences_service.dart';
import '../widgets/news_card.dart';
import 'article_screen.dart';

// Tela principal do aplicativo.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controla se o usuario esta vendo noticias do Brasil ou internacionais.
  bool isInternational = false;

  // Guarda a categoria escolhida nos chips.
  String selectedCategory = 'Geral';

  // Controla o texto digitado no campo de busca.
  final TextEditingController _searchController = TextEditingController();

  // Instancia do servico que busca noticias na API.
  final NewsService _newsService = NewsService();

  // Instancia do servico que salva preferencias simples do usuario.
  final PreferencesService _preferencesService = PreferencesService();

  // Guarda o Future atual. O FutureBuilder reage toda vez que esse valor muda.
  late Future<List<Article>> _newsFuture;

  // Lista de categorias exibidas na tela.
  final List<String> categories = const [
    'Geral',
    'Tecnologia',
    'Esportes',
    'Ciencia',
    'Saude',
    'Entretenimento',
  ];

  @override
  void initState() {
    super.initState();
    // Carrega categoria e pais salvos antes de buscar as noticias.
    _newsFuture = _loadPreferencesAndNews();
  }

  @override
  void dispose() {
    // Libera a memoria do controller quando a tela e destruida.
    _searchController.dispose();
    super.dispose();
  }

  // Chama a API com os filtros atuais e atualiza o FutureBuilder.
  // Toda vez que essa funcao e chamada, o FutureBuilder reconstroi a tela.
  void _loadNews() {
    setState(() {
      _newsFuture = _newsService.fetchNews(
        category: selectedCategory,
        query: _searchController.text,
        country: isInternational ? 'us' : 'br',
      );
    });
  }

  // Recupera as preferencias salvas em sessoes anteriores.
  Future<List<Article>> _loadPreferencesAndNews() async {
    final savedCategory = await _preferencesService.getCategory();
    final savedCountry = await _preferencesService.getCountry();

    if (!mounted) {
      return [];
    }

    setState(() {
      selectedCategory = savedCategory;
      isInternational = savedCountry == 'us';
    });

    return _newsService.fetchNews(
      category: selectedCategory,
      query: _searchController.text,
      country: savedCountry,
    );
  }

  // Salva o pais escolhido e recarrega as noticias.
  Future<void> _changeCountry(bool value) async {
    if (isInternational == value) {
      return;
    }

    final country = value ? 'us' : 'br';

    await _preferencesService.saveCountry(country);

    if (!mounted) {
      return;
    }

    setState(() {
      isInternational = value;
    });
    _loadNews();
  }

  // Salva a categoria escolhida e recarrega as noticias.
  Future<void> _changeCategory(String category) async {
    if (selectedCategory == category) {
      return;
    }

    await _preferencesService.saveCategory(category);

    if (!mounted) {
      return;
    }

    setState(() {
      selectedCategory = category;
    });
    _loadNews();
  }

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
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          // Area compacta de busca e filtros.
          _buildFilterArea(context),
          const SizedBox(height: 24),

          // Titulo da lista de noticias.
          const Text(
            'Noticias recentes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // FutureBuilder "escuta" o _newsFuture e reconstroi esse trecho da
          // tela automaticamente quando os dados chegam, ha erro ou esta
          // carregando. E a forma padrao do Flutter de lidar com dados async.
          FutureBuilder<List<Article>>(
            future: _newsFuture,
            builder: (context, snapshot) {
              // Estado: aguardando a resposta da API.
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // Estado: ocorreu algum erro (sem internet, limite de API, etc.).
              if (snapshot.hasError) {
                // Remove o prefixo tecnico "Exception: " antes de exibir.
                final mensagem =
                    snapshot.error.toString().replaceFirst('Exception: ', '');

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          mensagem,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        // Botao para tentar novamente sem precisar reiniciar o app.
                        ElevatedButton.icon(
                          onPressed: _loadNews,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tentar novamente'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Estado: dados chegaram, mas a lista esta vazia.
              final articles = snapshot.data ?? [];
              if (articles.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Text(
                      'Nenhuma noticia encontrada.',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                );
              }

              // Estado: tudo certo, exibe a lista de cards clicaveis.
              return Column(
                children: articles.map((article) {
                  // GestureDetector transforma o card em algo clicavel.
                  return GestureDetector(
                    onTap: () {
                      // Navega para a tela de leitura passando o artigo
                      // escolhido pelo usuario.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArticleScreen(article: article),
                        ),
                      );
                    },
                    child: NewsCard(article: article),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  // Monta a busca, o seletor de pais e as categorias em uma area mais amigavel.
  Widget _buildFilterArea(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar noticias',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    tooltip: 'Limpar busca',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _searchController.clear();
                      _loadNews();
                    },
                  )
                : IconButton(
                    tooltip: 'Buscar',
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: _loadNews,
                  ),
            filled: true,
            fillColor:
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
            ),
          ),
          // Busca ao pressionar a tecla de confirmacao do teclado.
          onSubmitted: (_) => _loadNews(),
          // Atualiza a tela so para mostrar/esconder o botao X.
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),

        // Botao segmentado substitui o switch e deixa claro qual pais esta ativo.
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment<bool>(
              value: false,
              icon: Icon(Icons.flag_outlined),
              label: Text('Brasil'),
            ),
            ButtonSegment<bool>(
              value: true,
              icon: Icon(Icons.public),
              label: Text('Internacional'),
            ),
          ],
          selected: {isInternational},
          showSelectedIcon: false,
          onSelectionChanged: (selection) {
            _changeCountry(selection.first);
          },
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: WidgetStateProperty.all(const Size(0, 44)),
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Categoria',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),

        // Chips horizontais economizam espaco e deixam os filtros mais leves.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories.map((category) {
              final isSelected = selectedCategory == category;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  showCheckmark: false,
                  avatar: isSelected
                      ? Icon(
                          Icons.check,
                          size: 18,
                          color: colorScheme.onPrimary,
                        )
                      : null,
                  selectedColor: colorScheme.primary,
                  labelStyle: TextStyle(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                  ),
                  onSelected: (_) => _changeCategory(category),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
