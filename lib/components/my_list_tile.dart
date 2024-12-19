import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final String title;
  final String route;
  final IconData icon;
  final bool isLogOut;
  const MyListTile({
    super.key,
    required this.title,
    required this.route,
    required this.isLogOut,
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
          if (isLogOut) {
            // Show a confirmation dialog for logout
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Confirm Logout'),
                  content: Text('Are you sure you want to log out?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        print('User logged out');
                        if (ModalRoute.of(context)?.settings.name != '/${route}') {
                          print('hello');
                          Navigator.pop(context);
                          Navigator.pushReplacementNamed(context, '/${route}');
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Logout'),
                    ),
                  ],
                );
              },
            );
          } else {
            if (ModalRoute.of(context)?.settings.name != '/${route}') {
              print('hello');
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/${route}');
            } else {
              Navigator.pop(context);
            }
          }
        },
      ),
    );
  }
}
