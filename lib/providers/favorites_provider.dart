import 'package:flutter/material.dart';
import 'package:socceranalyticsapp/services/favorites_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesService _favoritesService = FavoritesService();
  Set<String> _favoriteTeams = <String>{};
  bool _isLoading = false;

  Set<String> get favoriteTeams => _favoriteTeams;
  bool get isLoading => _isLoading;

  // Carregar favoritos do storage
  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _favoriteTeams = await _favoritesService.getFavoriteTeams();
    } catch (e) {
      print('Erro ao carregar favoritos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verificar se time é favorito
  bool isFavorite(String teamName) {
    return _favoriteTeams.contains(teamName);
  }

  // Toggle favorito
  Future<void> toggleFavorite(String teamName) async {
    try {
      final newState = await _favoritesService.toggleFavorite(teamName);
      
      if (newState) {
        _favoriteTeams.add(teamName);
      } else {
        _favoriteTeams.remove(teamName);
      }
      
      // Notificar todos os widgets que estão "ouvindo"
      notifyListeners();
    } catch (e) {
      print('Erro ao alterar favorito: $e');
    }
  }

  // Remover favorito
  Future<void> removeFavorite(String teamName) async {
    try {
      await _favoritesService.removeFromFavorites(teamName);
      _favoriteTeams.remove(teamName);
      notifyListeners();
    } catch (e) {
      print('Erro ao remover favorito: $e');
    }
  }
}