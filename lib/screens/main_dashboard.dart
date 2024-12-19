import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:login_test/components/button_card.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:login_test/components/button_card_diag.dart';
import 'package:login_test/components/my_primary_button.dart';
import '../../data/global_user.dart';
import '../../shared/based_scaffold.dart';
import '../data/salles.dart';

class MainDashboard extends StatefulWidget {
  final String? username = GlobalUser.username;

  MainDashboard({
    super.key,
  });

  @override
  State<MainDashboard> createState() => _CoorMainPageState();
}

class _CoorMainPageState extends State<MainDashboard> {
  String selectedDay = 'LUNDI';
  String selectedWeek = 'WEEK_1';
  String selectedSeance = '08:30 am - 10:20 am';

  final List<String> days = [
    'LUNDI', 'MARDI', 'MERCREDI', 'JEUDI', 'VENDREDI'
  ];
  final List<String> weeks = [
    for (var i = 1; i <= 36; i++) 'WEEK_$i'
  ];
  final List<String> seances = [
    for (var i = 1; i <= 36; i++) 'SEANCE_$i'
  ];

  final Map<String, String> timeToSeance = {
    '08:30 am - 10:20 am': 'SEANCE_1',
    '10:40 am - 12:30 pm': 'SEANCE_2',
    '02:30 pm - 04:20 pm': 'SEANCE_3',
    '04:40 pm - 06:30 pm': 'SEANCE_4',
  };

  final Map<String, String> seanceToTime = {
    for (var entry in {
      '08:30 am - 10:20 am': 'SEANCE_1',
      '10:40 am - 12:30 pm': 'SEANCE_2',
      '02:30 pm - 04:20 pm': 'SEANCE_3',
      '04:40 pm - 06:30 pm': 'SEANCE_4',
    }.entries)
      entry.value: entry.key,
  };

  List<Salles> sallesList = [];

  void showSallesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Available Salles'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sallesList.length,
              itemBuilder: (BuildContext context, int index) {
                final salle = sallesList[index];
                return ListTile(
                  title: Text(salle.name),
                  subtitle: Text(
                      'Location: ${salle.location}\nSeats: ${salle.numberOfSeats}\nType: ${salle.type}'),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void checkSalle() async {
    final apiUrl = Uri.parse(
        'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/salles/free-day-week-seance');
    print('GETTING DATA FROM API...');

    try {
      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': GlobalUser.verificationToken!,
          'Email': GlobalUser.email!
        },
        body: jsonEncode({
          'day': selectedDay,
          'week': selectedWeek,
          'seance': timeToSeance[selectedSeance], // Convert before sending
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        setState(() {
          sallesList = responseData.map((data) => Salles.fromJson(data)).toList();
        });
        showSallesDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${response.statusCode} - ${response.body}'),
            backgroundColor: Colors.red,
          ),
        );
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  String title() {
    if (GlobalUser.role == "RESPONSABLE_SALLES") {
      return "RESPONSABLE SALLES";
    }
    return GlobalUser.role!;
  }

  String formattedDate = DateFormat('EEEE,\nMMMM d\nyyyy').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: title(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 30),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Welcome, ',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: widget.username,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Dropdown Menus
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey.shade100,
                ),
                width: 400,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 5),
                      const Text(
                        'Check what salles are free :',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 20,
                          fontWeight: FontWeight.w400
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DropdownButton<String>(
                            value: selectedDay,
                            items: days
                                .map((day) => DropdownMenuItem(
                              value: day,
                              child: Text(day),
                            ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedDay = value!;
                              });
                            },
                          ),
                          const SizedBox(width: 50),
                          DropdownButton<String>(
                            value: selectedWeek,
                            items: weeks
                                .map((week) => DropdownMenuItem(
                              value: week,
                              child: Text(week),
                            ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedWeek = value!;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      DropdownButton<String>(
                        value: selectedSeance,
                        items: timeToSeance.keys
                            .map((time) => DropdownMenuItem(
                          value: time,
                          child: Text(time),
                        ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSeance = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: 200,
                        child: MyPrimaryButtonButton(
                            text: 'Check Salle',
                            onTap: checkSalle,
                            color: Colors.black
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100),
              Container(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ButtonCard(
                          title: 'Responsable des salles',
                          color: Colors.grey.shade100,
                          icon: Icons.manage_accounts,
                          route: 'respo',
                          role: GlobalUser.isRespo(),
                        ),
                        ButtonCard(
                          title: 'Matieres',
                          color: Colors.grey.shade100,
                          icon: Icons.manage_accounts,
                          route: 'Matiere',
                          role: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ButtonCardDiag(
                          title: 'Espace Professeurs',
                          color: Colors.grey.shade100,
                          icon: Icons.manage_accounts,
                          subroutes: [
                            '/prof',
                            '/lib'
                          ],
                          subRoutesNames: [
                            'Reservations',
                            'Liberations'
                          ],
                          role: GlobalUser.isProf(),
                        ),
                        ButtonCardDiag(
                          title: 'Espace Coordinateur',
                          color: Colors.grey.shade100,
                          icon: Icons.manage_accounts,
                          subroutes: [
                            '/filiere',
                            '/filiereMat',
                            '/emploi'
                          ],
                          subRoutesNames: [
                            'Generale',
                            'Filieres matieres',
                            'Filieres emploi'
                          ],
                          role: true
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
