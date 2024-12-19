import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyCard extends StatefulWidget {
  final double width;
  final double height;
  final String title;
  final String data;
  final String? description; // Optional description

  const MyCard({
    super.key,
    required this.height,
    required this.width,
    required this.title,
    required this.data,
    this.description, // Make description optional
  });

  @override
  State<MyCard> createState() => _MyCardState();
}

class _MyCardState extends State<MyCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.shade100,
      ),
      height: widget.height,
      width: widget.width,
      child: Column(
        children: [
          SizedBox(height: 20),
          Row(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  '${widget.title} :',
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 20,
                      fontWeight: FontWeight.w400
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Text(
              '${widget.data}',
              style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
          // Conditionally display description if it's not null
          if (widget.description != null) ...[
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Text(
                '${widget.description}',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 16,
                  fontWeight: FontWeight.w300, // Example style for description
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
