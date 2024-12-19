import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ButtonCardDiag extends StatefulWidget {
  final Color color;
  final String title;
  final List<String> subroutes;
  final List<String> subRoutesNames;
  final IconData icon;
  final bool role;

  const ButtonCardDiag({
    super.key,
    required this.title,
    required this.color,
    required this.icon,
    required this.subroutes,
    required this.subRoutesNames,
    required this.role
  });

  @override
  State<ButtonCardDiag> createState() => _ButtonCardDiagState();
}

class _ButtonCardDiagState extends State<ButtonCardDiag> {
  late Map<String, String> subRoutes;

  @override
  void initState() {
    super.initState();

    // Populate the subRoutes map with the provided lists
    subRoutes = {
      for (int i = 0; i < widget.subroutes.length; i++)
        widget.subRoutesNames[i]: widget.subroutes[i]
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.role) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Select an Option'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: subRoutes.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Close the dialog
                          Navigator.pushNamed(context, entry.value); // Navigate to the subroute
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.color,
                        ),
                        child: Text(entry.key),
                      ),
                    );
                  }).toList(),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                    },
                    child: Text('Cancel'),
                  ),
                ],
              );
            },
          );
        } else {
          // Show the SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vous n\'êtes pas autorisé à effectuer cette action'),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
      child: Container(
        height: 80,
        width: 174,
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: widget.color,
        ),
        child: Center(
          child: Row(
            children: [
              Icon(widget.icon),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.title,
                  overflow: TextOverflow.visible, // Allows wrapping
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}