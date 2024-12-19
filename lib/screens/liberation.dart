import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:login_test/components/emploi_slot_prof.dart';
import 'package:login_test/data/lib.dart';
import 'package:login_test/data/prof.dart';
import 'package:login_test/data/salles.dart';
import 'package:login_test/shared/based_scaffold.dart';
import '../components/liberation_card.dart';
import '../data/filieres.dart';
import '../data/global_user.dart';
import '../data/matiere_detail.dart';

class Liberation extends StatefulWidget {
  final bool prof;

  const Liberation({
    super.key,
    required this.prof
  });

  @override
  State<Liberation> createState() => _LiberationState();
}

class _LiberationState extends State<Liberation> {
  static String? selectedDay = 'LUNDI';
  List<Filiere> filieres = [];
  List<Lib> liberations = [];
  bool isLoading = true;
  List<MatiereDetail> availableMatieres = [];
  List<LiberationDisplay> combinedLiberations = [];
  List<Prof> availableProfs = [];
  List<Salles> availableSalles = [];
  List<EmploiAfficher> emploiSemaine = [];
  List<EmploiAfficher> emploiLib = [];
  // To filter by day
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

  @override
  void initState() {
    super.initState();
    FetchLib();
    showEmp();
  }


  void FetchLib() async {
    final apiUrlLib = Uri.parse('http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/liberations');
    final apiUrlEmp = Uri.parse(
        'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/emplois_du_temps/professeur/${GlobalUser.id}');

    try {
      setState(() => isLoading = true);

      // Step 1: Fetch liberations
      final libResponse = await http.get(apiUrlLib, headers: {
        'Content-Type': 'application/json',
        'Authorization': GlobalUser.verificationToken!,
        'Email': GlobalUser.email!
      });

      // Step 2: Fetch emplois
      final empResponse = await http.get(apiUrlEmp, headers: {
        'Content-Type': 'application/json',
        'Authorization': GlobalUser.verificationToken!,
        'Email': GlobalUser.email!
      });

      if (libResponse.statusCode == 200 && empResponse.statusCode == 200) {
        final List<dynamic> libList = jsonDecode(libResponse.body);
        final List<dynamic> empList = jsonDecode(empResponse.body);

        // Parse liberations and emplois
        liberations = libList.map((json) => Lib.fromJson(json)).toList();
        emploiLib = empList
            .map((json) => EmploiAfficher(
          id: json['id'],
          jour: json['jour'],
          time: seanceToTime[json['seance']] ?? json['seance'], // Raw seance for matching
          matiere: json['chargeHoraire']['matiere']['name'],
          salle: json['salle']['name'],
        ))
            .toList();

        // Step 3: Combine liberations with emploi data
        combinedLiberations = liberations.map((lib) {
          final matchedEmploi = emploiLib.firstWhere(
                (emploi) => emploi.id == lib.emploiId,
            orElse: () => EmploiAfficher(), // Default empty emploi
          );

          return LiberationDisplay(
            liberationId: lib.id,
            seance: matchedEmploi.time,
            matiere: matchedEmploi.matiere,
            salle: matchedEmploi.salle,
            week: lib.week, // Extract week directly from the lib object
          );
        }).toList();


        print('Combined Data: $combinedLiberations');
      } else {
        print('Error fetching liberations or emplois.');
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showEmp() async {
    setState(() => isLoading = true);

    final apiUrl = Uri.parse(
        'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/emplois_du_temps/professeur/${GlobalUser.id}');
    print('GETTING EMPLOI DATA FOR PROF ID: ${GlobalUser.id}...');

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

        // Map JSON data to EmploiAfficher objects
        setState(() {
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

          // Sort by seance order
          emploiSemaine.sort((a, b) {
            int indexA = timeOrder.indexOf(a.time ?? '');
            int indexB = timeOrder.indexOf(b.time ?? '');
            return indexA.compareTo(indexB);
          });
        });
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showEmpLib(int? emploiId) async {
    setState(() => isLoading = true);

    final apiUrl = Uri.parse(
        'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/emplois_du_temps/${emploiId}');
    print('GETTING EMPLOI DATA FOR PROF ID: ${GlobalUser.id}...');

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

        // Map JSON data to EmploiAfficher objects
        setState(() {
          emploiLib = jsonList
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

          // Sort by seance order
          emploiSemaine.sort((a, b) {
            int indexA = timeOrder.indexOf(a.time ?? '');
            int indexB = timeOrder.indexOf(b.time ?? '');
            return indexA.compareTo(indexB);
          });
        });
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  void free(int emploiId) async {
    String? selectedWeek; // Variable to hold the selected week

    // Generate the list of weeks from WEEK_1 to WEEK_36
    List<String> weeks = List.generate(36, (index) => 'WEEK_${index + 1}');

    // Show the dialog to allow week selection
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select a Week'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
              return DropdownButton<String>(
                value: selectedWeek,
                hint: Text('Choose a week'),
                items: weeks.map((week) {
                  return DropdownMenuItem<String>(
                    value: week,
                    child: Text(week),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setDialogState(() {
                    selectedWeek = newValue; // Update selected week
                  });
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog without doing anything
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (selectedWeek != null) {
                  Navigator.pop(context, selectedWeek); // Return the selected week
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please select a week'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );

    // If no week is selected, stop the function
    if (selectedWeek == null) {
      print('No week selected.');
      return;
    }

    print('ADDING LIBERATION FOR WEEK: $selectedWeek...');

    final apiUrl = Uri.parse(
        'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/liberations/emploi-du-temps/${emploiId}');

    try {
      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': GlobalUser.verificationToken!,
          'Email': GlobalUser.email!,
        },
        body: jsonEncode({
          'week': selectedWeek, // Add the selected week
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        FetchLib(); // Refresh the list after successful liberation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Séance libérée pour $selectedWeek!'),
          ),
        );
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Impossible de libérer une semaine passée'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Erreur'),
          ),
        );
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void deleteLib(int? libID) async {
    try {
      final deleteUrl = Uri.parse(
          'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/liberations/$libID');
      final response = await http.delete(
        deleteUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': GlobalUser.verificationToken!,
          'Email': GlobalUser.email!
        },
      );

      if (response.statusCode >= 200 || response.statusCode < 300) {
        print('Filiere with ID $libID deleted successfully.');
        FetchLib();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text('Liberation supprimée avec succès!'),
          ),
        );
      } else {
        print(
            'Failed to delete Liberation with ID $libID: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text('Error'),
          ),
        );
      }
    } catch (e) {
      print('Exception during delete for Filiere with ID $libID: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Liberations',
      body: Column(
        children: [
          // Dropdown to filter by day
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedDay,
              hint: Text('Filtrer par jour'),
              isExpanded: true,
              items: ['LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI']
                  .map((day) => DropdownMenuItem(
                value: day,
                child: Text(day),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedDay = value;
                });
              },
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: emploiSemaine.length,
              itemBuilder: (context, index) {
                final emploi = emploiSemaine[index];
                // Filter by day if selected
                if (selectedDay == null || emploi.jour == selectedDay) {
                  return Column(
                    children: [
                      EmploiSlotProf(
                        time: emploi.time!,
                        type: emploi.type!,
                        matiere: emploi.matiere!,
                        prof: emploi.prof!,
                        salle: emploi.salle!,
                        func: () {
                          free(emploi.id!);
                        },
                      ),
                      SizedBox(height: 10),
                    ],
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
            ),
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    'Liberations effectuees',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : combinedLiberations.isEmpty
              ? Center(child: Text('No liberations found.'))
              : Expanded(
            child: ListView.builder(
              itemCount: combinedLiberations.length,
              itemBuilder: (context, index) {
                final lib = combinedLiberations[index];
                return LiberationCard(
                  matiere: lib.matiere,
                  seance: lib.seance,
                  salle: lib.salle,
                  liberationId: lib.liberationId,
                  week: lib.week,
                  onPressed: () {
                    // Custom logic when the button is pressed
                    deleteLib(lib.liberationId);
                  },
                );
              },
            ),
          ),
          SizedBox(height: 100)
        ],
      ),
    );
  }
}

class LiberationDisplay {
  final int? liberationId;
  final String? seance;
  final String? matiere;
  final String? salle;
  final String? week; // Added week property

  LiberationDisplay({
    this.liberationId,
    this.seance,
    this.matiere,
    this.salle,
    this.week,
  });
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