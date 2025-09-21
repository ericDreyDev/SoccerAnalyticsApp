import 'package:flutter/material.dart';
import 'package:socceranalyticsapp/components/team_card.dart';
import 'package:socceranalyticsapp/models/league_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Soccer Analytics"),
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

          TeamCard(
            league: widget.selectedLeague,
            onTeamTap: openStatisticsFor,
          ),
          Center(
            child: Text("Statistics Page"),
          ),
          Center(
            child: Text("Favorites Page"),
          ),
        ],
      ),
    );
  }
}