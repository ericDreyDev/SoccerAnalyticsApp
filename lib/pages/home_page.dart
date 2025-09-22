import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:socceranalyticsapp/components/team_card.dart';
import 'package:socceranalyticsapp/models/league_model.dart';
import 'package:socceranalyticsapp/pages/login_page.dart';

class HomePage extends StatefulWidget {
  final LeagueModel selectedLeague;
  const HomePage({super.key, required this.selectedLeague});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPageIndex = 0;
  String? selectedTeam;

  void openStatisticsFor(String team) {
    setState(() {
      selectedTeam = team;
      currentPageIndex = 1;
    });
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
          NavigationDestination(
            icon: Icon(Icons.bar_chart),
            label: "Statistics",
          ),
          NavigationDestination(icon: Icon(Icons.favorite), label: "Favorites"),
        ],
      ),
      body: IndexedStack(
        index: currentPageIndex,
        children: [
          TeamCard(league: widget.selectedLeague, onTeamTap: openStatisticsFor),
          Center(child: Text("Statistics Page")),
          Center(child: Text("Favorites Page")),
        ],
      ),
    );
  }
}
