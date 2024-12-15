import 'filieres.dart';
import 'matiere.dart';

class MatiereDetail {
  final int id;
  final Filiere filiere;
  final Matiere matiere;
  final int heuresCours;
  final int heuresTP;
  final int heuresTD;

  MatiereDetail({
    required this.id,
    required this.filiere,
    required this.matiere,
    required this.heuresCours,
    required this.heuresTP,
    required this.heuresTD,
  });

  factory MatiereDetail.fromJson(Map<String, dynamic> json) {
    return MatiereDetail(
      id: json['id'],
      filiere: Filiere.fromJson(json['filiere']),
      matiere: Matiere.fromJson(json['matiere']),
      heuresCours: json['heuresCours'],
      heuresTP: json['heuresTP'],
      heuresTD: json['heuresTD'],
    );
  }
}
