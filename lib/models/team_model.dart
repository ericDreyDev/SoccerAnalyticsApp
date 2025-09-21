class TeamModel {
  final String? id;
  final String? name;
  final String? stadium;
  final String? stadiumCapacity;
  final String? city;
  final String? country;
  final String? badgeUrl;

  TeamModel({
    this.id,
    this.name,
    this.stadium,
    this.stadiumCapacity,
    this.city,
    this.country,
    this.badgeUrl,
  });

  TeamModel.fromJson(Map<String, dynamic> json)
      : id = json['idTeam'],
        name = json['strTeam'],
        stadium = json['strStadium'],
        stadiumCapacity = json['intStadiumCapacity'],
        city = json['strCity'],
        country = json['strCountry'],
        badgeUrl = json['strBadge'];
}