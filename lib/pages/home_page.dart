import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socceranalyticsapp/components/team_card.dart';
import 'package:socceranalyticsapp/models/league_model.dart';
import 'package:socceranalyticsapp/pages/favorites_page.dart';
import 'package:socceranalyticsapp/pages/login_page.dart';
import 'package:socceranalyticsapp/pages/team_statistics_page.dart';

class HomePage extends StatefulWidget {
  final LeagueModel selectedLeague;
  const HomePage({super.key, required this.selectedLeague});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  String? selectedTeam;

  void openStatisticsFor(String team, String teamId) {
    setState(() {
      selectedTeam = team;
      currentPageIndex = 1;
    });
    // Aqui você pode adicionar a lógica para abrir a página de estatísticas do time selecionado
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamStatisticsPage(teamId: teamId, teamName: team),
      ),
    );
  }

  Future<void> _logout() async {
    const storage = FlutterSecureStorage();

    // Limpar todos os dados salvos
    await storage.delete(key: 'saved_email');
    await storage.delete(key: 'saved_password');
    await storage.delete(key: 'remember_me');

    Navigator.pushAndRemoveUntil( // para evitar voltar com o botão de voltar
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Soccer Analytics"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _logout();
            }, 
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        indicatorColor: Colors.blue,
        selectedIndex: currentPageIndex,
        destinations: [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: "Statistics"),
          NavigationDestination(icon: Icon(Icons.favorite), label: "Favorites"),
        ],
      ),
      body: IndexedStack(
        index: currentPageIndex,
        children: [
          TeamCard(league: widget.selectedLeague, onTeamTap: openStatisticsFor),
          const Center(child: Text("Select a team to view statistics")),
          FavoritesPage(),
        ],
      ),
    );
  }
}
