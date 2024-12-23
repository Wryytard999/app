import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:login_test/components/my_table.dart';
import 'package:login_test/data/reservation.dart';
import 'package:login_test/shared/based_scaffold.dart';
import '../components/my_primary_button.dart';
import '../data/filieres.dart';
import '../data/global_user.dart';
import '../data/salles.dart';

class ManageProf extends StatefulWidget {
  final bool prof;

  const ManageProf({
    super.key,
    required this.prof
  });

  @override
  State<ManageProf> createState() => _ManageProfState();
}

class _ManageProfState extends State<ManageProf> {
  List<Reservation> profRes = [];
  List<ResAfficher> resAff = [];
  List<Filiere> availableFil = [];
  List<Salles> availableSalles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    FetchData();
    fetchAvailableSalle();
    fetchAvailableFilieres();
  }

  Future<void> fetchAvailableFilieres() async {

    final apiUrl = Uri.parse('http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/filieres');
    print('FETCHING AVAILABLE FILIERES...');
    try {
      final response = await http.get(
          apiUrl,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': GlobalUser.verificationToken!,
            'Email': GlobalUser.email!,
          }
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          availableFil = jsonList.map((json) => Filiere.fromJson(json)).toList();
        });
        print('Filieres loaded: ${availableSalles.length}');
      } else {
        print('Error fetching filieres: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception in fetchAvailableFilieres: $e');
    }
  }

  Future<void> fetchAvailableSalle() async {

    final apiUrl = Uri.parse('http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/salles');
    print('FETCHING AVAILABLE SALLES...');
    try {
      final response = await http.get(
          apiUrl,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': GlobalUser.verificationToken!,
            'Email': GlobalUser.email!,
          }
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          availableSalles = jsonList.map((json) => Salles.fromJson(json)).toList();
        });
        print('Salles loaded: ${availableSalles.length}');
      } else {
        print('Error fetching salles: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception in fetchAvailableSalles: $e');
    }
  }

  void FetchData() async {

    final Map<String, String> seanceToTime = {
      'SEANCE_1': '08:30 am - 10:20 am',
      'SEANCE_2': '10:40 am - 12:30 pm',
      'SEANCE_3': '02:30 pm - 04:20 pm',
      'SEANCE_4': '04:40 pm - 06:30 pm',
    };

    final apiUrl = Uri.parse('http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/reservations/professeur/${GlobalUser.id}');
    print('GETTING DATA FROM API...');

    try {
      final response = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': GlobalUser.verificationToken!,
          'Email': GlobalUser.email!
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body); // Parse the response as a list
        setState(() {
          // Convert the list of JSON objects into a list of Filiere objects
          profRes = jsonList.map((json) => Reservation.fromJson(json)).toList();

          resAff = jsonList
              .map((json) => ResAfficher(
            id: json['id'],
            jour: json['jour'],
            time: seanceToTime[json['seance']] ?? json['seance'],
            filiere: json['filiere']['name'],
            week: json['week'],
            salle: json['salle']['name'],
          ))
              .toList();


          isLoading = false;
        });
        print('DATA IS HERE');
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void ajouterRes() async {
    String? selectedTime;
    String? selectedJour;
    String? selectedWeek;
    Salles? selectedSalle;
    Filiere? selectedFiliere;

    final jours = ['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI'];
    final weeks = List.generate(36, (index) => 'WEEK_${index + 1}');
    final Map<String, String> timeToSeance = {
      '08:30 am - 10:20 am': 'SEANCE_1',
      '10:40 am - 12:30 pm': 'SEANCE_2',
      '02:30 pm - 04:20 pm': 'SEANCE_3',
      '04:40 pm - 06:30 pm': 'SEANCE_4',
    };

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter une réservation'),
          content: StatefulBuilder(
            builder: (BuildContext context, setDialogState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedJour,
                      decoration: InputDecoration(labelText: 'Jour'),
                      items: jours.map((jour) {
                        return DropdownMenuItem(value: jour, child: Text(jour));
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedJour = value;
                        });
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedTime,
                      decoration: InputDecoration(labelText: 'Seance'),
                      items: timeToSeance.keys.map((time) {
                        return DropdownMenuItem(value: time, child: Text(time));
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedTime = value;
                        });
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedWeek,
                      decoration: InputDecoration(labelText: 'Semaine'),
                      items: weeks.map((week) {
                        return DropdownMenuItem(value: week, child: Text(week));
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedWeek = value;
                        });
                      },
                    ),
                    DropdownButtonFormField<Salles>(
                      value: selectedSalle,
                      decoration: InputDecoration(labelText: 'Salle'),
                      items: availableSalles.map((salle) {
                        return DropdownMenuItem(value: salle, child: Text(salle.name));
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedSalle = value;
                        });
                      },
                    ),
                    DropdownButtonFormField<Filiere>(
                      value: selectedFiliere,
                      decoration: InputDecoration(labelText: 'Filière'),
                      items: availableFil.map((filiere) {
                        return DropdownMenuItem(value: filiere, child: Text(filiere.name));
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedFiliere = value;
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ajouter'),
              onPressed: () async {
                if (selectedJour != null &&
                    selectedWeek != null &&
                    selectedSalle != null &&
                    selectedTime != null &&
                    selectedFiliere != null) {
                  final apiUrl = Uri.parse(
                      'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/reservations');

                  final body = jsonEncode({
                    "jour": selectedJour,
                    "week": selectedWeek,
                    "seance": timeToSeance[selectedTime], // You can extend this to include seance selection.
                    "salleId": selectedSalle!.id,
                    "filiereId": selectedFiliere!.id,
                  });

                  try {
                    final response = await http.post(
                      apiUrl,
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': GlobalUser.verificationToken!,
                        'Email': GlobalUser.email!,
                      },
                      body: body,
                    );

                    if (response.statusCode == 200 || response.statusCode == 201) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.green,
                          content: Text('Réservation ajoutée avec succès.'),
                        ),
                      );
                      FetchData(); // Refresh data after adding.
                    } else if (response.statusCode == 400) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.redAccent,
                          content: Text('Impossible de réserver une semaine passée'),
                        ),
                      );
                    } else if (response.statusCode == 409) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.redAccent,
                          content: Text('Vous êtes occupés'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Erreur lors de l\'ajout'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      print('Erreur lors de l\'ajout: ${response.statusCode} - ${response.body}');
                    }
                  } catch (e) {
                    print('Exception lors de l\'ajout: $e');
                  }

                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Veuillez remplir tous les champs.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  print('Veuillez remplir tous les champs.');
                }
              },
            ),
          ],
        );
      },
    );
  }

  void deleteRes() {
    showDialog(
      context: context,
      builder: (context) {
        List<int?> selectedResIds = [];

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Supprimer reservations'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: resAff.length,
                  itemBuilder: (context, index) {
                    final res = resAff[index];
                    return CheckboxListTile(
                      title: Text('${res.jour} ${res.week} ${res.time}'),
                      value: selectedResIds.contains(res.id),
                      onChanged: (isSelected) {
                        setState(() {
                          if (isSelected == true) {
                            selectedResIds.add(res.id);
                          } else {
                            selectedResIds.remove(res.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                MyPrimaryButtonButton(
                  text: 'Supprimer',
                  color: Colors.redAccent,
                  onTap: () async {
                    if (selectedResIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.orange,
                          content: Text('Veuillez sélectionner au moins une filière.'),
                        ),
                      );
                      return;
                    }

                    for (var id in selectedResIds) {
                      try {
                        final deleteUrl = Uri.parse(
                            'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/reservations/$id');
                        final response = await http.delete(
                          deleteUrl,
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': GlobalUser.verificationToken!,
                            'Email': GlobalUser.email!
                          },
                        );

                        if (response.statusCode >= 200 || response.statusCode < 300) {
                          print('reservation with ID $id deleted successfully.');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text('reservations supprimées avec succès!'),
                            ),
                          );
                        } else {
                          print(
                              'Failed to delete reservations with ID $id: ${response.body}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Text('Error'),
                            ),
                          );
                        }
                      } catch (e) {
                        print('Exception during delete for reservation with ID $id: $e');
                      }
                    }

                    // Refresh the filieres list
                    FetchData();

                    Navigator.pop(context); // Close the dialog
                  },
                ),
                SizedBox(height: 10),
                MyPrimaryButtonButton(
                  text: 'Annuler',
                  color: Colors.black,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }




  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
        title: 'Reservations',
        body: Column(
          children: [
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
              child: ListView.builder(
                itemCount: profRes.length,
                itemBuilder: (context, index) {
                  final res = resAff[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        MyTable(
                            filiere: res.filiere,
                            salle: res.salle,
                            day: res.jour,
                            seance: res.time,
                            week: res.week
                        ),
                        SizedBox(height: 10)
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 25),
            widget.prof ? Padding(
              padding: const EdgeInsets.only(bottom: 20), // Adjust spacing from the bottom
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      MyPrimaryButtonButton(
                        text: '  Ajouter  ',
                        onTap: ajouterRes,
                        color: Colors.green,
                      ),
                      SizedBox(height: 15),
                      MyPrimaryButtonButton(
                        text: 'Supprimer',
                        onTap: deleteRes,
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ) : SizedBox(height: 1),
          ],
        )
    );
  }
}

class ResAfficher {
  int? id;
  String? filiere;
  String? jour;
  String? time;
  String? week;
  String? salle;

  ResAfficher({
    this.id,
    this.filiere,
    this.jour,
    this.time,
    this.week,
    this.salle,
  });
}