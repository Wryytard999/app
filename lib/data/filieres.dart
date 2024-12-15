class Filiere {
  final int? id;
  final String name;
  final int capacity;

  Filiere({this.id, required this.name, required this.capacity});

  // Factory constructor to create an instance from JSON
  factory Filiere.fromJson(Map<String, dynamic> json) {
    return Filiere(
      id: json['id'],
      name: json['name'],
      capacity: json['capacity'],
    );
  }
}
