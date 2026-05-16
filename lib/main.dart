import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'screens/home_screen.dart';
import 'screens/saved_screen.dart';

Future<void> main() async {
  // Garante que o Flutter esteja pronto antes de carregar arquivos/assets.
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega as variaveis do arquivo .env antes de iniciar o app.
  await dotenv.load(fileName: '.env');

  runApp(const BookShelfApp());
}

// Widget principal do aplicativo.
// Ele configura o tema e define qual tela aparece primeiro.
class BookShelfApp extends StatelessWidget {
  const BookShelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookShelf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Define que o app vai usar o tema claro.
        brightness: Brightness.light,

        // Define a cor principal do app como roxa.
        primarySwatch: Colors.purple,

        // Ajusta a cor dos componentes principais, como AppBar e botoes.
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),

        // Usa o Material Design mais atual.
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// Tela principal que controla as abas inferiores do aplicativo.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Indice da aba selecionada: 0 = Inicio, 1 = Salvos.
  int _selectedIndex = 0;

  // Esta chave muda quando o usuario abre a aba Salvos.
  // Assim a lista e recarregada depois que novas noticias sao salvas.
  int _savedScreenRefreshKey = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeScreen(),
          SavedScreen(key: ValueKey(_savedScreenRefreshKey)),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 1) {
              _savedScreenRefreshKey++;
            }
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Salvos',
          ),
        ],
      ),
    );
  }
}
