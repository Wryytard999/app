import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:login_test/components/info_card.dart';
import 'package:login_test/shared/based_scaffold.dart';
import '../components/my_primary_button.dart';
import '../data/filieres.dart';
import '../data/global_user.dart';
import '../data/matiere.dart';
import '../data/matiere_detail.dart';

class FiliereMat extends StatefulWidget {
  final bool coor;

  const FiliereMat({
    super.key,
    required this.coor
  });

  @override
  State<FiliereMat> createState() => _FiliereMatState();
}

class _FiliereMatState extends State<FiliereMat> {
  List<Filiere> filieres = [];
  bool isLoading = true;
  List<Matiere> availableMatieres = [];

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
        final List<dynamic> jsonList = jsonDecode(response.body); // Parse the response as a list
        setState(() {
          // Convert the list of JSON objects into a list of Filiere objects
          filieres = jsonList.map((json) => Filiere.fromJson(json)).toList();
          isLoading = false;
        });
        print('DATA IS HERE');
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

  Future<void> fetchAvailableMatieres() async {

    final apiUrl = Uri.parse('http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/matieres');
    print('FETCHING AVAILABLE MATIERES...');
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
          availableMatieres = jsonList.map((json) => Matiere.fromJson(json)).toList();
        });
        print('Matieres loaded: ${availableMatieres.length}');
      } else {
        print('Error fetching matieres: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception in fetchAvailableMatieres: $e');
    }
  }

  void AddMat(Filiere filiere) async {
    // Ensure matieres are loaded before showing the dialog
    await fetchAvailableMatieres();

    final TextEditingController coursController = TextEditingController();
    final TextEditingController tdController = TextEditingController();
    final TextEditingController tpController = TextEditingController();
    int? selectedMatiereId;

    if (availableMatieres.isEmpty) {
      print('No Matieres available to add.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No Matieres available. Please add Matieres first.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show dialog
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Add Matiere to: ${filiere.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<int>(
                  value: selectedMatiereId,
                  hint: Text('Select Matiere'),
                  isExpanded: true,
                  items: availableMatieres.map((matiere) {
                    return DropdownMenuItem<int>(
                      value: matiere.id,
                      child: Text(matiere.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedMatiereId = value!;
                    });
                  },
                ),
                TextField(
                  controller: coursController,
                  decoration: InputDecoration(labelText: 'Heures Cours'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: tdController,
                  decoration: InputDecoration(labelText: 'Heures TD'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: tpController,
                  decoration: InputDecoration(labelText: 'Heures TP'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              MyPrimaryButtonButton(
                text: 'Ajouter',
                onTap: () async {
                  if (selectedMatiereId == null) {
                    print('No Matiere selected.');
                    return;
                  }

                  // Check if the Matiere already exists in the Filiere
                  final alreadyExists = await checkMatiereExistsInFiliere(filiere.id!, selectedMatiereId!);
                  if (alreadyExists) {
                    Navigator.of(context).pop(); // Close the dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('This Matiere already exists in the Filiere!'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  // Proceed to add the Matiere
                  await addMatiereToFiliere(
                    filiere.id!,
                    selectedMatiereId!,
                    coursController.text,
                    tdController.text,
                    tpController.text,
                  );
                  Navigator.of(context).pop(); // Close the dialog
                  showMat(filiere); // Refresh the list
                },
                color: Colors.green,
              ),
              SizedBox(height: 15),
              MyPrimaryButtonButton(
                text: 'Cancel',
                onTap: () => Navigator.of(context).pop(),
                color: Colors.black,
              ),
            ],
          );
        },
      ),
    );
  }

// Helper function to check if the Matiere exists in the Filiere
  Future<bool> checkMatiereExistsInFiliere(int filiereId, int matiereId) async {
    final apiUrl = Uri.parse(
        'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/charges-horaires/filiere/$filiereId');
    print('Checking if Matiere ID: $matiereId exists in Filiere ID: $filiereId...');

    try {
      final response = await http.get(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': GlobalUser.verificationToken!,
          'Email': GlobalUser.email!,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        // Check if any MatiereDetail in the response matches the selected Matiere ID
        return jsonList.any((json) => json['matiere']['id'] == matiereId);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception: $e');
      return false;
    }
  }



  Future<void> addMatiereToFiliere(
      int filiereId,
      int matiereId,
      String heuresCours,
      String heuresTD,
      String heuresTP,
      ) async {
    final apiUrl = Uri.parse(
        'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/charges-horaires/filiere/$filiereId/matiere/$matiereId');
    print('ADDING MATIERE ID: $matiereId TO FILIERE ID: $filiereId...');

    try {
      final response = await http.post(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': GlobalUser.verificationToken!,
          'Email': GlobalUser.email!,
        },
        body: jsonEncode({
          'heuresCours': int.parse(heuresCours),
          'heuresTD': int.parse(heuresTD),
          'heuresTP': int.parse(heuresTP),
        }),
      );

      if (response.statusCode == 200) {
        print('Matiere added successfully.');
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void showMat(Filiere filiere) async {
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
        List<MatiereDetail> matieres = jsonList.map((json) => MatiereDetail.fromJson(json)).toList();

        // Show the data in a dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Matieres for: ${filiere.name}'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: matieres.length,
                itemBuilder: (context, index) {
                  final matiereDetail = matieres[index];
                  return ListTile(
                    title: Text(matiereDetail.matiere.name),
                    subtitle: Text(
                      'Cours: ${matiereDetail.heuresCours}h, TD: ${matiereDetail.heuresTD}h, TP: ${matiereDetail.heuresTP}h',
                    ),
                    onTap: () {
                      if (widget.coor) {
                        Navigator.of(context).pop();
                        showUpdateMatiereDialog(matiereDetail, filiere);
                      } else {
                        null;
                      } // Open the update dialog
                    },
                  );
                },
              ),
            ),
            actions: [
              widget.coor ? MyPrimaryButtonButton(
                text: 'Ajouter',
                onTap: () {
                  Navigator.of(context).pop();
                  AddMat(filiere);
                }, // Close the dialog
                color: Colors.green,
              ) : SizedBox(height: 0),
              SizedBox(height: 15),
              MyPrimaryButtonButton(
                text: 'Cancel',
                onTap: () => Navigator.of(context).pop(), // Close the dialog
                color: Colors.black,
              )
            ],
          ),
        );
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void deleteMatiere(int id, Filiere filiere) async {
    final apiUrl = Uri.parse('http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/charges-horaires/$id');
    print('DELETING MATIERE ID: $id...');

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
        showMat(filiere); // Refresh the list
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void showUpdateMatiereDialog(MatiereDetail matiereDetail, Filiere filiere) {
    final TextEditingController coursController = TextEditingController(text: '${matiereDetail.heuresCours}');
    final TextEditingController tdController = TextEditingController(text: '${matiereDetail.heuresTD}');
    final TextEditingController tpController = TextEditingController(text: '${matiereDetail.heuresTP}');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update: ${matiereDetail.matiere.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: coursController,
              decoration: InputDecoration(labelText: 'Heures Cours'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: tdController,
              decoration: InputDecoration(labelText: 'Heures TD'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: tpController,
              decoration: InputDecoration(labelText: 'Heures TP'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          MyPrimaryButtonButton(
            text: 'Update',
            onTap: () => updateMatiere(
              matiereDetail.id,
              coursController.text,
              tdController.text,
              tpController.text,
              filiere,
            ),
            color: Colors.blue,
          ),
          SizedBox(height: 10),
          MyPrimaryButtonButton(
            text: 'Delete',
            onTap: () => deleteMatiere(matiereDetail.id, filiere),
            color: Colors.redAccent,
          ),
          SizedBox(height: 10),
          MyPrimaryButtonButton(
            text: 'Cancel',
            onTap: () => Navigator.of(context).pop(),
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  void updateMatiere(int id, String heuresCours, String heuresTD, String heuresTP, Filiere filiere) async {
    final apiUrl = Uri.parse('http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/charges-horaires/$id');
    print('UPDATING MATIERE ID: $id...');

    try {
      final response = await http.put(
        apiUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': GlobalUser.verificationToken!,
          'Email': GlobalUser.email!
        },
        body: jsonEncode({
          'heuresCours': int.parse(heuresCours),
          'heuresTD': int.parse(heuresTD),
          'heuresTP': int.parse(heuresTP),
        }),
      );

      print('Status Code: ${response.statusCode}');
      if (response.statusCode == 200) {
        print('Matiere updated successfully.');
        Navigator.of(context).pop(); // Close the dialog
        showMat(filiere); // Refresh the list
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
        title: 'Filieres Matieres',
        body: Column(
          children: [
            isLoading
                ? Center(child: CircularProgressIndicator())
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
                      edit: () => showMat(filiere),
                      toEdit: true,
                      icon: Icons.remove_red_eye,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 25),
            widget.coor ? Padding(
              padding: const EdgeInsets.only(bottom: 20), // Adjust spacing from the bottom
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                ],
              ),
            ) : SizedBox(height: 1),
            SizedBox(height: 15)
          ],
        )
    );
  }
}