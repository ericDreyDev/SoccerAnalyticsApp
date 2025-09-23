class PlayerModel {
  final String id;
  final String name;
  final String position;
  final String photoUrl;
  final String nationality;
  final String footPreferred;
  final String height;
  final String weight;

  PlayerModel({
    required this.id,
    required this.name,
    required this.position,
    required this.photoUrl,
    required this.nationality,
    required this.footPreferred,
    required this.height,
    required this.weight,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      id: json['idPlayer']?.toString() ?? '',
      name: json['strPlayer']?.toString() ?? '',
      position: json['strPosition']?.toString() ?? '',
      photoUrl: json['strCutout']?.toString() ?? '',
      nationality: json['strNationality']?.toString() ?? '',
      footPreferred: json['strSide']?.toString() ?? '',
      height: json['strHeight']?.toString() ?? '',
      weight: json['strWeight']?.toString() ?? '',
    );
  }
}
