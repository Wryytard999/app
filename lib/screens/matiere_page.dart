import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:login_test/components/info_card.dart';
import 'package:login_test/shared/based_scaffold.dart';
import '../components/my_primary_button.dart';
import '../data/matiere.dart';
import '../data/global_user.dart';

class MatierePage extends StatefulWidget {
  final bool coor;

  const MatierePage({
    super.key,
    required this.coor
  });

  @override
  State<MatierePage> createState() => _MatierePageState();
}

class _MatierePageState extends State<MatierePage> {
  List<Matiere> matieres = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    FetchData();
  }

  void FetchData() async {
    final apiUrl = Uri.parse('http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/matieres');
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
          matieres = jsonList.map((json) => Matiere.fromJson(json)).toList();
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

  void addMat() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter Matiere'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nom de la matiere',
                  hintText: 'Entrez le nom',
                ),
              )
            ],
          ),
          actions: [
            MyPrimaryButtonButton(
              text: 'Ajouter',
              onTap: () async {
                final name = nameController.text.trim();

                // Check for empty fields
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text('Tous les champs sont obligatoires.'),
                    ),
                  );
                  return;
                }

                // Check for duplicate names (case-insensitive)
                final nameExists = matieres.any((matiere) =>
                matiere.name.toLowerCase() == name.toLowerCase());

                if (nameExists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text('Une filière avec ce nom existe déjà.'),
                    ),
                  );
                  return;
                }

                // Perform POST request to add new Filiere
                final apiUrl = Uri.parse(
                    'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/matieres');

                try {
                  final response = await http.post(
                    apiUrl,
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': GlobalUser.verificationToken!,
                      'Email': GlobalUser.email!
                    },
                    body: jsonEncode({
                      'name': name,
                    }),
                  );

                  if (response.statusCode == 201) {
                    // Success, refresh the data
                    FetchData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('Matiere ajoutée avec succès!'),
                      ),
                    );
                    Navigator.pop(context); // Close the dialog
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.redAccent,
                        content: Text(
                            'Erreur lors de l\'ajout: ${response.statusCode}'),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exception: $e')),
                  );
                }
              },
              color: Colors.green,
            ),
            SizedBox(height: 10),
            MyPrimaryButtonButton(
              text: 'Annuler',
              onTap: () {
                Navigator.pop(context);
              },
              color: Colors.black,
            ),
          ],
        );
      },
    );
  }

  void deleteMat() {
    showDialog(
      context: context,
      builder: (context) {
        List<int?> selectedFiliereIds = [];

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Supprimer Matiere'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: matieres.length,
                  itemBuilder: (context, index) {
                    final matiere = matieres[index];
                    return CheckboxListTile(
                      title: Text(matiere.name),
                      value: selectedFiliereIds.contains(matiere.id),
                      onChanged: (isSelected) {
                        setState(() {
                          if (isSelected == true) {
                            selectedFiliereIds.add(matiere.id);
                          } else {
                            selectedFiliereIds.remove(matiere.id);
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
                    if (selectedFiliereIds.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.orange,
                          content: Text('Veuillez sélectionner au moins une matiere.'),
                        ),
                      );
                      return;
                    }

                    for (var id in selectedFiliereIds) {
                      try {
                        final deleteUrl = Uri.parse(
                            'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/matieres/$id');
                        final response = await http.delete(
                          deleteUrl,
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': GlobalUser.verificationToken!,
                            'Email': GlobalUser.email!
                          },
                        );

                        if (response.statusCode == 200) {
                          print('Matiere with ID $id deleted successfully.');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text('Matieres supprimées avec succès!'),
                            ),
                          );
                        } else {
                          print(
                              'Failed to delete matiere with ID $id: ${response.body}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Text('Error'),
                            ),
                          );
                        }
                      } catch (e) {
                        print('Exception during delete for Matiere with ID $id: $e');
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

  void editMat(Matiere matiere) {
    final nameController = TextEditingController(text: matiere.name);
    bool isLoading = false; // Tracks loading state

    void showSnackBar(String message, {Color backgroundColor = Colors.redAccent}) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: backgroundColor,
          content: Text(message),
        ),
      );
    }

    Future<void> submitEdit() async {
      final name = nameController.text.trim();

      // Input validation
      if (name.isEmpty) {
        showSnackBar('Tous les champs sont obligatoires.');
        return;
      }

      final apiUrl = Uri.parse(
        'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/matieres/${matiere.id}',
      );

      // Show a loading indicator
      setState(() {
        isLoading = true;
      });

      try {
        final response = await http.put(
          apiUrl,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': GlobalUser.verificationToken!,
            'Email': GlobalUser.email!
          },
          body: jsonEncode({
            'name': name,
          }),
        );

        if (response.statusCode == 200) {
          // Assume data refresh is successful
          FetchData();
          showSnackBar('Matiere modifiée avec succès!', backgroundColor: Colors.green);
          Navigator.pop(context); // Close dialog
        } else {
          final errorMsg = jsonDecode(response.body)['message'] ?? 'Erreur inconnue';
          showSnackBar('Erreur: $errorMsg');
        }
      } catch (e) {
        showSnackBar('Exception: $e');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Modifier Matiere'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de la Matiere',
                      hintText: 'Entrez le nom',
                    ),
                  ),
                ],
              ),
              actions: [
                if (isLoading)
                  const CircularProgressIndicator()
                else
                  MyPrimaryButtonButton(
                    text: 'Modifier',
                    onTap: submitEdit,
                    color: Colors.green,
                  ),
                const SizedBox(height: 10),
                MyPrimaryButtonButton(
                  text: 'Annuler',
                  onTap: () {
                    Navigator.pop(context);
                  },
                  color: Colors.black,
                ),
              ],
            );
          },
        );
      },
    );
  }

  void searchMatieres(String query) async {
    if (query.isEmpty) {
      FetchData(); // Reset to all data when query is empty
      return;
    }

    final searchUrl = Uri.parse('http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/matieres/search?key=$query');
    print('SEARCHING FOR: $query');

    try {
      final response = await http.get(
        searchUrl,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': GlobalUser.verificationToken!,
          'Email': GlobalUser.email!
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          matieres = jsonList.map((json) => Matiere.fromJson(json)).toList();
          isLoading = false;
        });
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
      title: 'Matieres',
      body: Column(
        children: [
          SizedBox(height: 10),
          // Add search bar here
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Rechercher une matiere',
                hintText: 'Entrez le nom...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (value) {
                searchMatieres(value); // Trigger search on every input change
              },
            ),
          ),
          SizedBox(height: 20),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: matieres.length,
              itemBuilder: (context, index) {
                final matiere = matieres[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: InfoCard(
                    title: matiere.name,
                    capacity: -1,
                    edit: () => editMat(matiere),
                    toEdit: widget.coor,
                    icon: Icons.edit,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 25),
          widget.coor
              ? Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  children: [
                    MyPrimaryButtonButton(
                      text: '  Ajouter  ',
                      onTap: addMat,
                      color: Colors.green,
                    ),
                    SizedBox(height: 15),
                    MyPrimaryButtonButton(
                      text: 'Supprimer',
                      onTap: deleteMat,
                      color: Colors.redAccent,
                    ),
                  ],
                ),
              ],
            ),
          )
              : SizedBox(height: 1),
          SizedBox(height: 15),
        ],
      ),
    );
  }
}