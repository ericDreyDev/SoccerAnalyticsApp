import 'dart:convert';
import 'package:socceranalyticsapp/models/league_model.dart';
import 'package:socceranalyticsapp/models/team_model.dart';
import 'package:http/http.dart' as http;

class LeaguesRepository {
  
  Future<List<LeagueModel>> fetchLeagues() async {
    final response = await http.get(
      Uri.parse('https://www.thesportsdb.com/api/v1/json/123/all_leagues.php')
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final leaguesData = jsonData['leagues'] as List<dynamic>;
      
      return leaguesData
          .map((json) => LeagueModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load leagues: ${response.statusCode}');
    }
  }

  Future<List<TeamModel>> fetchTeamsByLeague(String leagueId) async {
    final response = await http.get(
      Uri.parse('https://www.thesportsdb.com/api/v1/json/123/lookup_all_teams.php?id=$leagueId')
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final teamsData = jsonData['teams'] as List<dynamic>;
      
      return teamsData
          .map((json) => TeamModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load teams: ${response.statusCode}');
    }
  }
}