import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ButtonCard extends StatefulWidget {
  final Color color;
  final String title;
  final String route;
  final IconData icon;
  final bool role;

  const ButtonCard({
    super.key,
    required this.title,
    required this.color,
    required this.icon,
    required this.route,
    required this.role
  });

  @override
  State<ButtonCard> createState() => _ButtonCardState();
}

class _ButtonCardState extends State<ButtonCard> {


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.role) {
          final targetRoute = '/${widget.route}';

          if (ModalRoute.of(context)?.settings.name != targetRoute) {
            print('hello'); // Close the drawer
            Navigator.pushReplacementNamed(context, targetRoute); // Navigate to the target route
          } else {
            Navigator.pop(context); // Just close the drawer
          }
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
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: widget.color,
        ),
        child: Center(
          child: Row(
            children: [
              Icon(widget.icon),
              SizedBox(width: 10),
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
