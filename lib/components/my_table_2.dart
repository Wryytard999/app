import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyTable2 extends StatefulWidget {
  final String? week;
  final String? day;
  final String? seance;
  final String? salle;
  final String? filiere;

  const MyTable2({
    Key? key,
    required this.filiere,
    required this.salle,
    required this.day,
    required this.seance,
    required this.week
  }) : super(key: key);

  @override
  State<MyTable2> createState() => _MyTable2State();
}

class _MyTable2State extends State<MyTable2> {

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical, // Allow vertical scrolling
      child: Center(
        child: Container(
          width: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: Colors.grey.shade200,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 5,
                offset: Offset(0, 3), // Shadow position
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Text('Day :'),
                    SizedBox(width: 5),
                    Text(widget.day!)
                  ],
                ),
                Row(
                  children: [
                    Text('Week :'),
                    SizedBox(width: 5),
                    Text(widget.week!)
                  ],
                ),
                Row(
                  children: [
                    Text('Seance :'),
                    SizedBox(width: 5),
                    Text(widget.seance!)
                  ],
                ),
                Row(
                  children: [
                    Text('Filiere :'),
                    SizedBox(width: 5),
                    Text(widget.filiere!)
                  ],
                ),
                Row(
                  children: [
                    Text('Salle :'),
                    SizedBox(width: 5),
                    Text(widget.salle!)
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}