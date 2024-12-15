import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:login_test/components/info_card.dart';
import 'package:login_test/shared/based_scaffold.dart';
import '../components/my_primary_button.dart';
import '../data/filieres.dart';
import '../data/global_user.dart';

class FilieresPage extends StatefulWidget {
  final bool coor;

  const FilieresPage({
    super.key,
    required this.coor
  });

  @override
  State<FilieresPage> createState() => _FilieresPageState();
}

class _FilieresPageState extends State<FilieresPage> {
  List<Filiere> filieres = [];
  bool isLoading = true;

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
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void addFil() {
    final nameController = TextEditingController();
    final capacityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ajouter Filiere'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nom de la Filiere',
                  hintText: 'Entrez le nom',
                ),
              ),
              TextField(
                controller: capacityController,
                decoration: InputDecoration(
                  labelText: 'Capacité',
                  hintText: 'Entrez la capacité',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            MyPrimaryButtonButton(
              text: 'Ajouter',
              onTap: () async {
                final name = nameController.text.trim();
                final capacityText = capacityController.text.trim();

                // Check for empty fields
                if (name.isEmpty || capacityText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text('Tous les champs sont obligatoires.'),
                    ),
                  );
                  return;
                }

                // Validate capacity
                if (int.tryParse(capacityText) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.redAccent,
                      content: Text('La capacité doit être un entier valide.'),
                    ),
                  );
                  return;
                }

                // Check for duplicate names (case-insensitive)
                final nameExists = filieres.any((filiere) =>
                filiere.name.toLowerCase() == name.toLowerCase());

                if (nameExists) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.orange,
                      content: Text('Une filière avec ce nom existe déjà.'),
                    ),
                  );
                  return;
                }

                final capacity = int.parse(capacityText);

                // Perform POST request to add new Filiere
                final apiUrl = Uri.parse(
                    'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/filieres');

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
                      'capacity': capacity,
                    }),
                  );

                  if (response.statusCode == 201) {
                    // Success, refresh the data
                    FetchData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('Filiere ajoutée avec succès!'),
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


  void deleteFilieres() {
    showDialog(
      context: context,
      builder: (context) {
        List<int?> selectedFiliereIds = [];

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Supprimer Filieres'),
              content: SizedBox(
                width: double.maxFinite,
                height: 300,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filieres.length,
                  itemBuilder: (context, index) {
                    final filiere = filieres[index];
                    return CheckboxListTile(
                      title: Text(filiere.name),
                      value: selectedFiliereIds.contains(filiere.id),
                      onChanged: (isSelected) {
                        setState(() {
                          if (isSelected == true) {
                            selectedFiliereIds.add(filiere.id);
                          } else {
                            selectedFiliereIds.remove(filiere.id);
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
                          content: Text('Veuillez sélectionner au moins une filière.'),
                        ),
                      );
                      return;
                    }

                    for (var id in selectedFiliereIds) {
                      try {
                        final deleteUrl = Uri.parse(
                            'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/filieres/$id');
                        final response = await http.delete(
                          deleteUrl,
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': GlobalUser.verificationToken!,
                            'Email': GlobalUser.email!
                          },
                        );

                        if (response.statusCode == 200) {
                          print('Filiere with ID $id deleted successfully.');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text('Filières supprimées avec succès!'),
                            ),
                          );
                        } else {
                          print(
                              'Failed to delete Filiere with ID $id: ${response.body}');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.redAccent,
                              content: Text('Error'),
                            ),
                          );
                        }
                      } catch (e) {
                        print('Exception during delete for Filiere with ID $id: $e');
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

  void editFil(Filiere filiere) {
    final nameController = TextEditingController(text: filiere.name);
    final capacityController = TextEditingController(text: filiere.capacity.toString());
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
      final capacityText = capacityController.text.trim();

      // Input validation
      if (name.isEmpty || capacityText.isEmpty) {
        showSnackBar('Tous les champs sont obligatoires.');
        return;
      }

      final capacity = int.tryParse(capacityText);
      if (capacity == null) {
        showSnackBar('La capacité doit être un entier valide.');
        return;
      }

      final apiUrl = Uri.parse(
        'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/filieres/${filiere.id}',
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
            'capacity': capacity,
          }),
        );

        if (response.statusCode == 200) {
          // Assume data refresh is successful
          FetchData();
          showSnackBar('Filière modifiée avec succès!', backgroundColor: Colors.green);
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
              title: const Text('Modifier Filière'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de la Filière',
                      hintText: 'Entrez le nom',
                    ),
                  ),
                  TextField(
                    controller: capacityController,
                    decoration: const InputDecoration(
                      labelText: 'Capacité',
                      hintText: 'Entrez la capacité',
                    ),
                    keyboardType: TextInputType.number,
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




  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'Filieres',
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
                    capacity: filiere.capacity,
                    edit: () => editFil(filiere),
                    toEdit: widget.coor,
                    icon: Icons.edit,
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
                Column(
                  children: [
                    MyPrimaryButtonButton(
                      text: '  Ajouter  ',
                      onTap: addFil,
                      color: Colors.green,
                    ),
                    SizedBox(height: 15),
                    MyPrimaryButtonButton(
                      text: 'Supprimer',
                      onTap: deleteFilieres,
                      color: Colors.redAccent,
                    ),
                  ],
                ),
              ],
            ),
          ) : SizedBox(height: 1),
          SizedBox(height: 15)
        ],
      )
    );
  }
}
