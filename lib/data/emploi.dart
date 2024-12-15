class Emploi {
  final int? id;
  final String? jour;
  final String? seance;
  final String? typeSeance;
  final int? chargeHoraire_id;
  final int? salle_id;
  final int? professeur_id;

  Emploi({
    this.id,
    required this.jour,
    required this.seance,
    required this.typeSeance,
    required this.chargeHoraire_id,
    required this.salle_id,
    required this.professeur_id
  });

  // Factory constructor to create an instance from JSON
  factory Emploi.fromJson(Map<String, dynamic> json) {
    return Emploi(
        id: json['id'],
        jour: json['jour'],
        seance: json['seance'],
        typeSeance: json['typeSeance'],
        chargeHoraire_id: json['chargeHoraire_id'],
        salle_id: json['salle_id'],
        professeur_id: json['professeur_id']
    );
  }
}