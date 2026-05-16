import 'package:shared_preferences/shared_preferences.dart';

// Servico responsavel por guardar preferencias simples do usuario.
class PreferencesService {
  static const String _categoryKey = 'selected_category';
  static const String _countryKey = 'selected_country';

  // Salva a ultima categoria escolhida pelo usuario.
  Future<void> saveCategory(String category) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_categoryKey, category);
  }

  // Busca a categoria salva.
  // Se ainda nao existir nada salvo, retorna "Geral".
  Future<String> getCategory() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_categoryKey) ?? 'Geral';
  }

  // Salva o pais escolhido: "br" para Brasil ou "us" para Internacional.
  Future<void> saveCountry(String country) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_countryKey, country);
  }

  // Busca o pais salvo.
  // Se ainda nao existir nada salvo, retorna "br".
  Future<String> getCountry() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_countryKey) ?? 'br';
  }
}
