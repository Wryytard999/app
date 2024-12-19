import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:login_test/components/info_card.dart';
import 'package:login_test/data/salles.dart';
import 'package:login_test/shared/based_scaffold.dart';
import '../components/my_primary_button.dart';
import '../data/global_user.dart';

class RespoSalle1 extends StatefulWidget {
  final bool respo;

  const RespoSalle1({
    super.key,
    required this.respo
  });

  @override
  State<RespoSalle1> createState() => _RespoSalle1State();
}

class _RespoSalle1State extends State<RespoSalle1> {
  Map<String, int> locationCounts = {}; // Map to hold location and salle count
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    FetchData();
  }

  void FetchData() async {
    final apiUrl = Uri.parse('http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/salles');
    print('GETTING DATA FROM API...');

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
          // Convert JSON list to `Salles` objects
          List<Salles> salles = jsonList.map((json) => Salles.fromJson(json)).toList();
          // Group by location and count the number of salles for each
          locationCounts = {};
          for (var salle in salles) {
            locationCounts[salle.location] = (locationCounts[salle.location] ?? 0) + 1;
          }
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

  void addSalle() async {
    final _formKey = GlobalKey<FormState>();
    String? name;
    String? location;
    int? numberOfSeats;
    String? type;
    bool isAddingNewLocation = false;

    // Initialize `existingLocations` as an empty list
    List<String> existingLocations = [];

    // Fetch locations before showing the dialog
    Future<void> fetchSalles() async {
      final apiUrl = Uri.parse('http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/salles');
      try {
        final response = await http.get(apiUrl, headers: {
          'Content-Type': 'application/json',
          'Authorization': GlobalUser.verificationToken!,
          'Email': GlobalUser.email!,
        });

        if (response.statusCode == 200) {
          final List<dynamic> salles = jsonDecode(response.body);
          existingLocations = salles.map((salle) => salle['location'] as String).toSet().toList();
        } else {
          print('Failed to fetch salles: ${response.body}');
        }
      } catch (e) {
        print('Error fetching salles: $e');
      }
    }

    // Fetch locations first
    await fetchSalles();

    // Show dialog after fetching locations
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a New Salle'),
          content: Form(
            key: _formKey,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name input
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                      onSaved: (value) => name = value,
                    ),
                    // Location input or dropdown
                    isAddingNewLocation
                        ? TextFormField(
                      decoration: InputDecoration(labelText: 'New Location'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a location';
                        }
                        return null;
                      },
                      onSaved: (value) => location = value,
                    )
                        : DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Location'),
                      items: [
                        ...existingLocations.map((String loc) {
                          return DropdownMenuItem<String>(
                            value: loc,
                            child: Text(loc),
                          );
                        }),
                        DropdownMenuItem<String>(
                          value: 'AddNew',
                          child: Text('Add New Location'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          if (value == 'AddNew') {
                            isAddingNewLocation = true;
                          } else {
                            location = value;
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null && !isAddingNewLocation) {
                          return 'Please select or add a location';
                        }
                        return null;
                      },
                    ),
                    // Number of seats input
                    TextFormField(
                      decoration: InputDecoration(labelText: 'Number of Seats'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                      onSaved: (value) => numberOfSeats = int.tryParse(value!),
                    ),
                    // Type dropdown
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Type'),
                      items: ['TD', 'TP', 'COURS'].map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a type';
                        }
                        return null;
                      },
                      onChanged: (value) => type = value,
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  // Add new location to the list if provided
                  if (isAddingNewLocation && location != null) {
                    existingLocations.add(location!);
                  }

                  // Make API POST request
                  final apiUrl = Uri.parse('http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/salles');
                  try {
                    final response = await http.post(
                      apiUrl,
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': GlobalUser.verificationToken!,
                        'Email': GlobalUser.email!,
                      },
                      body: jsonEncode({
                        'name': name,
                        'location': location,
                        'numberOfSeats': numberOfSeats,
                        'type': type,
                      }),
                    );

                    if (response.statusCode == 201) {
                      FetchData();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Salle added successfully!')),
                      );
                    } else {
                      print(response.body);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add salle: ${response.body}')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  VoidCallback accessSalles(String location) {
    return () async {
      List<dynamic> sallesInLocation = [];

      // Fetch salles in the selected location
      try {
        final apiUrl = Uri.parse('http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/salles');
        final response = await http.get(
          apiUrl,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': GlobalUser.verificationToken!,
            'Email': GlobalUser.email!,
          },
        );

        if (response.statusCode == 200) {
          final List<dynamic> sallesList = jsonDecode(response.body);
          sallesInLocation = sallesList.where((salle) => salle['location'] == location).toList();

          if (sallesInLocation.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('No salles available in this location.'),
                  backgroundColor: Colors.redAccent,
              ),
            );
            return;
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to get salles.')),
          );
          return;
        }
      } catch (e) {
        print('Error: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        return;
      }

      // Show salles in the selected location
      showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16), // Add a SizedBox for spacing at the top
              Expanded(
                child: ListView.builder(
                  itemCount: sallesInLocation.length,
                  itemBuilder: (context, index) {
                    final salle = sallesInLocation[index];
                    return ListTile(
                      title: Text(salle['name']),
                      subtitle: Text('Seats: ${salle['numberOfSeats']}, Type: ${salle['type']}'),
                      onTap: () {
                        Navigator.of(context).pop(); // Close the bottom sheet
                        showSalleOptions(salle);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    };
  }

  void showSalleOptions(dynamic salle) {
    final _formKey = GlobalKey<FormState>();
    String? updatedName = salle['name'];
    int? updatedSeats = salle['numberOfSeats'];
    String? updatedType = salle['type'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier Salle'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: updatedName,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onChanged: (value) => updatedName = value,
                ),
                TextFormField(
                  initialValue: updatedSeats.toString(),
                  decoration: InputDecoration(labelText: 'Number of Seats'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                  onChanged: (value) => updatedSeats = int.tryParse(value),
                ),
                DropdownButtonFormField<String>(
                  value: updatedType,
                  decoration: InputDecoration(labelText: 'Type'),
                  items: ['TD', 'TP', 'COURS'].map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) => updatedType = value,
                ),
              ],
            ),
          ),
          actions: [
            MyPrimaryButtonButton(
                text: 'Update',
                onTap: () async {
                  // Validate and update
                  if (_formKey.currentState!.validate()) {
                    final apiUrl = Uri.parse(
                        'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/salles/${salle['id']}');
                    try {
                      final response = await http.put(
                        apiUrl,
                        headers: {
                          'Content-Type': 'application/json',
                          'Authorization': GlobalUser.verificationToken!,
                          'Email': GlobalUser.email!,
                        },
                        body: jsonEncode({
                          'name': updatedName,
                          'numberOfSeats': updatedSeats,
                          'type': updatedType,
                          'location': salle['location'],
                        }),
                      );

                      if (response.statusCode == 200) {
                        FetchData(); // Refresh the data
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Salle updated successfully!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to update salle: ${response.body}')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                color: Colors.green
            ),
            SizedBox(height: 10),
            MyPrimaryButtonButton(
                text: 'Delete',
                onTap: () async {
                  print(salle['id']);
                  // Delete the salle
                  final apiUrl = Uri.parse(
                      'http://10.0.2.2:8080/School_1-1.0-SNAPSHOT/api/salles/${salle['id']}');
                  try {
                    final response = await http.delete(
                      apiUrl,
                      headers: {
                        'Content-Type': 'application/json',
                        'Authorization': GlobalUser.verificationToken!,
                        'Email': GlobalUser.email!,
                      },
                    );

                    if (response.statusCode <= 300 || response.statusCode >= 200) {
                      FetchData(); // Refresh the data
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Salle deleted successfully!'),
                            backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      print('this is the error ${response.body}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Failed to delete salle'),
                            backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error'),
                          backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                },
                color: Colors.redAccent
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      title: 'SALLES',
      body: Column(
        children: [
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: locationCounts.keys.length,
              itemBuilder: (context, index) {
                final location = locationCounts.keys.elementAt(index);
                final count = locationCounts[location]!;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: InfoCard(
                    title: location, // Display the location
                    capacity: count, // Display the count of salles in that location
                    edit: accessSalles(location),
                    toEdit: widget.respo,
                    icon: Icons.remove_red_eye_rounded,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 25),
          widget.respo
              ? Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  children: [
                    MyPrimaryButtonButton(
                      text: '  Ajouter  ',
                      onTap: addSalle,
                      color: Colors.green,
                    ),
                    SizedBox(height: 15),
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
