import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String route;
  final IconData icon;
  const MyListTile({
    super.key,
    required this.title,
    required this.route,
    required this.icon
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.black,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        onTap: () {
          if (ModalRoute.of(context)?.settings.name != '/${route}') {
            print('heloo');
            Navigator.pop(context); // Close the drawer
            Navigator.pushReplacementNamed(context, '/${route}'); // Navigate to Home
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
