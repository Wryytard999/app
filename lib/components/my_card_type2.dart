import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InfoCard2 extends StatefulWidget {
  final String title;
  final int capacity;
  final VoidCallback edit;
  final bool toEdit;
  final IconData icon;

  const InfoCard2({
    super.key,
    required this.title,
    required this.capacity,
    required this.edit,
    required this.toEdit,
    required this.icon
  });

  @override
  State<InfoCard2> createState() => _InfoCard2State();
}

class _InfoCard2State extends State<InfoCard2> {
  @override
  Widget build(BuildContext context) {
    return Center(
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
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align left
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis, // Add ellipsis when text overflows
                      maxLines: 2, // Limit to a single line
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Modules : ${widget.capacity}',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            widget.toEdit ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: widget.edit,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(7), // Add rounded corners
                  ),
                  child: Icon(
                    widget.icon,
                    color: Colors.white,
                  ),
                ),
              ),
            ) : SizedBox(height: 1),
          ],
        ),
      )
      ,
    );
  }
}
