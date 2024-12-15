import 'package:flutter/material.dart';

class LiberationCard extends StatefulWidget {
  final String? matiere;
  final String? seance;
  final String? salle;
  final String? week;
  final int? liberationId;
  final VoidCallback onPressed; // Function to be executed on button press

  const LiberationCard({
    super.key,
    required this.matiere,
    required this.seance,
    required this.salle,
    required this.week,
    required this.liberationId,
    required this.onPressed,
  });

  @override
  State<LiberationCard> createState() => _LiberationCardState();
}

class _LiberationCardState extends State<LiberationCard> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(widget.seance!),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Week : '),
                        Text(widget.week!),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Matiere : '),
                        Text(widget.matiere!),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('Salle : '),
                        Text(widget.salle!),
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
                      onTap: widget.onPressed,
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
