# BookShelf

BookShelf é um aplicativo Flutter desenvolvido para a faculdade. O app funciona
como um agregador de notícias, permitindo buscar matérias na internet, filtrar
por país e categoria, abrir a notícia completa no navegador e salvar conteúdos
para ler depois.

## Funcionalidades

- Listagem de notícias recentes usando a GNews API.
- Busca por palavra-chave.
- Filtro por país: Brasil ou Internacional.
- Filtro por categoria em chips horizontais.
- Tela de leitura com imagem, título, fonte, data e resumo.
- Botão para abrir a matéria completa no navegador.
- Salvamento local de notícias para ler depois.
- Tela de notícias salvas.
- Marcação de notícia como lida.
- Remoção de notícia salva.
- Persistência da última categoria e país escolhidos pelo usuário.
- Navegação inferior com abas `Início` e `Salvos`.

## Tecnologias utilizadas

- Flutter
- Dart
- GNews API
- SQLite com `sqflite`
- `shared_preferences`
- `flutter_dotenv`
- `http`
- `url_launcher`

## Estrutura do projeto

```text
lib/
  main.dart
  models/
    article.dart
  screens/
    home_screen.dart
    article_screen.dart
    saved_screen.dart
  services/
    news_service.dart
    database_service.dart
    preferences_service.dart
  widgets/
    news_card.dart
```

## Principais arquivos

### `main.dart`

Inicializa o Flutter, carrega o arquivo `.env` e configura o tema do app.
Também contém a navegação principal com `BottomNavigationBar`, alternando entre:

- `HomeScreen`: tela inicial com notícias recentes.
- `SavedScreen`: tela com notícias salvas localmente.

### `models/article.dart`

Define o modelo `Article`, que representa uma notícia dentro do app.
O modelo possui campos como:

- `title`
- `description`
- `url`
- `imageUrl`
- `source`
- `publishedAt`
- `isRead`
- `isSaved`

Também possui o método `fromJson()`, usado para converter a resposta da GNews API
em objetos Dart.

### `screens/home_screen.dart`

É a tela inicial do aplicativo. Ela mostra:

- Campo de busca.
- Seletor entre Brasil e Internacional.
- Categorias em chips horizontais.
- Lista de notícias recentes.

Quando o usuário muda país ou categoria, a preferência é salva e a lista de
notícias é recarregada.

### `screens/article_screen.dart`

Mostra os detalhes de uma notícia selecionada.

Nessa tela o usuário pode:

- Ler o resumo da notícia.
- Abrir a matéria completa no navegador.
- Salvar a notícia para ler depois.

### `screens/saved_screen.dart`

Mostra todas as notícias salvas no banco local SQLite.

Cada item permite:

- Abrir a notícia na tela de leitura.
- Marcar como lida.
- Remover dos salvos.

Quando não há notícias salvas, a tela mostra a mensagem:

```text
Nenhuma notícia salva ainda
```

### `services/news_service.dart`

Responsável por consumir a GNews API.

Ele usa:

- `/top-headlines` para buscar manchetes por categoria.
- `/search` para buscar notícias por palavra-chave.

Também trata erros como:

- Falta de conexão.
- Limite de requisições da API.
- Nenhum resultado encontrado.
- Resposta inválida da API.

### `services/database_service.dart`

Responsável pelo armazenamento local usando SQLite.

Cria o banco `bookshelf.db` com a tabela `saved_articles`, contendo:

- `id`
- `title`
- `url`
- `imageUrl`
- `source`
- `publishedAt`
- `isRead`

Métodos principais:

- `saveArticle(Article article)`
- `getSavedArticles()`
- `deleteArticle(String url)`
- `markAsRead(String url)`

O serviço usa o padrão Singleton para evitar abrir várias conexões com o banco.

### `services/preferences_service.dart`

Responsável por salvar preferências simples do usuário com
`shared_preferences`.

Preferências salvas:

- Última categoria escolhida.
- Último país escolhido.

### `widgets/news_card.dart`

Widget reutilizável para exibir uma notícia em formato de card.

Mostra:

- Imagem da notícia.
- Título.
- Fonte.
- Horário.
- Botão de bookmark para salvar direto da lista principal.

## Configuração da API

O app usa a GNews API. Para funcionar, é necessário criar um arquivo `.env` na
raiz do projeto.

Exemplo:

```env
GNEWS_API_KEY=SUA_CHAVE_AQUI
```

O arquivo `.env` não deve ser enviado para o GitHub, pois contém uma chave
privada. Ele está listado no `.gitignore`.

Existe também o arquivo `.env.example`, que serve como modelo para outros
desenvolvedores.

## Dependências

As principais dependências estão no `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_dotenv: ^5.2.1
  http: ^1.2.2
  path: ^1.9.1
  shared_preferences: ^2.3.2
  sqflite: ^2.4.1
  url_launcher: ^6.3.0
```

## Como executar

1. Instale as dependências:

```bash
flutter pub get
```

2. Crie o arquivo `.env` na raiz do projeto:

```env
GNEWS_API_KEY=SUA_CHAVE_AQUI
```

3. Verifique o ambiente:

```bash
flutter doctor
```

4. Rode no emulador ou dispositivo conectado:

```bash
flutter run
```

Para rodar em um emulador específico:

```bash
flutter devices
flutter run -d emulator-5554
```

## Permissões Android

O app precisa de permissão de internet para acessar a GNews API.

No `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Também há configuração para permitir que o `url_launcher` encontre navegadores
capazes de abrir links `http` e `https`.

## Responsividade e layout

O app foi construído com widgets básicos do Flutter, como:

- `Container`
- `Row`
- `Column`
- `Image.network`
- `Icon`
- `ElevatedButton`
- `OutlinedButton`
- `IconButton`
- `SegmentedButton`
- `ChoiceChip`
- `ListView`
- `FutureBuilder`

Para melhorar a adaptação em diferentes tamanhos de celular, o app usa:

- `ListView` para rolagem vertical.
- `SingleChildScrollView` para chips horizontais.
- `Expanded` para evitar estouro de texto em linhas.
- `AspectRatio` para imagens proporcionais.
- `ConstrainedBox` na tela de leitura para manter o conteúdo confortável em
  telas maiores.

## Observações

- A chave da GNews API deve ser configurada localmente no `.env`.
- O SQLite salva as notícias apenas no dispositivo do usuário.
- O app depende de conexão com a internet para carregar notícias novas.
- Notícias já salvas continuam disponíveis localmente.

## Status do projeto

Versão final para entrega acadêmica com:

- Layout principal.
- Integração com API.
- Tela de leitura.
- Armazenamento local.
- Tela de salvos.
- Preferências persistentes.
- Navegação por abas.
