import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/article.dart';

// Servico responsavel por salvar noticias no banco SQLite local.
class DatabaseService {
  // Singleton: cria uma unica instancia do servico para o app inteiro.
  DatabaseService._internal();

  static final DatabaseService instance = DatabaseService._internal();

  // Guarda a conexao aberta com o banco.
  // O ponto de interrogacao indica que ela pode comecar nula.
  Database? _database;

  // Getter assincrono que abre o banco apenas uma vez.
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _openDatabase();
    return _database!;
  }

  // Cria ou abre o arquivo do banco de dados dentro da pasta do app.
  Future<Database> _openDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'bookshelf.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Esta tabela guarda as noticias que o usuario quer ler depois.
        await db.execute('''
          CREATE TABLE saved_articles (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            url TEXT NOT NULL UNIQUE,
            imageUrl TEXT NOT NULL,
            source TEXT NOT NULL,
            publishedAt TEXT NOT NULL,
            isRead INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  // Salva uma noticia no banco.
  // Se a URL ja existir, substitui o registro antigo pelo mais recente.
  Future<void> saveArticle(Article article) async {
    final db = await database;

    await db.insert(
      'saved_articles',
      {
        'title': article.title,
        'url': article.url,
        'imageUrl': article.imageUrl,
        'source': article.source,
        'publishedAt': article.publishedAt.toIso8601String(),
        'isRead': article.isRead ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Busca todas as noticias salvas e converte cada linha em um Article.
  Future<List<Article>> getSavedArticles() async {
    final db = await database;

    final rows = await db.query(
      'saved_articles',
      orderBy: 'publishedAt DESC',
    );

    return rows.map((row) {
      return Article(
        title: row['title'] as String,
        description: '',
        url: row['url'] as String,
        imageUrl: row['imageUrl'] as String,
        source: row['source'] as String,
        publishedAt:
            DateTime.tryParse(row['publishedAt'] as String) ?? DateTime.now(),
        isRead: (row['isRead'] as int) == 1,
        isSaved: true,
      );
    }).toList();
  }

  // Remove uma noticia salva usando a URL como identificador.
  Future<void> deleteArticle(String url) async {
    final db = await database;

    await db.delete(
      'saved_articles',
      where: 'url = ?',
      whereArgs: [url],
    );
  }

  // Marca uma noticia como lida usando a URL como identificador.
  Future<void> markAsRead(String url) async {
    final db = await database;

    await db.update(
      'saved_articles',
      {'isRead': 1},
      where: 'url = ?',
      whereArgs: [url],
    );
  }
}
