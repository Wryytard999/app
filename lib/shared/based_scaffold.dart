import 'package:flutter/material.dart';
import 'package:login_test/components/my_list_tile.dart';
import 'package:login_test/data/global_user.dart';

class BaseScaffold extends StatefulWidget {
  final String title;
  final Widget body;

  BaseScaffold({super.key, required this.title, required this.body});

  @override
  _BaseScaffoldState createState() => _BaseScaffoldState();
}

class _BaseScaffoldState extends State<BaseScaffold> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.black,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black87,
              ),
              child: Center(
                child: const Text(
                  'G-SALLES',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                  ),
                ),
              ),
            ),
            MyListTile(
              title: 'Home',
              route: 'home',
              icon: Icons.dashboard_sharp,
            ),
            MyListTile(
              title: 'Responsable des salles',
              route: 'respo',
              icon: Icons.manage_accounts,
            ),
            ExpansionTile(
              title: Row(
                children: [
                  Icon(Icons.file_present_rounded, color: Colors.black87),
                  SizedBox(width: 16),
                  Text(
                    'Manage filiere',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              children: [
                MyListTile(
                  title: 'General',
                  route: 'filiere',
                  icon: Icons.add,
                ),
                MyListTile(
                  title: 'Filieres Matiere',
                  route: 'filiereMat',
                  icon: Icons.add,
                ),
                MyListTile(
                  title: 'Filieres Emploi',
                  route: 'emploi',
                  icon: Icons.add,
                ),
              ],
            ),
            GlobalUser.isProf() ?
            ExpansionTile(
              title: Row(
                children: [
                  Icon(Icons.man, color: Colors.black87),
                  SizedBox(width: 16),
                  Text(
                    'Manage prof',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              children: [
                MyListTile(
                  title: 'Reservation',
                  route: 'prof',
                  icon: Icons.add,
                ),
                MyListTile(
                  title: 'Liberation',
                  route: 'lib',
                  icon: Icons.add,
                )
              ],
            ) : SizedBox(height: 2),
            MyListTile(
              title: 'Matieres',
              route: 'Matiere',
              icon: Icons.subject,
            ),
            MyListTile(
              title: 'Log out',
              route: 'login',
              icon: Icons.logout,
            ),
          ],
        ),
      ),
      body: widget.body,
    );
  }
}