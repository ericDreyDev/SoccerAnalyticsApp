import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:socceranalyticsapp/models/match_model.dart';
import 'package:socceranalyticsapp/models/player_model.dart';
import 'package:socceranalyticsapp/repositories/teams_repository.dart';

class TeamStatisticsPage extends StatefulWidget {
  final String teamId;
  final String teamName;

  const TeamStatisticsPage({
    super.key,
    required this.teamId,
    this.teamName = '',
  });

  @override
  State<TeamStatisticsPage> createState() => _TeamStatisticsPageState();
}

class _TeamStatisticsPageState extends State<TeamStatisticsPage> {
  final repo = TeamsRepository();

  Future<List<MatchModel>>? _nextFuture;
  Future<List<MatchModel>>? _lastFuture;
  Future<List<PlayerModel>>? _playerFuture;

  @override
  void initState() {
    super.initState();
    _nextFuture = repo.fetchNextMatch(widget.teamId);
    _lastFuture = repo.fetchLastMatch(widget.teamId);
    _playerFuture = repo.fetchAllPlayers(widget.teamId);
  }

  Future<void> _refreshNext() async {
    setState(() => _nextFuture = repo.fetchNextMatch(widget.teamId));
    await _nextFuture;
  }

  Future<void> _refreshLast() async {
    setState(() => _lastFuture = repo.fetchLastMatch(widget.teamId));
    await _lastFuture;
  }

  Future<void> _refreshPlayers() async {
    setState(() => _playerFuture = repo.fetchAllPlayers(widget.teamId));
    await _playerFuture;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.teamName.isNotEmpty
        ? 'Statistics for ${widget.teamName}'
        : 'Team Statistics';
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.schedule), text: 'Next'),
              Tab(icon: Icon(Icons.sports_score), text: 'Last'),
              Tab(icon: Icon(Icons.group), text: 'Players'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _NextMatchTab(future: _nextFuture, onRefresh: _refreshNext),
            _LastMatchTab(future: _lastFuture, onRefresh: _refreshLast),
            _PlayersTab(future: _playerFuture, onRefresh: _refreshPlayers),
          ],
        ),
      ),
    );
  }
}

class _NextMatchTab extends StatelessWidget {
  final Future<List<MatchModel>>? future;
  final Future<void> Function() onRefresh;
  const _NextMatchTab({required this.future, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: FutureBuilder<List<MatchModel>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return ListView(
              children: [
                SizedBox(height: 200),
                Center(child: CircularProgressIndicator()),
              ],
            );
          }
          if (snap.hasError) {
            return _ErrorList(
              message: 'Failed to load next match: ${snap.error}',
              onRetry: onRefresh,
            );
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const _EmptyList(
              message: 'No upcoming matches found.',
            );
          }
          final m = list.first;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _MatchCard(
                title: m.descriptionMatch,
                date: m.dateMatch,
                time: m.timeMatch,
                home: m.homeTeam,
                away: m.awayTeam,
                score: null,
                thumb: m.thumbMatch,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LastMatchTab extends StatelessWidget {
  final Future<List<MatchModel>>? future;
  final Future<void> Function() onRefresh;
  const _LastMatchTab({required this.future, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: FutureBuilder<List<MatchModel>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return ListView(
              children: [
                SizedBox(height: 200),
                Center(child: CircularProgressIndicator()),
              ],
            );
          }
          if (snap.hasError) {
            return _ErrorList(
              message: 'Failed to load last match: ${snap.error}',
              onRetry: onRefresh,
            );
          }
          final list = snap.data ?? [];
          if (list.isEmpty) {
            return const _EmptyList(
              message: 'No last match found.',
            );
          }
          final m = list.first;
          final score = (m.scoreHome.isNotEmpty || m.scoreAway.isNotEmpty)
              ? '${m.scoreHome} - ${m.scoreAway}'
              : null;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _MatchCard(
                title: m.descriptionMatch,
                date: m.dateMatch,
                time: m.timeMatch,
                home: m.homeTeam,
                away: m.awayTeam,
                score: score,
                thumb: m.thumbMatch,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PlayersTab extends StatelessWidget {
  final Future<List<PlayerModel>>? future;
  final Future<void> Function() onRefresh;
  const _PlayersTab({required this.future, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: FutureBuilder<List<PlayerModel>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return ListView(
              children: [
                SizedBox(height: 200),
                Center(child: CircularProgressIndicator()),
              ],
            );
          }
          if (snap.hasError) {
            return _ErrorList(
              message: 'Failed to load players: ${snap.error}',
              onRetry: onRefresh,
            );
          }
          final players = snap.data ?? [];
          if (players.isEmpty) {
            return const _EmptyList(message: 'No players found.');
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: players.map((p) => _PlayerCard(p)).toList(),
          );
        },
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final String home;
  final String away;
  final String? score;
  final String thumb;

  const _MatchCard({
    required this.title,
    required this.date,
    required this.time,
    required this.home,
    required this.away,
    required this.thumb,
    this.score,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (thumb.isNotEmpty)
            CachedNetworkImage(
              imageUrl: thumb,
              fit: BoxFit.cover,
              height: 160,
              placeholder: (c, _) => const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (c, _, __) => const SizedBox(
                height: 160,
                child: Center(child: Icon(Icons.image_not_supported, size: 40)),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('$home vs $away'),
                const SizedBox(height: 4),
                Text('Date: $date'),
                const SizedBox(height: 2),
                Text('Time: $time'),
                if (score != null) ...[
                  const SizedBox(height: 8),
                  Text('Score: $score'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final PlayerModel p;
  const _PlayerCard(this.p);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 120,
            child: p.photoUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: p.photoUrl,
                    fit: BoxFit.contain,
                    placeholder: (c, _) =>
                        const Center(child: CircularProgressIndicator()),
                    errorWidget: (c, _, __) =>
                        const Icon(Icons.person, size: 48, color: Colors.grey),
                  )
                : const Center(
                    child: Icon(Icons.person, size: 48, color: Colors.grey),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p.name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(p.position, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),
                if (p.nationality.isNotEmpty)
                  Text(
                    'Nationality: ${p.nationality}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (p.footPreferred.isNotEmpty)
                  Text(
                    'Foot: ${p.footPreferred}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (p.height.isNotEmpty)
                  Text(
                    'Height: ${p.height}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (p.weight.isNotEmpty)
                  Text(
                    'Weight: ${p.weight}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorList extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorList({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(Icons.error, color: Theme.of(context).colorScheme.error, size: 48),
        const SizedBox(height: 12),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(message, textAlign: TextAlign.center),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: ElevatedButton(
            onPressed: () => onRetry(),
            child: const Text('Try Again'),
          ),
        ),
      ],
    );
  }
}

class _EmptyList extends StatelessWidget {
  final String message;
  const _EmptyList({required this.message});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        SizedBox(height: 120),
        Icon(Icons.info_outline, size: 48, color: Colors.grey),
        SizedBox(height: 12),
        Center(child: Text('No data available at the moment.')),
      ],
    );
  }
}
