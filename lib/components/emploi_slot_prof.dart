import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmploiSlotProf extends StatefulWidget {
  final String time;
  final String type;
  final String matiere;
  final String prof;
  final String salle;
  final VoidCallback func;

  const EmploiSlotProf({
    super.key,
    required this.time,
    required this.type,
    required this.matiere,
    required this.prof,
    required this.salle,
    required this.func
  });

  @override
  State<EmploiSlotProf> createState() => _EmploiSlotProfState();
}

class _EmploiSlotProfState extends State<EmploiSlotProf> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.grey.shade200,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(widget.time),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Type : '),
                        Text(widget.type),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Matiere : '),
                        Text(widget.matiere),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Prof : '),
                        Text(widget.prof),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Salle : '),
                        Text(widget.salle),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: GestureDetector(
                      onTap: widget.func,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Icon(
                          Icons.free_cancellation_outlined,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
