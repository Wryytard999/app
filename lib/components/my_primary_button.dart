import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyPrimaryButtonButton extends StatefulWidget {
  final String text;
  final Color color;
  final void Function()? onTap;

  const MyPrimaryButtonButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.color
  });

  @override
  State<MyPrimaryButtonButton> createState() => _MyPrimaryButtonState();
}

class _MyPrimaryButtonState extends State<MyPrimaryButtonButton> {

  
  @override
  Widget build(BuildContext context) {
    Color mycolor = widget.color;
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: widget.color,
          boxShadow: [
            BoxShadow(
              color: mycolor.withOpacity(0.3),
              spreadRadius: 1.5,
              blurRadius: 5,
              offset: Offset(0, 3), // Shadow position
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.text,
            style: TextStyle(
                color: Colors.white,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                fontSize: 16
            ),
          ),
        ),
      ),
    );
  }
}
