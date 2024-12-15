class Matiere {
  final int? id;
  final String name;

  Matiere({this.id, required this.name});

  // Factory constructor to create an instance from JSON
  factory Matiere.fromJson(Map<String, dynamic> json) {
    return Matiere(
      id: json['id'],
      name: json['name'],
    );
  }
}