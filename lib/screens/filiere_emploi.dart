import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:login_test/components/emploi_slot.dart';
import 'package:login_test/components/info_card.dart';
import 'package:login_test/data/prof.dart';
import 'package:login_test/data/salles.dart';
import 'package:login_test/shared/based_scaffold.dart';
import '../components/my_primary_button.dart';
import '../data/filieres.dart';
import '../data/global_user.dart';
import '../data/matiere_detail.dart';

class EmploiPage extends StatefulWidget {
  final bool coor;

  const EmploiPage({
    super.key,
    required this.coor
  });

  @override
  State<EmploiPage> createState() => _EmploiPageState();
}

class _EmploiPageState extends State<EmploiPage> {
  static String? selectedDay = 'LUNDI';
  List<Filiere> filieres = [];
  bool isLoading = true;
  List<MatiereDetail> availableMatieres = [];
  List<Prof> availableProfs = [];
  List<Salles> availableSalles = [];
  List<EmploiAfficher> emploiSemaine = [];

  @override
  void initState() {
    super.initState();
    FetchData();
  }

  void FetchData() async {
    final apiUrl = Uri.parse('http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/filieres');
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
        final List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          filieres = jsonList.map((json) => Filiere.fromJson(json)).toList();
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

  Future<void> fetchAvailableChargeHoraraie(Filiere filiere) async {

    final apiUrl = Uri.parse(
        'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/charges-horaires/filiere/${filiere.id}');
    print('GETTING MATIERES DATA FOR FILIERE ID: ${filiere.id}...');

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
        final List<dynamic> jsonList = jsonDecode(response.body);
        availableMatieres = jsonList.map((json) => MatiereDetail.fromJson(json)).toList();
        print('Matieres loaded: ${availableMatieres.length}');
      } else {
        print('Error fetching matieres: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception in fetchAvailableMatieres: $e');
    }
  }

