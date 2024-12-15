import 'package:flutter/material.dart';
import 'package:login_test/screens/emploi_page.dart';
import 'package:login_test/screens/filiere_mat.dart';
import 'package:login_test/screens/filieres_page.dart';
import 'package:login_test/screens/liberation.dart';
import 'package:login_test/screens/main_dashboard.dart';
import 'package:login_test/screens/manage_prof.dart';
import 'package:login_test/screens/matiere_page.dart';
import 'package:login_test/screens/respo_salle1.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:login_test/screens/login.dart';
import 'data/global_user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.material(
      initialRoute: '/login',
      routes: {
        '/home': (context) => MainDashboard(), // Replace HomePage with your actual widget
        '/login': (context) => Login(),
        '/respo': (context) => RespoSalle1(respo: GlobalUser.isRespo(),),
        '/prof': (context) => ManageProf(prof: GlobalUser.isProf(),),
        '/lib': (context) => Liberation(prof: GlobalUser.isProf(),),
        '/filiere' : (context) => FilieresPage(coor: GlobalUser.isCoor()),
        '/filiereMat' : (context) => FiliereMat(coor: GlobalUser.isCoor()),
        '/Matiere' : (context) => MatierePage(coor: GlobalUser.isCoor()),
        '/emploi' : (context) => EmploiPage(coor: GlobalUser.isCoor()),
        // Add other routes as necessary
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const Login(),
      ),
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}