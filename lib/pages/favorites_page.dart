import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:socceranalyticsapp/providers/favorites_provider.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, favoritesProvider, child) {
        if (favoritesProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final favorites = favoritesProvider.favoriteTeams;

        if (favorites.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No favorite teams added',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Add favorite teams from the home page.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final teamName = favorites.elementAt(index);
            return Card(
              child: ListTile(
                leading: const Icon(Icons.sports_soccer),
                title: Text(teamName),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () async {
                    await favoritesProvider.removeFavorite(teamName);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$teamName has been removed from favorites!'),
                        duration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
