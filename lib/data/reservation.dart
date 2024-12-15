class Reservation {
  final int? id;
  final String? jour;
  final int? reservationSatuts;
  final String? seance;
  final String? week;
  final int? professeur_id;
  final int? filiere_id;
  final int? salle_id;

  Reservation({
    this.id,
    required this.jour,
    required this.seance,
    required this.week,
    required this.reservationSatuts,
    required this.filiere_id,
    required this.salle_id,
    required this.professeur_id
  });

  // Factory constructor to create an instance from JSON
  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
        id: json['id'],
        jour: json['jour'],
        seance: json['seance'],
        week: json['week'],
        reservationSatuts: json['reservationSatuts'],
        filiere_id: json['filiere_id'],
        salle_id: json['salle_id'],
        professeur_id: json['professeur_id']
    );
  }
}