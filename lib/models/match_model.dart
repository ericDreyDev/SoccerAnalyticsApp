class MatchModel {
  final String descriptionMatch;
  final String dateMatch;
  final String timeMatch;
  final String homeTeam;
  final String awayTeam;
  final String badgeHomeTeam;
  final String badgeAwayTeam;
  final String scoreHome;
  final String scoreAway;
  final String thumbMatch;

  MatchModel({
    required this.descriptionMatch,
    required this.dateMatch,
    required this.timeMatch,
    required this.homeTeam,
    required this.awayTeam,
    required this.badgeHomeTeam,
    required this.badgeAwayTeam,
    required this.scoreHome,
    required this.scoreAway,
    required this.thumbMatch,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      descriptionMatch: json['strEvent']?.toString() ?? '',
      dateMatch: json['dateEvent']?.toString() ?? '',
      timeMatch: json['strTime']?.toString() ?? '',
      homeTeam: json['strHomeTeam']?.toString() ?? '',
      awayTeam: json['strAwayTeam']?.toString() ?? '',
      badgeHomeTeam: json['strHomeTeamBadge']?.toString() ?? '',
      badgeAwayTeam: json['strAwayTeamBadge']?.toString() ?? '',
      scoreHome: json['intHomeScore']?.toString() ?? '',
      scoreAway: json['intAwayScore']?.toString() ?? '',
      thumbMatch: json['strThumb']?.toString() ?? '',
    );
  }
}
