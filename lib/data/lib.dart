class Lib {
  final int? id;
  final String? week;
  final int? emploiId;

  Lib({this.id, required this.week, required this.emploiId});

  // Factory constructor to create an instance from JSON
  factory Lib.fromJson(Map<String, dynamic> json) {
    return Lib(
      id: json['id'],
      week: json['week'],
      emploiId: json['emploiDuTemps']['id']
    );
  }
}