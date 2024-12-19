import 'package:flutter/material.dart';
import 'package:login_test/screens/filiere_emploi.dart';
import 'package:login_test/screens/filiere_mat.dart';
import 'package:login_test/screens/filieres_page.dart';
import 'package:login_test/screens/liberation.dart';
import 'package:login_test/screens/main_dashboard.dart';
import 'package:login_test/screens/reservation.dart';
import 'package:login_test/screens/matiere_page.dart';
import 'package:login_test/screens/respo_salle1.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:login_test/screens/login.dart';
import 'data/global_user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // Text styles
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 15,
    fontFamily: 'Montserrat',
    color: Colors.black54,
  );
  static const TextStyle titleStyle = TextStyle(
    fontWeight: FontWeight.bold,
    fontFamily: 'Montserrat',
    fontSize: 40,
  );


  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.material(
      initialRoute: '/login',
      routes: {
        '/home': (context) => MainDashboard(),
        '/login': (context) => WillPopScope(
          onWillPop: () async {
            // Prevent swiping back or pressing the back button on the login page
            return false;
          },
          child: Login(),
        ),
        '/respo': (context) => RespoSalle1(respo: GlobalUser.isRespo()),
        '/prof': (context) => ManageProf(prof: GlobalUser.isProf()),
        '/lib': (context) => Liberation(prof: GlobalUser.isProf()),
        '/filiere': (context) => FilieresPage(coor: GlobalUser.isCoor()),
        '/filiereMat': (context) => FiliereMat(coor: GlobalUser.isCoor()),
        '/Matiere': (context) => MatierePage(coor: GlobalUser.isCoor()),
        '/emploi': (context) => EmploiPage(coor: GlobalUser.isCoor()),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => MainDashboard(),
      ),
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async {
          // Prevent swiping back or pressing the back button on the initial login page
          return false;
        },
        child: Login(),
      ),
    );
  }
}