  Future<void> fetchAvailableProfesseurs() async {

    final apiUrl = Uri.parse('http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/users/professeurs');
    print('FETCHING AVAILABLE PROFESSORS...');
    try {
      final response = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': GlobalUser.verificationToken!,
          'Email': GlobalUser.email!,
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          availableProfs = jsonList.map((json) => Prof.fromJson(json)).toList();
        });
        print('Matieres loaded: ${availableProfs.length}');
      } else {
        print('Error fetching professeurs: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception in fetchAvailableProfesseurs: $e');
    }
  }

  Future<void> fetchAvailableSalle() async {

    final apiUrl = Uri.parse('http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/salles');
    print('FETCHING AVAILABLE MATIERES...');
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
        print('Matieres loaded: ${availableSalles.length}');
      } else {
        print('Error fetching salles: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception in fetchAvailableSalles: $e');
    }
  }

  void addEmp(Filiere filiere) async {
    String? selectedTime;
    Prof? selectedProf;
    Salles? selectedSalle;
    MatiereDetail? selectedMatiere;

    final Map<String, String> timeToSeance = {
      '08:30 am - 10:20 am': 'SEANCE_1',
      '10:40 am - 12:30 pm': 'SEANCE_2',
      '02:30 pm - 04:20 pm': 'SEANCE_3',
      '04:40 pm - 06:30 pm': 'SEANCE_4',
    };

    await fetchAvailableChargeHoraraie(filiere);
    await fetchAvailableProfesseurs();
    await fetchAvailableSalle();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Ajouter un emploi: ${filiere.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedTime,
                    hint: const Text('Select Time Slot'),
                    items: timeToSeance.keys
                        .map((time) => DropdownMenuItem(
                      value: time,
                      child: Text(time),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedTime = value;
                      });
                    },
                  ),
                  DropdownButton<Prof>(
                    value: selectedProf,
                    hint: const Text('Select Professor'),
                    items: availableProfs
                        .map((prof) => DropdownMenuItem(
                      value: prof,
                      child: Text(prof.username ?? 'Unknown'),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedProf = value;
                      });
                    },
                  ),
                  DropdownButton<Salles>(
                    value: selectedSalle,
                    hint: const Text('Select Salle'),
                    items: availableSalles
                        .map((salle) => DropdownMenuItem(
                      value: salle,
                      child: Text(salle.name),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedSalle = value;
                      });
                    },
                  ),
                  DropdownButton<MatiereDetail>(
                    value: selectedMatiere,
                    hint: const Text('Select Matiere'),
                    items: availableMatieres
                        .map((mat) => DropdownMenuItem(
                      value: mat,
                      child: Text(mat.matiere.name),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedMatiere = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                MyPrimaryButtonButton(
                  text: 'Ajouter',
                  onTap: () async {
                    if (selectedDay != null &&
                        selectedTime != null &&
                        selectedProf != null &&
                        selectedSalle != null &&
                        selectedMatiere != null) {
                      final apiUrl = Uri.parse(
                          'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/emplois_du_temps/filiere/${filiere.id}');

                      final body = {
                        "jour": selectedDay,
                        "seance": timeToSeance[selectedTime],
                        "typeSeance": selectedSalle!.type,
                        "chargeHoraireId": selectedMatiere!.id,
                        "salleId": selectedSalle!.id,
                        "professeurId": selectedProf!.id
                      };

                      try {
                        final response = await http.post(
                          apiUrl,
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': GlobalUser.verificationToken!,
                            'Email': GlobalUser.email!,
                          },
                          body: jsonEncode(body),
                        );

                        if (response.statusCode == 200 || response.statusCode == 201) {
                          Navigator.of(context).pop();
                          showEmp(filiere);
                          print('Emploi added successfully');
                        } else {
                          print('Error adding emploi: ${response.statusCode} - ${response.body}');
                        }
                      } catch (e) {
                        print('Exception: $e');
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All fields must be selected'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      print('All fields must be selected');
                    }
                  },
                  color: Colors.green,
                ),
                SizedBox(height: 10),
                MyPrimaryButtonButton(
                  text: 'Annuler',
                  onTap: () => Navigator.of(context).pop(),
                  color: Colors.black,
                ),
              ],
            );
          },
        );
      },
    );
  }

  void ModifierEmp(Filiere filiere, int? emploiID) async {
    String? selectedTime;
    Prof? selectedProf;
    Salles? selectedSalle;
    MatiereDetail? selectedMatiere;

    final Map<String, String> timeToSeance = {
      '08:30 am - 10:20 am': 'SEANCE_1',
      '10:40 am - 12:30 pm': 'SEANCE_2',
      '02:30 pm - 04:20 pm': 'SEANCE_3',
      '04:40 pm - 06:30 pm': 'SEANCE_4',
    };

    await fetchAvailableChargeHoraraie(filiere);
    await fetchAvailableProfesseurs();
    await fetchAvailableSalle();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Modifier un emploi: ${filiere.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedTime,
                    hint: const Text('Select Time Slot'),
                    items: timeToSeance.keys
                        .map((time) => DropdownMenuItem(
                      value: time,
                      child: Text(time),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedTime = value;
                      });
                    },
                  ),
                  DropdownButton<Prof>(
                    value: selectedProf,
                    hint: const Text('Select Professor'),
                    items: availableProfs
                        .map((prof) => DropdownMenuItem(
                      value: prof,
                      child: Text(prof.username ?? 'Unknown'),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedProf = value;
                      });
                    },
                  ),
                  DropdownButton<Salles>(
                    value: selectedSalle,
                    hint: const Text('Select Salle'),
                    items: availableSalles
                        .map((salle) => DropdownMenuItem(
                      value: salle,
                      child: Text(salle.name),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedSalle = value;
                      });
                    },
                  ),
                  DropdownButton<MatiereDetail>(
                    value: selectedMatiere,
                    hint: const Text('Select Matiere'),
                    items: availableMatieres
                        .map((mat) => DropdownMenuItem(
                      value: mat,
                      child: Text(mat.matiere.name),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedMatiere = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                MyPrimaryButtonButton(
                  text: 'Modifier',
                  onTap: () async {
                    if (selectedDay != null &&
                        selectedTime != null &&
                        selectedProf != null &&
                        selectedSalle != null &&
                        selectedMatiere != null) {
                      final apiUrl = Uri.parse(
                          'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/emplois_du_temps/${emploiID}');

                      final body = {
                        "jour": selectedDay,
                        "seance": timeToSeance[selectedTime],
                        "typeSeance": selectedSalle!.type,
                        "chargeHoraireId": selectedMatiere!.id,
                        "salleId": selectedSalle!.id,
                        "professeurId": selectedProf!.id
                      };

                      try {
                        final response = await http.put(
                          apiUrl,
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': GlobalUser.verificationToken!,
                            'Email': GlobalUser.email!,
                          },
                          body: jsonEncode(body),
                        );

                        if (response.statusCode == 200 || response.statusCode == 201) {
                          Navigator.of(context).pop();
                          showEmp(filiere);
                          print('Emploi updated successfully');
                        } else {
                          print('Error updating emploi: ${response.statusCode} - ${response.body}');
                        }
                      } catch (e) {
                        print('Exception: $e');
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('All fields must be selected'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      print('All fields must be selected');
                    }
                  },
                  color: Colors.blueAccent,
                ),
                SizedBox(height: 10),
                MyPrimaryButtonButton(
                  text: 'Annuler',
                  onTap: () => Navigator.of(context).pop(),
                  color: Colors.black,
                ),
              ],
            );
          },
        );
      },
    );
  }

  void deleteEmp(Filiere filiere, int? emploiID) async {
    final apiUrl = Uri.parse('http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/emplois_du_temps/${emploiID}');
    print('DELETING Emploi ID: ${emploiID}...');

    try {
      final response = await http.delete(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': GlobalUser.verificationToken!,
          'Email': GlobalUser.email!
        },
      );

      print('Status Code: ${response.statusCode}');
      if (response.statusCode >= 200 || response.statusCode < 300) {
        print('Matiere deleted successfully.');
        Navigator.of(context).pop(); // Close the dialog
        showEmp(filiere); // Refresh the list
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void showEmp(Filiere filiere) async {

    final apiUrl = Uri.parse(
        'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/emplois_du_temps/filiere/${filiere.id}');
    print('GETTING EMPLOI DATA FOR FILIERE ID: ${filiere.id}...');

// Map for converting seance names to time slots
    final Map<String, String> seanceToTime = {
      'SEANCE_1': '08:30 am - 10:20 am',
      'SEANCE_2': '10:40 am - 12:30 pm',
      'SEANCE_3': '02:30 pm - 04:20 pm',
      'SEANCE_4': '04:40 pm - 06:30 pm',
    };

    final List<String> timeOrder = [
      '08:30 am - 10:20 am',
      '10:40 am - 12:30 pm',
      '02:30 pm - 04:20 pm',
      '04:40 pm - 06:30 pm',
    ];

    try {
      final response = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': GlobalUser.verificationToken!,
          'Email': GlobalUser.email!,
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);

        // Map JSON data to a structured list of EmploiAfficher objects
        emploiSemaine = jsonList
            .map((json) => EmploiAfficher(
          id: json['id'],
          jour: json['jour'],
          time: seanceToTime[json['seance']] ?? json['seance'],
          type: json['typeSeance'],
          matiere: json['chargeHoraire']['matiere']['name'],
          prof: json['user']['username'],
          salle: json['salle']['name'],
        ))
            .toList();
        emploiSemaine.sort((a, b) {
          int indexA = timeOrder.indexOf(a.time ?? '');
          int indexB = timeOrder.indexOf(b.time ?? '');
          return indexA.compareTo(indexB);
        }); // Sort by seance order

        // Show the data in a dialog
        showDialog(
          context: context,
          builder: (context) { // Local state for selected day

            return StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                return AlertDialog(
                  title: Text('Emploi: ${filiere.name}'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButton<String>(
                          value: selectedDay,
                          hint: const Text('Select an option'),
                          items: [
                            const DropdownMenuItem<String>(
                              value: 'LUNDI',
                              child: Text('LUNDI'),
                            ),
                            const DropdownMenuItem<String>(
                              value: 'MARDI',
                              child: Text('MARDI'),
                            ),
                            const DropdownMenuItem<String>(
                              value: 'MERCREDI',
                              child: Text('MERCREDI'),
                            ),
                            const DropdownMenuItem<String>(
                              value: 'JEUDI',
                              child: Text('JEUDI'),
                            ),
                            const DropdownMenuItem<String>(
                              value: 'VENDREDI',
                              child: Text('VENDREDI'),
                            ),
                          ],
                          onChanged: (String? newValue) {
                            setDialogState(() {
                              selectedDay = newValue; // Update local state
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: emploiSemaine.length,
                            itemBuilder: (context, index) {
                              final emploi = emploiSemaine[index];
                              // Show only items that match the selected day
                              if (emploi.jour == selectedDay) {
                                return Column(
                                  children: [
                                    EmploiSlot(
                                      time: emploi.time!,
                                      type: emploi.type!,
                                      matiere: emploi.matiere!,
                                      prof: emploi.prof!,
                                      salle: emploi.salle!,
                                      edit: () {
                                        Navigator.of(context).pop();
                                        ModifierEmp(filiere, emploi.id);
                                      },
                                      delete: () {
                                        deleteEmp(filiere, emploi.id);
                                      },
                                      role: GlobalUser.isCoor(),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                );
                              } else {
                                return const SizedBox.shrink(); // Don't display anything if the day doesn't match
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    widget.coor ? MyPrimaryButtonButton(
                      text: 'Ajouter',
                      onTap: () {
                        Navigator.of(context).pop();
                        addEmp(filiere);
                        },
                      color: Colors.green,
                    ) : const SizedBox(height: 0),
                    const SizedBox(height: 10),
                    MyPrimaryButtonButton(
                      text: 'Annuler',
                      onTap: () => Navigator.of(context).pop(), // Close the dialog
                      color: Colors.black,
                    ),
                  ],
                );
              },
            );
          },
        );
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
        title: 'Filieres Emploi',
        body: Column(
          children: [
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Expanded(
              child: ListView.builder(
                itemCount: filieres.length,
                itemBuilder: (context, index) {
                  final filiere = filieres[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: InfoCard(
                      title: filiere.name,
                      capacity: -1,
                      edit: () => showEmp(filiere),
                      toEdit: true,
                      icon: Icons.remove_red_eye,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 25),
          ],
        )
    );
  }
}

class EmploiAfficher {
  int? id;
  String? jour;
  String? time;
  String? type;
  String? matiere;
  String? prof;
  String? salle;

  EmploiAfficher({
    this.id,
    this.jour,
    this.time,
    this.type,
    this.matiere,
    this.prof,
    this.salle,
  });
}