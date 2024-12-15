import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmploiSlot extends StatefulWidget {
  final String time;
  final String type;
  final String matiere;
  final String prof;
  final String salle;
  final VoidCallback edit;
  final VoidCallback delete;

  const EmploiSlot({
    super.key,
    required this.time,
    required this.type,
    required this.matiere,
    required this.prof,
    required this.salle,
    required this.edit,
    required this.delete
  });

  @override
  State<EmploiSlot> createState() => _EmploiSlotState();
}

class _EmploiSlotState extends State<EmploiSlot> {
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
                        onTap: widget.edit,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: GestureDetector(
                      onTap: widget.delete,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: const Icon(
                          Icons.delete,
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
