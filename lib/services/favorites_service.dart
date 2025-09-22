import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class FavoritesService {
  static const _storage = FlutterSecureStorage();
  static const String _favoritesKey = 'favorite_teams';
  
  // Obter lista de times favoritos
  Future<Set<String>> getFavoriteTeams() async {
    try {
      final favoritesJson = await _storage.read(key: _favoritesKey);
      if (favoritesJson != null) {
        final List<dynamic> favoritesList = jsonDecode(favoritesJson);
        return favoritesList.cast<String>().toSet();
      }
    } catch (e) {
      throw Exception('Erro ao carregar favoritos: $e');
    }
    return <String>{};
  }
  
  // Salvar lista de favoritos
  Future<void> _saveFavorites(Set<String> favorites) async {
    try {
      final favoritesJson = jsonEncode(favorites.toList());
      await _storage.write(key: _favoritesKey, value: favoritesJson);
    } catch (e) {
      throw Exception('Erro ao salvar favoritos: $e');
    }
  }
  
  // Adicionar time aos favoritos
  Future<void> addToFavorites(String teamName) async {
    final favorites = await getFavoriteTeams();
    favorites.add(teamName);
    await _saveFavorites(favorites);
  }
  
  // Remover time dos favoritos
  Future<void> removeFromFavorites(String teamName) async {
    final favorites = await getFavoriteTeams();
    favorites.remove(teamName);
    await _saveFavorites(favorites);
  }
  
  // Verificar se time é favorito
  Future<bool> isFavorite(String teamName) async {
    final favorites = await getFavoriteTeams();
    return favorites.contains(teamName);
  }
  
  // Toggle favorite status
  Future<bool> toggleFavorite(String teamName) async {
    final isCurrentlyFavorite = await isFavorite(teamName);
    
    if (isCurrentlyFavorite) {
      await removeFromFavorites(teamName);
      return false;
    } else {
      await addToFavorites(teamName);
      return true;
    }
  }
}