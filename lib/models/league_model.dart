class LeagueModel {
  String? id;
  String? name;

  LeagueModel({this.id, this.name});

  LeagueModel.fromJson(Map<String, dynamic> json) {
    id = json['idLeague'];
    name = json['strLeague'];
  }
}
