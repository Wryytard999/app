class Salles {
  final int? id;
  final String name;
  final String location;
  final int numberOfSeats;
  final String type;

  Salles({
    this.id,
    required this.location,
    required this.numberOfSeats,
    required this.name,
    required this.type
  });

  // Factory constructor to create an instance from JSON
  factory Salles.fromJson(Map<String, dynamic> json) {
    return Salles(
      id: json['id'],
      name: json['name'],
      numberOfSeats: json['numberOfSeats'],
      location: json['location'],
      type: json['type']
    );
  }
}
