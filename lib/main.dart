import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
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
      home: const HomeScreen(),
    );
  }
}
