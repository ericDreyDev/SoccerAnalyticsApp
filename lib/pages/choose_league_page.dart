import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socceranalyticsapp/models/league_model.dart';
import 'package:socceranalyticsapp/pages/home_page.dart';
import 'package:socceranalyticsapp/repositories/leagues_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ChooseLeaguePage extends StatefulWidget {
  const ChooseLeaguePage({super.key});

  @override
  State<ChooseLeaguePage> createState() => _ChooseLeaguePageState();
}

class _ChooseLeaguePageState extends State<ChooseLeaguePage> {
  LeagueModel? selectedLeague;
  late Future<List<LeagueModel>> leaguesFuture;
  final repository = LeaguesRepository();
  final _storage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    leaguesFuture = repository.fetchLeagues();
  }

  Future<void> _confirmSelection() async {
    if (selectedLeague != null) {
      try {
        await _storage.write(
          key: 'selected_league',
          value: jsonEncode({
            'idLeague': selectedLeague!.id,
            'strName': selectedLeague!.name,
          }),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HomePage(selectedLeague: selectedLeague!),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar liga: $e')));
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a league")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Choose your favorite league")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<LeagueModel>>(
          future: leaguesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Failed to load leagues"),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          leaguesFuture = repository.fetchLeagues();
                        });
                      },
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              );
            }
            final leagues = snapshot.data ?? [];

            if (leagues.isEmpty) {
              return const Center(child: Text("No leagues available"));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<LeagueModel>(
                  decoration: const InputDecoration(
                    labelText: "Select League",
                    border: OutlineInputBorder(),
                  ),
                  items: leagues.map((league) {
                    return DropdownMenuItem(
                      value: league,
                      child: Text(league.name ?? ''),
                    );
                  }).toList(),
                  value: selectedLeague,
                  onChanged: (value) {
                    setState(() {
                      selectedLeague = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: selectedLeague != null ? _confirmSelection : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text("Confirm"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
