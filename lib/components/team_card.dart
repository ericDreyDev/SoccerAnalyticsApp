import 'package:flutter/material.dart';
import 'package:socceranalyticsapp/models/team_model.dart';
import 'package:socceranalyticsapp/models/league_model.dart';
import 'package:socceranalyticsapp/repositories/leagues_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

  @override
  void initState() {
    super.initState();
    teamsFuture = repository.fetchTeamsByLeague(widget.league.id.toString());
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => widget.onTeamTap(team.name ?? 'Unknown Team'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
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
                    child: team.badgeUrl != null && team.badgeUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: team.badgeUrl!,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Icon(
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
                      team.name ?? 'Unknown Team',
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
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
      ),
    );
  }
}
