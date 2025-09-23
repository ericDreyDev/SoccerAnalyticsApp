import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_teams';

  Future<Set<String>> getFavoriteTeams() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_favoritesKey) ?? <String>[];
      return list.toSet();
    } catch (e) {
      throw Exception('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites(Set<String> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_favoritesKey, favorites.toList());
    } catch (e) {
      throw Exception('Error saving favorites: $e');
    }
  }

  Future<void> addToFavorites(String teamName) async {
    final favorites = await getFavoriteTeams();
    favorites.add(teamName);
    await _saveFavorites(favorites);
  }

  Future<void> removeFromFavorites(String teamName) async {
    final favorites = await getFavoriteTeams();
    favorites.remove(teamName);
    await _saveFavorites(favorites);
  }

  Future<bool> isFavorite(String teamName) async {
    final favorites = await getFavoriteTeams();
    return favorites.contains(teamName);
  }

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
