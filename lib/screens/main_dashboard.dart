import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:login_test/components/my_card_type1.dart';
import 'package:intl/intl.dart';
import '../../data/global_user.dart';
import '../../components/my_card_type2.dart';
import '../../shared/based_scaffold.dart';

class MainDashboard extends StatefulWidget {
  final String? username = GlobalUser.username;

  MainDashboard({
    super.key,
  });

  @override
  State<MainDashboard> createState() => _CoorMainPageState();
}

class _CoorMainPageState extends State<MainDashboard> {

  String title() {
    if (GlobalUser.role == "RESPONSABLE_SALLES")
      {return "RESPONSABLE SALLES";}
    return GlobalUser.role!;
  }

  String formattedDate = DateFormat('EEEE,\nMMMM d\nyyyy').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
        title: title(),
        body: SingleChildScrollView(
          child: Center(
              child: Column(
                children: [
                  SizedBox(height: 30),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Welcome, ',
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w500, // Example style for part1
                          ),
                        ),
                        TextSpan(
                          text: widget.username,
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            fontSize: 20,
                            color: Colors.black, // Example style for part2
                            fontWeight: FontWeight.bold, // Example style for part2
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  MyCard(
                      height: 200,
                      width: 400,
                      title: 'Current Date',
                      data: formattedDate
                  ),
                  SizedBox(height: 20)
                ],
              )
          ),
        )
    );
  }
}
