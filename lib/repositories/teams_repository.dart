import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socceranalyticsapp/models/player_model.dart';
import 'package:socceranalyticsapp/models/team_model.dart';
import 'package:socceranalyticsapp/models/match_model.dart';

import 'package:http/http.dart' as http;

class TeamsRepository {
  Future<List<MatchModel>> fetchNextMatch(String teamId) async {
    final response = await http.get(
      Uri.parse(
        'https://www.thesportsdb.com/api/v1/json/123/eventsnext.php?id=$teamId',
      ),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final eventsData = jsonData['events'] as List<dynamic>?;

      if (eventsData != null) {
        return eventsData
            .map((json) => MatchModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load next match: ${response.statusCode}');
    }
  }

  Future<List<MatchModel>> fetchLastMatch(String teamId) async {
    final response = await http.get(
      Uri.parse(
        'https://www.thesportsdb.com/api/v1/json/123/eventslast.php?id=$teamId',
      ),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final eventsData = jsonData['results'] as List<dynamic>?;

      if (eventsData != null) {
        return eventsData
            .map((json) => MatchModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load last match: ${response.statusCode}');
    }
  }

  Future<List<PlayerModel>> fetchAllPlayers(String teamId) async {
    final response = await http.get(
      Uri.parse(
        'https://www.thesportsdb.com/api/v1/json/123/lookup_all_players.php?id=$teamId',
      ),
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final playersData = jsonData['player'] as List<dynamic>?;

      if (playersData != null) {
        return playersData
            .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to load players: ${response.statusCode}');
    }
  }
}
