import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MySecondaryButton extends StatefulWidget {
  final String text;
  final void Function()? onTap;

  const MySecondaryButton({
    super.key,
    required this.text,
    required this.onTap
  });

  @override
  State<MySecondaryButton> createState() => _MySecondaryButtonState();
}

class _MySecondaryButtonState extends State<MySecondaryButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
            color: Colors.grey.shade400
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
