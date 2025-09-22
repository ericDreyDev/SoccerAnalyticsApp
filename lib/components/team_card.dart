import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socceranalyticsapp/models/team_model.dart';
import 'package:socceranalyticsapp/models/league_model.dart';
import 'package:socceranalyticsapp/repositories/leagues_repository.dart';
import 'package:socceranalyticsapp/services/favorites_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:socceranalyticsapp/providers/favorites_provider.dart';

class TeamCard extends StatefulWidget {
  final LeagueModel league;
  final void Function(String team) onTeamTap;

  const TeamCard({required this.league, required this.onTeamTap, super.key});

  @override
  State<TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends State<TeamCard> {
  late Future<List<TeamModel>> teamsFuture;
  final repository = LeaguesRepository();
  final favoritesService = FavoritesService();

  // Map para controlar estado dos favoritos de cada time
  Map<String, bool> favoriteStates = {};

  @override
  void initState() {
    super.initState();
    teamsFuture = repository.fetchTeamsByLeague(widget.league.id.toString());
    _loadFavoriteStates();
  }

  // Carregar estados dos favoritos
  Future<void> _loadFavoriteStates() async {
    final teams = await teamsFuture;
    final Map<String, bool> states = {};

    for (final team in teams) {
      if (team.name != null) {
        states[team.name!] = await favoritesService.isFavorite(team.name!);
      }
    }

    if (mounted) {
      setState(() {
        favoriteStates = states;
      });
    }
  }

  // Toggle favorito com animação
  Future<void> _toggleFavorite(String teamName) async {
    final favoritesProvider = Provider.of<FavoritesProvider>(
      context,
      listen: false,
    );
    final wasAdded = !favoritesProvider.isFavorite(teamName);

    await favoritesProvider.toggleFavorite(teamName);

    if (mounted) {
      // Feedback visual
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasAdded
                ? '$teamName adicionado aos favoritos!'
                : '$teamName removido dos favoritos!',
          ),
          duration: const Duration(milliseconds: 500),
          backgroundColor: wasAdded ? Colors.red : Colors.grey,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TeamModel>>(
      future: teamsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Loading teams..."),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                Text("Failed to load teams: ${snapshot.error}"),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      teamsFuture = repository.fetchTeamsByLeague(
                        widget.league.id.toString(),
                      );
                    });
                    _loadFavoriteStates();
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        final teams = snapshot.data ?? [];

        if (teams.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sports_soccer, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text("No teams found for this league"),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {
              teamsFuture = repository.fetchTeamsByLeague(
                widget.league.id.toString(),
              );
            });
            await _loadFavoriteStates();
          },
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: teams.length,
            itemBuilder: (context, index) {
              final team = teams[index];
              return _buildTeamCard(team);
            },
          ),
        );
      },
    );
  }

  Widget _buildTeamCard(TeamModel team) {
    final teamName = team.name ?? 'Unknown Team';

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => widget.onTeamTap(teamName),
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Team Badge
                  Expanded(
                    flex: 3,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            team.badgeUrl != null && team.badgeUrl!.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: team.badgeUrl!,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                      Icons.sports_soccer,
                                      size: 48,
                                      color: Colors.grey,
                                    ),
                              )
                            : const Icon(
                                Icons.sports_soccer,
                                size: 48,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Team Name
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          teamName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (team.city != null && team.city!.isNotEmpty)
                          Text(
                            team.city!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // SOLUÇÃO: Consumer ISOLADO só para o botão de favorito
            Positioned(
              bottom: 8,
              right: 8,
              child: Consumer<FavoritesProvider>(
                builder: (context, favoritesProvider, child) {
                  final isFavorite = favoritesProvider.isFavorite(teamName);

                  return AnimatedScale(
                    scale: isFavorite ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: GestureDetector(
                      onTap: () async {
                        // Usar HapticFeedback para melhor UX
                        HapticFeedback.lightImpact();
                        await favoritesProvider.toggleFavorite(teamName);

                        // Feedback visual
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              favoritesProvider.isFavorite(teamName)
                                  ? '$teamName adicionado aos favoritos!'
                                  : '$teamName removido dos favoritos!',
                            ),
                            duration: const Duration(seconds: 1),
                            backgroundColor:
                                favoritesProvider.isFavorite(teamName)
                                ? Colors.red
                                : Colors.grey,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            key: ValueKey(isFavorite),
                            color: isFavorite ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
